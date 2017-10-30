function sbmlModel = writeSBMLJSBML(model,fileName,compSymbolList,compNameList)
% Exports a COBRA structure into an SBML FBCv2 file. A SBMLFBCv2 file  a file is written to the current Matlab path.
%
% USAGE:
%
%    sbmlModel = writeSBML(model, fileName, compSymbolList, compNameList)
%
% INPUTS:
%    model:             COBRA model structure
%    fileName:          File name for output file
%
% OPTIONAL INPUTS:
%    compSymbolList:    List of compartment symbols
%    compNameList:      List of copmartment names corresponding to compSymbolList
%
% OUTPUT:
%    sbmlModel:         SBML MATLAB structure
%
% .. Author: - Longfei Mao 24/09/15
%            - Thomas Pfau May 2017 Updates to libsbml 5.15

import org.sbml.jsbml.Unit;
setupJSBML(); % Set up JSBML
sbmlDoc = org.sbml.jsbml.SBMLDocument(3,1);
sbmlDoc.addDeclaredNamespace('html','http://www.w3.org/1999/xhtml')
sbmlModel = sbmlDoc.createModel();


%Set unit definitions
unit_kinds = {javaMethod('valueOf','org.sbml.jsbml.Unit$Kind','MOLE'),javaMethod('valueOf','org.sbml.jsbml.Unit$Kind','GRAM'),javaMethod('valueOf','org.sbml.jsbml.Unit$Kind','SECOND')};
unit_exponents = [1 -1 -1];
unit_scales = [-3 0 0];
unit_multipliers = [1 1 1*60*60];
fluxDef = sbmlModel.createUnitDefinition();
fluxDef.setId('mmol_per_gDW_per_hr');
%Create Flux unit
for i = 1:size(unit_kinds, 2)
    unit = fluxDef.createUnit();
    unit.setExponent(unit_exponents(i));
    unit.setKind(unit_kinds{i});
    unit.setScale(unit_scales(i));
    unit.setMultiplier(unit_multipliers(i));    
end

sbmlModel.enablePackage('fbc');
fbcModel = sbmlModel.getPlugin('fbc');
fbcModel.setStrict(true);
%First, set up the Compartments
if nargin<3 || ~exist('compSymbolList','var') || isempty(compSymbolList) || ~isfield(model, 'compNames')
    if isfield(model, 'comps') && isfield(model,'compNames')
        %Don't do anything. 
    elseif isfield(model, 'comps') && ~isfield(model,'compNames')
        model.compNames = model.comps;
    else
        [model.comps,model.compNames] = getDefaultCompartments();
    end
else
    model.comps = compSymbolList;
    model.compNames = compNameList;
end

%For IDs which are converted to SBML IDs check whether they have the
%appropriate format:
metabolitePrefix = 'M_';

reactionPrefix = 'R_';

genePrefix = 'G_';

compPrefix = 'C_';



%% Compartments
for i = 1:numel(model.comps)
    ccomp = sbmlModel.createCompartment();
    ccomp.setId([compPrefix, convertSBMLID(model.comps{i})]);
    ccomp.setName(model.compNames{i});
    ccomp.setConstant(true);
end


[tokens tmp_met_struct] = regexp(model.mets,'(?<met>.+)\[(?<comp>.+)\]','tokens','names'); % add the third type for parsing the string such as "M_10fthf5glu_c"
%if we have any compartment, we will use unknown as compartment ID for
%metabolites without compartment.
if any(cellfun(@isempty, tmp_met_struct))
    unknownComp = 'u';
else
    unknownComp = 'c';
end

