classdef ParamMg < handle
    %PARAMMG Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ParamStoreArray;
    end
    
    methods
        
        %Construct ParamMg object
        %can accept default construct, with out input argrument.
        function Obj = ParamMg(ParamStoreIn)
            if nargin==0
                Obj.ParamStoreArray = ParamStore;
            else
                if (strcmpi(class(ParamStoreIn),'ParamStore'))
                    Obj.ParamStoreArray = ParamStoreIn;
                else
                    error('Input must the same class of ParamStore');
                end
            end
        end
        
    end
    
    methods (Static = true)
        function Obj = creatPMfromStruct(StructArray)
            Obj = ParamMg;
            Num = length(StructArray);
            for i = 1:Num
                Obj.ParamStoreArray(i) = ParamStore.struct2ParamStore(StructArray(i));
            end
        end
        %write to a XML file
        function rs = writeXmlFile(obj,FileName)
            rs = false;
            expr = '\w+\.xml' ;
            Mat = regexp(FileName,expr,'match');
            if isempty(Mat)
                FileName = [FileName,'.xml'];
            end
            
            docNode = com.mathworks.xml.XMLUtils.createDocument...
                ('Model_Parameter');
            toc = docNode.getDocumentElement;
            toc.setAttribute('version','2.0');
            if length(obj.ParamStoreArray) > 0
                for i = 1:length(obj.ParamStoreArray)
                    temp = obj.ParamStoreArray(i);
                    item = docNode.createElement(['ParamStore',num2str(i)]);
                    item.setAttribute('Des',temp.Des);
                    child = ParamMg.genXmlNode(docNode,item,temp);
                    %item.appendChild(child);
                    toc.appendChild(item);
                end
                
                xmlwrite(FileName,docNode);
                rs = true;
            end
        end
    
       function Obj = readXmlFile(FileName)
           %get rid of Name;
            Obj = [];
            
            expr = '\w+\.xml' ;
            Mat = regexp(FileName,expr,'match');
            if isempty(Mat)
                OtFileName = [FileName,'.xml'];
            else
                OtFileName = FileName ;
            end
            
            %deal with xml file
            %get the xml file
            xDoc = xmlread(OtFileName) ;
            if xDoc.hasChildNodes
                %get the first level Node
                xRoot = xDoc.item(0);
                %check Length of the 1st level Node
                NumxRoot = xRoot.getLength ;
                Param = ParamStore;
                if NumxRoot > 1
                    for cnt = 1:2:NumxRoot-1
                        index = (cnt-1)/2+1 ;
                        Param(index).Des = '';
                        CurNode = xRoot.item(cnt) ;
                        %get Attributes, Only 1 Attributtes for each Node
                        if CurNode.hasAttributes
                           attributes = CurNode.getAttributes;
                           attr = attributes.item(0);
                           Param(index).Des = attr.getValue;
                           ParamMg.genParambyNode(CurNode,Param(index));
                        end
                    end
                end
                Obj = ParamMg(Param);
            end
       end
    end
        
            
    methods (Static = true, Access = private)
        
        %for xml file writing
        function node = genXmlNode(docNode,node,Param)
            if ~Param.isempty
                for i = 1:Param.getLength
                    temp = Param.getParambyIndex(i);
                    item = docNode.createElement(['Param',num2str(i)]);
                    item.setAttribute(temp.Name,temp.Value);
                    node.appendChild(item);
                end
            end
        end
        
        function genParambyNode(Node,Param)
            Num = Node.getLength;
            if Num > 1
                for cnt = 1:2:Num-1
                    Name = '';
                    Value = '';
                    CurNode = Node.item(cnt) ;
                    %get Attributes, Only 1 Attributtes for each Node
                    if CurNode.hasAttributes
                       attributes = CurNode.getAttributes;
                       attr = attributes.item(0);
                       Name = char(attr.getName);
                       Value = char(attr.getValue);
                    end
                    temp = AtriPair(Name,Value) ;
                    Param.addParam(temp);
                end
            end
        end
            
    end
    
end

