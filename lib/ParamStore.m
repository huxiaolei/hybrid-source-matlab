classdef ParamStore < handle
    %PARAMSTORE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = private )
        Param
    end
    
    properties %(SetAccess = private, GetAccess = private )
        Des
    end
    
    methods
        
        function Obj = ParamStore(AtriPairIn)
            Obj.Des = '';
            if nargin==0
                Obj.Param = [] ;
            else
                if strcmpi(class(AtriPairIn),'AtriPair') == true
                    Obj.Param = AtriPairIn.copy ;
                else
                    error('input must be object of AtriPair')
                end
            end
        end
        
        function set.Param(obj,AtriPairIn)
            if strcmpi(class(AtriPairIn),'AtriPair') == true
                obj.Param = AtriPairIn ;
            elseif isempty(AtriPairIn)
                obj.Param = [];
            else
                error('input must be object of AtriPair')
            end
        end
        
        function set.Des(obj,DesIn)
            obj.Des = char(DesIn);
        end
        
        %get TotalNum of the Param Store in the Object
        function Len = getLength(obj)
            Len = length(obj.Param);
        end
        
        %AtriPairIn can be a AtriPair object or a str indicates the name
        %prop of a AtriPair
        function [rs index] = existsAtriPair(obj,AtriPairIn)
           rs = false;
           index = 0 ;
           if ~isempty(obj.Param)
               TotalNum = length(obj.Param);
               for i = 1:TotalNum
                   if obj.Param(i).equals(AtriPairIn)
                       rs = true;
                       index = i ;
                       break;
                   end
               end
           end
        end
        %AtriPairIn can be a AtriPair object or a str indicates the name
        %prop of a AtriPair
        %will return a copy of the original object
        function Obj = getParam(obj,AtriPairIn)
            [rs index] = obj.existsAtriPair(AtriPairIn);
            if rs
                Obj = obj.Param(index).copy;
            else
                Obj = [];
            end
            
        end
        
        %get Param by index
        function Obj = getParambyIndex(obj,index)
            if ~(obj.isempty)
                Obj = obj.Param(index).copy;
            end
        end
        
        %check if ParamStore is empty
        function rs = isempty(obj)
            rs = isempty(obj.Param);
        end
        
        %add an AtriPair into the store
        function addParam(obj,AtriPairIn)
           if strcmpi(class(AtriPairIn),'AtriPair') == true
               rs = obj.existsAtriPair(AtriPairIn);
               if isempty(obj.Param)
                   obj.Param = AtriPairIn.copy ;
               else
                   if rs
                       error('Input has already exists in the store');
                   else
                       TotalNum = length(obj.Param);
                       CurNum = TotalNum + 1;
                       obj.Param(CurNum) = AtriPairIn.copy;
                   end
               end
            else
                error('input must be object of AtriPair')
           end
        end
        
        %delete an AtriPair from the store
        %input could be str or AtriPair
        function del = delParam(obj,AtriPairIn)
            [rs index] = obj.existsAtriPair(AtriPairIn);
            if ~rs
                del = false;
            else
                obj.Param(index) = [] ;
                del = true;
            end
        end
        
        %update an AtriPair from the store
        %input could be str(Name and Value) or AtriPair
        function update = updateParam(obj,AtriPairIn,Value)
            %in this case, AtriPairIn is AtriPair object
            update = false;
            [rs index] = obj.existsAtriPair(AtriPairIn);
            if rs
                if nargin==2
                    obj.Param(index).Value = AtriPairIn.Value;
                    update = true;
                elseif nargin==3
                    obj.Param(index).Value = Value;
                    update = true;
                end
            else
                if nargin==2
                    obj.addParam(AtriPairIn);
                    update = true;
                elseif nargin==3
                    obj.addParam(AtriPairIn,Value);
                    update = true;
                end
            end
        end
        
    end
    
    methods (Static = true)
        %compare two ParamStore object and get the differs
        function rs = getdiffer(ParamS1,ParamS2)
            rs = struct('Name',[],'PreValue',[],'CurValue',[]) ;
            %ParamS1 is the dominent object
            if ~(ParamS1.isempty)
                Num = ParamS1.getLength;
                rsCnt = 1 ;
                for i=1:Num
                    a = ParamS1.getParambyIndex(i) ;
                    b = ParamS2.getParam(a) ;
                    if ~(isempty(b))
                        if ~strcmpi(a.Value,b.Value)
                            rs(rsCnt).Name = a.Name;
                            rs(rsCnt).PreValue = a.Value;
                            rs(rsCnt).CurValue = b.Value;
                            rsCnt = rsCnt+1;
                        end
                    end
                end
            end
        end
        
        %all values are double
        function rs = ParamStore2struct(ParamIn)
            rs = struct();
            rs.('Des') = ParamIn.Des ;
            for i=1:ParamIn.getLength
                CurParam = ParamIn.getParambyIndex(i);
                %rs = setfield(rs,CurParam.Name,str2double(CurParam.Value));
                rs.(CurParam.Name) = str2double(CurParam.Value) ;
            end
        end
        
        function rs = struct2ParamStore(strIn)
            rs = ParamStore;
            %get length namefields of struct 
            StrName = fieldnames(strIn);
            for i =1:length(StrName)
                %getData
                if strcmp(StrName{i},'Des')
                    rs.Des = strIn.(StrName{i});
                else
                    DataValue = strIn.(StrName{i}) ;
                    if isnumeric(DataValue)
                        DataValue = num2str(DataValue,16);
                    else
                        DataValue = char(DataValue);
                    end
                    rs.addParam(AtriPair(StrName{i},DataValue));
                end
            end
        end
        
        %full fill struct
        function StrIn = fullfillStruct(StrIn,ParamIn)
            %find all the field of a struct, and then fullfill it by the
            %corrsponding value of a paramStore obj
            if ~isempty(StrIn) && ~ParamIn.isempty
                %get length namefields of struct
                StrName = fieldnames(StrIn);
                StrIn.('Des') = ParamIn.Des ;
                for i =1:length(StrName)
                    temp = ParamIn.getParam(StrName{i});
                    if ~isempty(temp)
                        try
                            converter = str2double(temp.Value);
                        catch
                            converter = char(temp.Value);
                        end
                        StrIn.(StrName{i}) = converter;
                    end
                end
            end
        end
    end
    
    methods (Static = true, Access = private)
    end
end