%Convert all Metabolite IDs.
model.mets = strcat(metabolitePrefix,  convertSBMLID(model.mets));
tic
for i=1:size(model.mets, 1)
    cspecies = sbmlModel.createSpecies();   
    cspecies.setId(model.mets{i});    
    cspecies.setMetaId(model.mets{i});
    %Some default settings
    cspecies.setHasOnlySubstanceUnits(true);    
    cspecies.setBoundaryCondition(false);
    cspecies.setConstant(false);
    cspecies.setInitialAmount(1); %Everything is present (at least thats the assumption)
    cspecies.setSubstanceUnits(javaMethod('valueOf','org.sbml.jsbml.Unit$Kind','MOLE'));
    fbcSpecies = cspecies.getPlugin('fbc');
    if isfield(model, 'metNames')
        cspecies.setName(model.metNames{i});
    end
    
    if isfield(model, 'metFormulas')
        fbcSpecies.setChemicalFormula(model.metFormulas{i});        
    end
    
    if isfield(model, 'metCharges')
        if ~isnan(model.metCharges(i))
            fbcSpecies.setCharge(model.metCharges(i));
        end
    end
    
    if isfield(model,'metSBOTerms')
        if ~isempty(model.metSBOTerms{i})
            cspecies.setSBOTerm(str2num(regexprep(model.metSBOTerms{i},'^SBO:0*([1-9][0-9]*)$','$1')));            
        end
    end
    %% here notes can be formulated to include more annotations.    
    try
        cspecies.setCompartment(strcat(compPrefix,convertSBMLID(tmp_met_struct{i}.comp)));        
    catch   % if no compartment symbol is found in the metabolite names
        cspecies.setCompartment(strcat(compPrefix,convertSBMLID(unknownComp)));        
    end
    %% Add annotations for metaoblites to the reconstruction       
    tmp_note = '';
    if isfield(model,'metNotes')
        %Lets test whether the field is correctly formatted
        COBRA_STYLE_NOTE_FIELDS = strsplit(model.metNotes{i},'\n');
        for pos = 1:length(COBRA_STYLE_NOTE_FIELDS)
            current = COBRA_STYLE_NOTE_FIELDS{pos};
            if isempty(current)
                continue;
            end
            if any(strfind(current,':'))
                %If it has a title, we use that one, otherwise its just a
                %note.
                tmp_note = [ tmp_note ' <html:p>' current '</html:p>'];
            else
                tmp_note = [ tmp_note ' <html:p>NOTES: ' current '</html:p>'];
            end
        end
    end
    if ~isempty(tmp_note)        
        %tmp_note = ['<body xmlns="http://www.w3.org/1999/xhtml">' tmp_note '</body>'];
        cspecies.setNotes(tmp_note);    
        fprintf('Metabolite %i has note %s\n',i,tmp_note);
    end
    setJSBMLAnnotation(cspecies,model,'met',i);
end
fprintf('Metabolites set up\n');
toc

%% Genes

GeneProductAnnotations = {'gene',{'isEncodedBy','encoder'},'protein',{}};

if isfield(model,'genes')
    for i=1:length(model.genes)
        cGeneProduct = fbcModel.createGeneProduct();
        cGeneProduct.setId(strcat(genePrefix, convertSBMLID(model.genes{i})));
        cGeneProduct.setMetaId(cGeneProduct.getId());        
        if isfield(model,'geneNames')
            cGeneProduct.setLabel(model.geneNames{i});
        else
            cGeneProduct.setLabel(model.genes{i});
        end
        
        if isfield(model,'proteins')
            cGeneProduct.setName(model.proteins{i});            
        end        
        setJSBMLAnnotation(cGeneProduct,model,GeneProductAnnotations,i)
    end
end

fprintf('Genes set up\n');
toc
%% Reaction

% % % % % % sbml_tmp_parameter.units = reaction_units;
% % % % % % sbml_tmp_parameter.isSetValue = 1;
%%%%%%%% Rxn definitions



%% Generate a list of unqiue fbc_bound names
totalValues=[model.lb; model.ub];
totalNames=cell(size(totalValues,1),1);

listUniqueValues=unique(totalValues);

for i=1:length(listUniqueValues)
    listUniqueNames{i,1}=['FB',num2str(i),'N',num2str(abs(round(listUniqueValues(i))))]; % create unique flux bound IDs.
    ind=find(ismember(totalValues,listUniqueValues(i)));
    totalNames(ind)=listUniqueNames(i,1);
end
BoundParams = cell(size(listUniqueValues));
if ~isempty(listUniqueValues)
    for i=1:length(listUniqueNames)
        cparam = sbmlModel.createParameter();
        cparam.setId(listUniqueNames{i,1});
        cparam.setValue(listUniqueValues(i));
        cparam.setConstant(true);
        cparam.setUnits(fluxDef);        
        BoundParams{i} = cparam;
    end
else
    
end
fprintf('Parameters set up\n');
toc

