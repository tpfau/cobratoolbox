classdef (HandleCompatible) Node < handle & matlab.mixin.Heterogeneous
    % Node are an Abstract class that handles different types of logical Nodes
    % for a tree representation of a logical formula.
    %
    % .. Authors Thomas Pfau 2016
    properties
        formula
    end
    methods(Static)
          function literals = getLiteralsFromCollection(collection)
            % Get the literals from a collection of logicNG literals.
            % USAGE:
            %    literals = getLiteralsFromCollection(collection)
            %
            % INPUT:
            %    collection:    The collection returned by formula.literals
            %
            % OUTPUTS:
            %    literals:      A cell array of all literals present in the tree under this node
            %
                        
            literals = zeros(collection.size(),1);                        
            index = 1;
            iter = collection.iterator();
            while iter.hasNext()
                literals(index) = str2num(char(iter.next().toString()));
                index = index + 1;
            end            
          end  
    end
          
    methods
        function tf = evaluate(self,assignment,printLevel)
        % evaluate the node with the current GPR assignment
        % USAGE:
        %    res = Node.evaluate(assignment)
        %
        % INPUTS:
        %    assignment:    a containers.Map of the assignment of
        %                   true/false values for each literal. The
        %                   literals are assumed to be the string numbers from the
        %                   parsed formula.
        %
        % OPTIONAL INPUTS:
        %
        %    printLevel:    whether to print out result for individual
        %                   nodes (default 0)
        %
        % OUTPUTS:
        %    tf:           The evaluation of the Node (true or false)
        %
        if ~exist('printLevel','var')
            printLevel = 0;
        end
        assignedLiterals = assignment.keys();
        assign = org.logicng.datastructures.Assignment();
        for i = 1:numel(assignedLiterals)
            cLiteral = assignedLiterals{i};
            lit = self.formula.factory.literal(cLiteral,assignment(cLiteral));
            assign.addLiteral(lit);
        end
        tf = self.formula.evaluate(assign);        
        end
        
        
        function res = toString(self,PipeAnd)
        % print the Node to a string
        % USAGE:
        %    res = Node.toString()
        %
        % OPTIONAL INPUTS:
        %    PipeAnd:       Whether to use | as the symbol for OR and & as
        %                   the symbol for AND. (default false)
        %
        % OUTPUTS:
        %    res:           The String representation of the GPR-Node
        %
        if ~exist('PipeAnd','var')
            PipeAnd = false;
        end
        res = char(self.formula.toString());
        if ~PipeAnd
            res = strrep(res,'&', 'and');
            res = strrep(res,'|', 'or');
        end
        res = regexprep(res,'([0-9]+)','x($1)');        
        % if this is now either true, or false, this indicates it is an
        % empty formula, so we return an empty string.
        if strfind(res,'$')
            res = '';
        end
        
        end
        
        function dnfNode = convertToDNF(self)
        % Convert to a DNF Node.
        % USAGE:
        %    dnfNode = Node.convertToDNF()
        %
        % OUTPUTS:
        %    res:           A Node in DNF form (i.e. and clauses separated
        %                   by or )
        %  
            QMConverter = org.logicng.transformations.qmc.QuineMcCluskeyAlgorithm();
            dnfNode = self.copy();            
            dnfNode.formula = QMConverter.compute(dnfNode.formula);            
        end
        
        
        function cnfNode = convertToCNF(self)
        % Convert to a minimal CNF Node.
        % USAGE:
        %    dnfNode = Node.convertToCNF()
        %
        % OUTPUTS:
        %    res:           A Node in CNF form (i.e. and or-clauses separated
        %                   by and )
        %
            cnfNode = self.copy();
            cnfNode.formula = cnfNode.formula.cnf();   
            %Now, we have to reduce this formula....
             if ~isa(cnfNode.formula,'org.logicng.formulas.Literal')
                % in this case there would be nothing to do, so we don't do anything.                            
                setSize = cnfNode.formula.numberOfOperands(); % This is the number of elements                                
                setSizes = zeros(setSize,1);
                setsToCheck = cell(setSize,1);
                minSize = inf;
                maxSize = 0;
                i = 1;
                iter = cnfNode.formula.iterator();
                while iter.hasNext
                    collection = iter.next().literals();
                    pos = Node.getLiteralsFromCollection(collection);
                    setsToCheck{i} = pos;
                    setSizes(i) = numel(pos);
                    minSize = min([minSize,setSizes(i)]);
                    maxSize = max([maxSize,setSizes(i)]);
                    i = i+1;
                end
                % now, this will be computationally expensive
                % all minimal Sets are automatically added.
                cSets = setSizes == minSize;
                newSets = setsToCheck(cSets);
                setsToCheck(cSets) = [];
                setSizes(cSets) = [];
                for i = minSize+1:maxSize
                    % we go over all set sizes
                    cSets = setSizes == i;
                    currentSets = setsToCheck(cSets);
                    setsToKeep = true(sum(cSets),1);
                    % remove the current sets from the checkup.
                    setsToCheck(cSets) = [];
                    setSizes(cSets) = [];
                    for l = 1:numel(currentSets)
                        % Check all sets of that size
                        setToCheck = currentSets{l};
                        for j = 1:numel(newSets)
                            % against all sets that should be in the new
                            % formula
                            compSet = newSets{j};
                            newSetSize = numel(compSet);
                            cresult = false(newSetSize,1);                        
                            for k = 1:newSetSize
                                % and look over all elements whether we can
                                % find them.
                                % this formulation is more efficient than
                                % ismember or use of any.
                                for m = 1:numel(setToCheck)
                                    if compSet(k) == setToCheck(m)
                                        cresult(k) = true;
                                        break;
                                    end
                                end
                            end
                            if all(cresult)
                                setsToKeep(l) = false;
                                % Stop lookup, if there is one, than we can
                                % skip it.
                                break;
                            end
                        end
                    end
                    % now, clean up
                    if any(setsToKeep)
                        newSets = [newSets;currentSets(setsToKeep)];
                    end
                end
                newFormula = strjoin(cellfun(@(x) ['(' strjoin(x,' | ') ')'], cellfun(@(y) arrayfun(@num2str, y, 'uniform', 0),newSets,'Uniform', 0),'Uniform',0),' & ');
                cnfNode.formula = cnfNode.formula.factory.parse(newFormula);
            end
        end
        
        
        function reduce(self)
        % DEPRACATED. Nothing to do as this happens automatically
        % value non literal subnodes.
        % USAGE:
        %    Node.reduce()
        %
        % OUTPUTS:
        %    Node:    The Node is modified in this process.
        %
        end
        
        function tf = deleteLiteral(self,literalID, keepClauses)
        % Delete a literal from this Node and all children
        % USAGE:
        %    newHead = node.deleteLiteral(literalID)
        % 
        % INPUT:
        %    literalID: The LiteralID (As string or number)
        %
        % OPTIONAL INPUT:
        %    keepClauses:    Whether to retain AND nodes in which the
        %                    literal occurs (default: true)
        %        
        % NOTE:
        %    The Node will no longer contain the corresponding literal
        %
        
        if ~exist('keepClauses','var')
            keepClauses = true;
        end
        
        if isnumeric(literalID)
           literalID = num2str(literalID);
        end
        tf = true;
        ffac = self.formula.factory();
        formulastring = char(self.formula.toString());
        if keepClauses
            % remove in and rules
            newFormula = regexprep(formulastring,['(& ' literalID ')|(' literalID ' &)'],'');
            % remove from or rules
            newFormula = regexprep(newFormula,['(\| ' literalID ')|(' literalID ' \|)'],'');
        else
            %remove and rules
            lit = ffac.literal(literalID,false);
            assign = org.logicng.datastructures.Assignment();
            assign.addLiteral(lit);
            newFormula = self.formula.restrict(assign).toString();            
        end
        ffac = self.formula.factory();
        self.formula = ffac.parse(newFormula);
        end

    
        function obj = Node()
            % Default Node constructor.
            % USAGE:
            %    obj = Node()
            %
            % OUTPUTS:
            %    obj:    The Node Object
            %            
        end                            
        
        function nodeCopy = copy(self)            
            fp = FormulaParser();
            nodeCopy = fp.parseFormula(self.toString(true));
        end
                       
        function res = contains(self,literal)
            % Check whether the given literal is part of this node.
            % USAGE:
            %    res = Node.contains(literal)
            %
            % INPUTS:
            %    literal:   The literal to look up (a string representation of
            %               a number from a rule
            %
            % OUTPUTS:
            %    res:       Whether the literal is present in the tree starting
            %               at this node.
            %
            res = self.formula.containsVariable(literal);
        end
        
        function literals = getLiterals(self)
            % Get the set of literals present in the tree below this node.
            % USAGE:
            %    literals = Node.getLiterals()
            %
            % OUTPUTS:
            %    literals:   A cell array of all literals present in the tree under this node
            %
            
            collection = self.formula.literals;
            literals = Node.getLiteralsFromCollection(collection);        
        end           
        
        function tf = isDNF(self)
        % Check, whether this is a DNF node (i.e.)
        % i.e. it is either a literal node, or an or node which only has 
        % children which are and nodes (with only literal children), or
        % literal nodes. Or an AND node with only literal children
        % USAGE:
        %    tf = Node.isDNF()
        %
        % OUTPUTS:
        %    tf:           Whether this node is a DNF node or not.        
        %                
            dnfpred = org.logicng.predicates.DNFPredicate;
            tf = dnfpred.test(self.formula);        
        end
        
        function [geneSets,genePos] = getFunctionalGeneSets(self, geneNames, getCNFSets)
            % Get all functional gene sets useable for this node
            % USAGE:
            %    geneSets = Node.getFunctionalGeneSets(geneNames)
            %
            % INPUTS:
            %    geneNames:   the genes in the order represented by the
            %                 literals (which represent positions)
            %
            % OPTIONAL INPUT:
            %    getCNFSets:    Get the CNF sets from this node instead of the DNF sets.
            %                   (i.e. get the or clauses instead of the
            %                   protein representing and clauses)
            %                   (Default: false)
            %
            % OUTPUTS:
            %    geneSets:    A cell array of gene Combinations that would make this node active
            %
            %    genePos:     A set of positions (according to the parsed
            %                 Rules) of genes that would make this tree
            %                 evaluate to true.
            %
            if ~exist('getCNFSets','var')
                getCNFSets = false;
            end
            if getCNFSets                
                NodeToCheck = self.convertToCNF();
            else
                NodeToCheck = self.convertToDNF();
            end
            
            if isa(NodeToCheck.formula,'org.logicng.formulas.Literal')
                geneSets = cell(1,1);
                genePos = cell(1,1);
                pos = str2double(char(NodeToCheck.formula.toString()));                
                genePos{1} = pos;
                geneSets{1} = geneNames(sort(pos));
            else
                setSize = NodeToCheck.formula.numberOfOperands(); % This is the number of elements
                                
                geneSets = cell(setSize,1);
                genePos = cell(setSize,1);
                iter = NodeToCheck.formula.iterator();
                i = 1;
                while iter.hasNext
                    collection = iter.next().literals();
                    pos = getLiteralsFromCollection(collection);
                    genePos{i} = pos;
                    geneSets{i} = geneNames(sort(pos));
                    i = i+1;
                end
            end
        end                
        
        function deleteLiterals(self, literals, keepClauses)
        % Remove all duplicate literal nodes in this node.
        % USAGE:
        %    node.removeLiterals(literals, keepClauses)
        % INPUTS:
        %    literals:       The literals to remove
        %    keepClauses:    Whether to retain AND nodes in which
        %                    any of the lietrals are nested.        
        for i = 1:numel(literals)
            self.deleteLiteral(literals(i),keepClauses);
        end
        end
        
        function tf = isequal(self,otherNode)
            % Get all functional gene sets useable for this node
            % USAGE:
            %    tf = Node.isequal(otherNode)
            %
            % INPUTS:
            %    otherNode:   The node to compare this node with            
            %
            % OUTPUTS:
            %    tf:          true, if this node is equal to the other
            %                 node, i.e. it represents the same boolean truth table.
            %
            tf = self.formula.equals(otherNode.formula);
            
        end
    end
end
