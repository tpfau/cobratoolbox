classdef MissingToolboxException < MException
    
    
    methods
        function obj = MissingToolboxException(Toolboxes)
            if iscell(Toolboxes)
                Toolboxes = strjoin(Toolboxes,'; ');
            end
            currentMessage = ['The following toolboxes are required for this function:\n' Toolboxes];
            type = MissingToolboxException.getExceptionType();
            obj@MException(type,currentMessage);
        end               
    end
    
    methods (Static)
        function type = getExceptionType()
            type = 'COBRA:ToolBoxMissing'; 
        end
    end
end