classdef AtriPair < handle
    %ATRIPAIR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Name;
        Value;
    end
    
    methods
        %first arg is the name
        %second is the value
        %both must be str
        function Obj = AtriPair(Name,Value)
            if nargin==0
                Obj.Name = '' ;
                Obj.Value = '';
            elseif nargin==1
                Obj.Name = Name;
                Obj.Value = '';
            else
                Obj.Name = Name;
                Obj.Value = Value;
            end
        end
        
        %set method for props
        function set.Name(obj,NameIn)
            if ischar(NameIn)
                obj.Name = NameIn ;
            else
                error('input must be string');
            end
        end
        
        function set.Value(obj,ValueIn)
            if ischar(ValueIn)
                obj.Value = ValueIn;
            else
                error('input must be string');
            end
        end
        %return 1by2 cell value which contains the value of Name & Value
        %first cell is the name
        %second cell is the value of the name
        function ObjCell = getCell(obj)
            ObjCell = cell(1,2);
            ObjCell{1,1} = obj.Name;
            ObjCell{1,2} = obj.Value;
        end
        
        %check if the two attribute have the same name.
        %treat them as the same, if they have the same names
        function rs = equals(obj,AtriPairIn)
            rs = false;
            if ischar(AtriPairIn)
                if strcmpi(obj.Name,AtriPairIn)
                    rs = true;
                end
            elseif strcmpi(obj.Name,AtriPairIn.Name)
                rs = true;
            end
        end
        
        %check if value equals
        %if name does not match, always return false;
        function rs = valueEquals(obj,AtriPairIn)
            rs = false;
            if obj.equals(AtriPairIn)
                if strcmp(obj.Value,AtriPairIn.Value)
                    rs = true;
                end
            end
        end
       
        function Obj = copy(obj)
            Obj = AtriPair(obj.Name,obj.Value);
        end
    end
    
    
    
end

