function model = makeGeneProteinRules(model, defaultkCat)


if ~exist('defaultkCat','var')
    defaultkCat = 1;
end

parsedRules = GPRparser(model);
proteins = ~cellfun(@isempty, cellfun(@(x) x{1}, parsedRules,'Uniform', 0));
uProtCount = 0;
uniqueProteins = cell(3*sum(proteins),1);
proteinEfficienies = sparse(numel(model.rxns),3*sum(proteins));
proteinRules = columnVector(cell(size(proteins)));


for i = 1:numel(parsedRules)    
    if proteins(i)
        proteinpos = zeros(numel(parsedRules{i}),1);
        currentProts = parsedRules{i};        
        for cProt = 1:numel(currentProts)                    
            present = false;
            for j = 1:uProtCount
                cUnique = uniqueProteins{j};
                if numel(intersect(cUnique,currentProts{cProt})) == numel(union(cUnique,currentProts{cProt}))
                    % they are equal
                    proteinpos(cProt) = j;                    
                    proteinEfficienies(i,j) = defaultkCat;
                    present = true;
                    break;
                end
            end
            if ~present                
                uProtCount = uProtCount+1;
                uniqueProteins(uProtCount) = currentProts(cProt);
                proteinpos(cProt) = uProtCount;                
                proteinEfficienies(i,uProtCount) = defaultkCat;
            end
        end
        proteinRules{i} = proteinpos;        
    end
end

model.proteins = columnVector(strcat('Protein',cellfun(@num2str, num2cell(1:uProtCount),'uni',0)));
model.proteinGenes = columnVector(uniqueProteins(1:uProtCount));
model.rxnProteinRules = proteinRules;
model.rxnProteinEfficiencies = proteinEfficienies(:,1:uProtCount);