fbcModel = sbmlModel.getPlugin('fbc');
parser = FormulaParser();
%Set the Gene IDs
model.genes = strcat(genePrefix,convertSBMLID(model.genes));
getGeneNameForPos = @(x) model.genes{str2num(x)};
for i=1:size(model.rxns, 1)
    creaction = sbmlModel.createReaction();
    creaction.setFast(true);
    fbcReaction = creaction.getPlugin('fbc');
    creaction.setId(strcat(reactionPrefix,convertSBMLID(model.rxns{i})));
    creaction.setMetaId(creaction.getId());             
    tmp_note = '';
    if isfield(model, 'subSystems')                
        tmp_note = [ tmp_note ' <html:p>SUBSYSTEM: ' strjoin(model.subSystems{i},';') '</html:p>'];
    end
    if isfield(model, 'rxnConfidenceScores')
        if iscell(model.rxnConfidenceScores)
            %This is for old style models which provide confidence scores
            %as strings.
            tmp_note = [ tmp_note ' <html:p>Confidence Level: ' model.rxnConfidenceScores{i} '</html:p>'];
        else
            tmp_note = [ tmp_note ' <html:p>Confidence Level: ' num2str(model.rxnConfidenceScores(i)) '</html:p>'];
        end
    end
    if isfield(model, 'rxnNotes')
        %Lets test whether the field is correctly formatted
        COBRA_STYLE_NOTE_FIELDS = strsplit(model.rxnNotes{i},'\n');
        for pos = 1:length(COBRA_STYLE_NOTE_FIELDS)
            current = COBRA_STYLE_NOTE_FIELDS{pos};
            if isempty(current)
                continue;
            end
            if any(strfind(current,':'))
                %If it has a title, we use that one, otherwise its just a
                %note.
                tmp_note = [ tmp_note ' <html:p>' current '</html:p>'];
            else
                tmp_note = [ tmp_note ' <html:p>NOTES: ' current '</html:p>'];
            end
        end
    end    
    if ~isempty(tmp_note)
        %tmp_note = ['<body xmlns="http://www.w3.org/1999/xhtml">' tmp_note '</body>'];
        creaction.setNotes(tmp_note);   
    end
    if isfield(model, 'rxnNames')
        creaction.setName(model.rxnNames{i});        
    end
    
    if isfield(model,'metSBOTerms')
        if ~isempty(model.metSBOTerms{i})
            creaction.setSBOTerm(str2num(regexprep(model.metSBOTerms{i},'^SBO:0*([1-9][0-9]*)$','$1')))            
        end    
    end
    creaction.setReversible(model.lb(i) < 0);        
    %Add in the reactants and products
    met_idx = find(model.S(:, i));    
    for (j_met=1:size(met_idx,1))
        tmp_idx = met_idx(j_met,1);
        met_stoich = model.S(tmp_idx, i);
        if(met_stoich > 0)
            speciesref = creaction.createProduct();
            speciesref.setStoichiometry(met_stoich);
            speciesref.setSpecies(sbmlModel.getSpecies(met_idx(j_met)-1)); %Java, starts with 0
            speciesref.setConstant(true);
        else
            speciesref = creaction.createReactant();
            speciesref.setStoichiometry(-met_stoich);
            speciesref.setSpecies(sbmlModel.getSpecies(met_idx(j_met)-1)); %Java, starts with 0
            speciesref.setConstant(true);
        end        
    end
    %% grRules
    
    if isfield(model, 'rules') && ~isempty(model.rules{i})
        crule = model.rules{i};
        %Make the rule conforming to CobraFormulaParser
        formula = parser.parseFormula(crule);        
        GPR = fbcReaction.createGeneProductAssociation();
        GPR.setAssociation(createGeneAssociation(model,formula));
        fbcReaction.setGeneProductAssociation(GPR);
    end
    %Set the flux bounds    
    fbcReaction.setUpperFluxBound(BoundParams{ismember(listUniqueValues,model.ub(i))});
    fbcReaction.setLowerFluxBound(BoundParams{ismember(listUniqueValues,model.lb(i))});
    
    %Set the annotation
    setJSBMLAnnotation(creaction,model,'rxn',i);
            
end
fprintf('Reactions set up\n');
toc
%% geneProduct, i.e., list of genes in the SBML file, which are stored in the <fbc:listOfGeneProducts> attribute
%Set the objective sense of the FBC objective according to the osenseStr in
%the model.
objectiveSense = javaMethod('valueOf','org.sbml.jsbml.ext.fbc.Objective$Type','MAXIMIZE');

if isfield(model,'osense') && model.osense == 1
    objectiveSense = javaMethod('valueOf','org.sbml.jsbml.ext.fbc.Objective$Type','MINIMIZE');
end

%%%%% multiple objectives
if ~isnumeric(model.c)
    model.c=double(cell2mat(model.c)); % convert the variable type to double
end

%Get the objective
ind=find(model.c); % Find the index numbers for the objective reactions
% The fields of a COBRA model are converted into respective fields of a FBCv2 structure.
%Create the objective
cObjective = fbcModel.createObjective('COBRA_Objective');
cObjective.setType(objectiveSense);
if isempty(ind)    
    fluxObjective = cObjective.createFluxObjective('COBRA_Flux_Objective');
    fluxObjective.setCoefficient(0);    
else    
    for i=1:length(ind)
        cfluxObjective = cObjective.createFluxObjective();
        cfluxObjective.setReaction(sbmlModel.getReaction(ind(i)-1));
        cfluxObjective.setCoefficient(model.c(ind(i)));        
    end
end
fbcModel.setActiveObjective(cObjective);

outputFile = java.io.File(fileName);
writer = org.sbml.jsbml.SBMLWriter();
writer.write(sbmlDoc,outputFile);
end
