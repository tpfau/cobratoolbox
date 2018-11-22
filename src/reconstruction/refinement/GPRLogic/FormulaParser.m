classdef FormulaParser < handle
    % A FormulaParser is used to parse logic formulas in the format
    % specified for the COBRA Toolbox tules field (i.e. logical formulas
    % using | and & as OR and AND symbols and x\([0-9]+\)  as a regexp
    % matching all literals.
    % 
    % .. Authors
    %     - Thomas Pfau 2016
    
    properties
        formulaFactory
    end
    
    methods
        function obj = FormulaParser()
        % Default FormulaParser constructor.        
        % USAGE:
        %    obj = FormulaParser()                
        %    
        % OUTPUTS:
        %    obj:    The FormulaParser Object
        %
            setupLogicNG();
            obj.formulaFactory = org.logicng.formulas.FormulaFactory();
        end
        
        function Head = parseFormula(self,formula)            
        % Parse a Formula in the COBRA rules format (as detailed above).
        % USAGE:
        %    Head = FormulaParser.parseFormula(formula)                
        %    
        % INPUTS:
        %    formula:   A String of a GPR formula in rules format ( &/| as
        %               operators, x(1) as literal symbols
        %
        % OUTPUTS:
        %    Head:       The Head of a Tree representing the formula
        %  
        form = self.formulaFactory.parse(regexprep(formula,'x\(([0-9]+)\)','$1'));
        Head =Node();
        Head.formula = form;
        end
                        
       
    end
    
end

