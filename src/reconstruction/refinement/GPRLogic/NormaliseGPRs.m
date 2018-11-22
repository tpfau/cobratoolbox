function Outmodel = NormaliseGPRs(model,geneRegExp)
% Bring all GPRS into a DNF form and reduce them to the minimal DNF Form
% USAGE:
%
%    Outmodel = NormaliseGPRs(model,geneRegExp)
%
% INPUTS:
%
%    model:       The Model to convert the GPRs
%    geneRegExp:  A Regular expression matching the genes in the model.
% 
% OUTPUTS:
%    Outmodel:    The output model with all GPRS in minimal DNF form.
%
% .. Authors:
%    - Thomas Pfau 2016

gprs = model.rules;
FP = FormulaParser();
newgprs = cell(numel(gprs),1);
newrules = cell(numel(gprs),1);
for i = 1:numel(gprs)
    if strcmp(gprs{i},'') || isempty(gprs{i})
        newgprs{i} = '';
        newrules{i} = '';
        continue
    end
    fprintf('Currently calculating GPR #%i: \n %s\n',i,gprs{i});    
    Head = FP.parseFormula(gprs{i});        
    originalLiterals = Head.getLiterals();    
    NewHead = Head.convertToDNF();    
    newrules{i} = NewHead.toString(1);
    newLiterals = NewHead.getLiterals();    
    if ~isempty(setdiff(originalLiterals,newLiterals))
        %This is IMPORTANT
        irrevgenes = setdiff(originalLiterals,newLiterals);
        warn = warning();
        warning on;
        warning('The following genes have no effect on reaction %s given the original GPR rule. They will therefore be removed from the reaction!\n%s',model.rxns{i},strjoin(model.genes(irrevgenes),'\n'));
        warning(warn);
    end
    
end
Outmodel = model;
Outmodel.rules = newrules;
if isfield(model,'grRules')
    Outmodel = creategrRulesField(Outmodel);
end

if isfield(model,'rxnGeneMat')
    Outmodel = buildRxnGeneMat(Outmodel);
end

end