classdef (HandleCompatible) OrNode < Node
    % OrNode is a class that represents OR connections in a logical formula
    % For further documentation please have a look at the Node Class.
    % .. Authors
    %     - Thomas Pfau 2016
    
    properties
    end
    
    methods    

        function res = evaluate(self,assignment, printLevel)
            if ~exist('printLevel','var')
                printLevel = 0;
            end
            res = false;
            for i=1:numel(self.children)
                child = self.children{i};
                if child.evaluate(assignment,printLevel)
                    res = true;
                    break;
                end
            end
            if printLevel >= 1
                fprintf('%s : %i\n',self.toString(),res);
            end
        end
        
        
        function cnfNode = convertToCNF(self)
            cnfNode = AndNode();
            for c=1:numel(self.children)
                child = self.children{c};
                CNFChild = child.convertToCNF();
                cnfNode = combineChildren(cnfNode,CNFChild);
                %If the child is again an or node, we need to add all
                %children of that child directly to this node.                
            end
        end
        
        function dnfNode = convertToDNF(self)
            dnfNode = OrNode();
            fprintf('OrNode: The original node is %s\n',self.toString());
            for c=1:numel(self.children)
                child = self.children{c};
                fprintf('OrNode: Converting Child %s\n',child.toString());
                %If the child is again an or node, we need to add all
                %children of that child directly to this node.
                if isa(child,'OrNode')
                    DNFChild = child.convertToDNF(); 
                    fprintf('OrNode: Adding Children of %s\n',DNFChild.toString());                       
                    for cc = 1:numel(DNFChild.children)                        
                        dnfNode.addChild(DNFChild.children{cc})
                    end
                    fprintf('OrNode: After Addition dnfNode is: %s\n',dnfNode.toString());                       
                else
                    dnfNode.addChild(child.convertToDNF());
                    fprintf('OrNode: After Addition dnfNode is: %s\n',dnfNode.toString());                       
                end
            end            
            fprintf('OrNode: All Added; dnfNode is: %s\n',dnfNode.toString());                       
            %finally, remove all duplicate literal nodes from this node.
            for c = 1:numel(dnfNode.children)
                literals = {};                
                childNode = dnfNode.children{c};
                fprintf('OrNode: Checking Node %s\n',childNode.toString());                       
                childrenToRemove = false(numel(childNode.children),1);
                for i = 1 : numel(childNode.children)                  
                    cchild = childNode.children{i};
                    fprintf('OrNode: Checking %s\n',cchild.toString());                       
                    if isa(childNode.children{i},'LiteralNode')                                                
                        fprintf('OrNode: %s is a literal\n',cchild.toString());                       
                        if ~any(~cellfun(@isempty, strfind(literals,cchild.toString())))
                            literals{end+1} = cchild.toString();
                        else
                            fprintf(['OrNode: Removing child ', cchild.toString(), ' since its already present in:\n'])
                            disp(literals)
                            childrenToRemove(i) = true
                        end
                    end
                end                
                childNode.children = childNode.children(~childrenToRemove);
                disp(['OrNode: After Removal dnfNode is : ', dnfNode.toString()])
            end            
        end
        
        
        
        function removeDNFduplicates(self)
            % Assuming this is a DNF head node, removeDNFDuplicates checks
            % all present AND nodes for equality and removes replicates.
            %
            % USAGE:
            %    Node.removeDNFduplicates()
            %
            % OUTPUTS:
            %    Node:    A OrNode with all duplicate And nodes removed.
            %
            i = 1;
            literals = self.getLiterals();
            literals = unique(literals);
            comps = false(numel(self.children),numel(literals));
            for i = 1:numel(self.children)
              cchild = self.children{i};
                comps(i,:) = ismember(literals,cchild.getLiterals());
            end
            [~,select] = unique(comps,'rows');
            self.children = self.children(select);
        end
        
        function res = toString(self,PipeAnd)
            if nargin < 2
                PipeAnd = 0;
            end
            res = '(';
            cstring = '';
            for i=1:numel(self.children)
                child = self.children{i};
                if PipeAnd
                    cstring = [cstring child.toString(PipeAnd) ' | '];
                else
                    cstring = [cstring child.toString(PipeAnd) ' or '];
                end
            end
            if length(cstring) > 1
                if PipeAnd
                    cstring = cstring(1:end-3);
                else
                    cstring = cstring(1:end-4);
                end
            end
            if ~isempty(cstring)
                res = [res cstring ')'];
            else
                res = '';
            end
        end
        
        function tf = deleteLiteral(self, literalID, keepClauses)
            tf = true;            
            if ~exist('keepClauses','var')
                keepClauses = true;
            end
            if ~keepClauses
                % we need to be careful about the nesting
                self.reduce();
            end
            % delete the literals from all non Literal children
            cellfun(@(x) ~isa(x,'LiteralNode') && x.deleteLiteral(literalID, keepClauses), self.children);
            % now, look for children which are empty, or only contain one
            % element
            toDelete = cellfun(@(x) (isa(x, 'LiteralNode') && x.contains(literalID) ) || (~isa(x,'LiteralNode') && numel(x.children) <= 1), self.children);
            % and check for one element entries
            mergeChildren = cellfun(@(x) ~isa(x,'LiteralNode') && numel(x.children) == 1, self.children);            
            if any(mergeChildren)
                childsToMerge = self.children(mergeChildren);
                childrenToAdd = {};
                for i = 1:numel(childsToMerge)
                    cchild = childsToMerge{i};
                    childrenToAdd(i) = cchild.children;
                end
                % the following works only on 2017b or newer, but is more
                % efficient.
                % childrenToAdd = arrayfun(@(x) x.children, self.children(mergeChildren));
            end            
            self.children(toDelete) = [];
            if exist('childrenToAdd','var')
                for child = 1:numel(childrenToAdd)
                    newChild = childrenToAdd{child};
                    self.children{end+1} = newChild;
                    newChild.parent = self;
                end
            end
            %  fprintf('Removing Literal %s from the following node:\n%s\nLeads to the node:\n%s\n',literalID,originalNodeString,self.toString(1));
        end
        
        function reduce(self)
            childrenChanged = false;
            mergeNode.children = {};
            for i = 1:numel(self.children)
                cchild = self.children{i};
                cchild.reduce();
                %Check if the child has exactly one child. I
                if numel(cchild.children) == 1
                    %If there is only one child, we can directly add the
                    %child to this node.
                    if isempty(mergeNode.children)
                        mergeNode.children = cchild.children;
                    else
                        mergeNode.children(end+1:end+numel(cchild.children)) = cchild.children;
                    end                    
                    childrenChanged = true;
                elseif isa(cchild,'OrNode')
                    %If its an OR node, we can directly add all children to
                    %this node.
                    if isempty(mergeNode.children)
                        mergeNode.children = cchild.children;
                    else
                        mergeNode.children(end+1:end+numel(cchild.children)) = cchild.children;
                    end                    
                    childrenChanged = true;
                else
                    if isempty(mergeNode.children)
                        mergeNode.children = {cchild};
                    else                        
                        mergeNode.children{end+1} = cchild;
                    end
                end
            end       
            if childrenChanged
                
                self.children = mergeNode.children;
                for i = 1:numel(self.children)
                    cchild = self.children{i};
                    cchild.parent = self;
                end
            end
        end
        
        
    end
    
end

