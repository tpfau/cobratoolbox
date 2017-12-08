classdef NoCompatibleSolverForTest < MException    
    
    methods
        function obj = NoCompatibleSolverForTest(Solvers)            
            if iscell(Solvers)
                Solvers = strjoin(Solvers,', ');
            end
            currentMessage = sprtinf('This function is only tested with the following solvers:\n%s,\n none of which is installed on your system',Solvers);
            type = MissingToolboxException.getExceptionType();
            obj@MException(type,currentMessage);
        end               
    end
    
    methods (Static)
        function type = getExceptionType()
            type = 'COBRA:NoCompliantSolver'; 
        end
    end
end