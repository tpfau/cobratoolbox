classdef IncompatibleOperatingSystem < MException    
    
    methods
        function obj = IncompatibleOperatingSystem()            
            currentMessage = 'This function cannot be used with the current Operating System';
            type = MissingToolboxException.getExceptionType();
            obj@MException(type,currentMessage);
        end               
    end
    
    methods (Static)
        function type = getExceptionType()
            type = 'COBRA:IncompatibleOS'; 
        end
    end
end