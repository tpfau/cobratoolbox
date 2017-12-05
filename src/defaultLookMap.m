function newmap = defaultLookMap(map)

% Give default look to structures on map in terms of color, size and width.
%
% USAGE:
%
%   newmap = defaultLookMap(map);
%
%   INPUTS:
%
%   map:        Map from CD parsed to matlab format
%
% OUTPUT:
%
%   newmap:     Matlab structure of new map with default look
%
% NOTE:
%
%   Note that this is specific to MitoMap and Recon3Map, as it uses Recon3
%   and PDmap nomenclature for metabolites
%
% .. Authors:
% .. A.Danielsdottir 01/08/2017 LCSB. Belval. Luxembourg
% .. N.Sompairac - Institut Curie, Paris, 01/08/2017.

    newmap = map;
    Colors = createColorsMap;

    % Set all rxn lines to black and normal width
    color = 'BLACK';
    width = 1.0;
    
    for j = 1:length(newmap.rxnName)
        newmap.rxnColor{j} = Colors(color);
        newmap.rxnWidth{j} = width;
    end

    % Use the existence of reactant lines to check if the map has the
    % complete structure, and if so change also secondary lines.
    if any(strcmp('rxnReactantLineColor',fieldnames(map))) == 1
        for j = 1:length(newmap.rxnName)
            if ~isempty(newmap.rxnReactantLineColor{j})
                for k = 1:length(map.rxnReactantLineColor{j})
                    newmap.rxnReactantLineColor{j,1}{k,1} = Colors(color);
                    newmap.rxnReactantLineWidth{j,1}{k,1} = width;
                end
            end
            if ~isempty(newmap.rxnProductLineColor{j})
                for m = 1:1:length(newmap.rxnProductLineColor{j})
                    newmap.rxnProductLineColor{j,1}{m,1} = Colors(color);
                    newmap.rxnProductLineWidth{j,1}{m,1} = width;
                end
            end
        end
    end

    % Start with giving all simple molecules the CD default color and size
    SM_ID = newmap.specID(ismember(newmap.specType,'SIMPLE_MOLECULE'));
    SM_Alias = find(ismember(newmap.molID,SM_ID));
    
    for i = SM_Alias'
        newmap.molColor{i} = 'ffccff66';
        newmap.molWidth{i} = '70';
        newmap.molHeight{i} = '25';
    end
    % Use the existence of reactant lines to check if the map has the
    % complete structure, and if so change also included species.
    if any(strcmp('rxnReactantLineColor',fieldnames(map))) == 1
        SMInc_ID = newmap.specIncID(ismember(newmap.specIncType,'SIMPLE_MOLECULE'));
        SMInc_Alias = find(ismember(newmap.molID,SMInc_ID));
            for i = SMInc_Alias'
                newmap.molColor{i} = 'ffccff66';
                newmap.molWidth{i} = '70';
                newmap.molHeight{i} = '25';
            end
    end

    % Identify the metabolites that should be considered "secondary
    % metabolites"
    % Groups of metabolites as chosen during drawing of Recon3map
    Mets{1} = {'^atp\[\w\]';'^adp\[\w\]';'^amp\[\w\]';'^utp\[\w\]';'^udp\[\w\]';'^ump\[\w\]';'^ctp\[\w\]';'^cdp\[\w\]';'^cmp\[\w\]';'^gtp\[\w\]';'^gdp\[\w\]';'^gmp\[\w\]';'^imp\[\w\]';'^idp\[\w\]';'^itp\[\w\]';'^dgtp\[\w\]';'^dgdp\[\w\]';'^dgmp\[\w\]';'^datp\[\w\]';'^dadp\[\w\]';'^damp\[\w\]';'^dctp\[\w\]';'^dcdp\[\w\]';'^dcmp\[\w\]';'^dutp\[\w\]';'^dudp\[\w\]';'^dump\[\w\]';'^dttp\[\w\]';'^dtdp\[\w\]';'^dtmp\[\w\]';'^pppi\[\w\]';'^ppi\[\w\]';'^pi\[\w\]'};
    Mets{2} = {'^h2o\[\w\]'};
    Mets{3} = {'^h\[\w\]'};
    Mets{4} = {'^nadp\[\w\]';'^nadph\[\w\]';'^nad\[\w\]';'^nadh\[\w\]';'^fad\[\w\]';'^fadh2\[\w\]';'^fmn\[\w\]';'^fmnh2\[\w\]';'FAD';'FADH2';'NAD(_plus_)';'NADH'};
    % Also with PDmap nomenclature, for full version of MitoMap, as these
    % are sometimes included in complexes.
    Mets{5} = {'^coa\[\w\]'};
    Mets{6} = {'^h2o2\[\w\]';'^o2\[\w\]';'^co2\[\w\]';'^co\[\w\]';'^no\[\w\]';'^no2\[\w\]';'^o2s\[\w\]';'^oh1\[\w\]'};
    Mets{7} = {'^na1\[\w\]';'^nh4\[\w\]';'^hco3\[\w\]';'^h2co3\[\w\]';'^so4\[\w\]';'^so3\[\w\]';'^cl\[\w\]';'^k\[\w\]';'^ca2\[\w\]';'^fe2\[\w\]';'^fe3\[\w\]';'^i\[\w\]';'^zn2\[\w\]';'Ca2_plus_';'Cl_minus_';'Co2_plus_';'Fe2_plus_';'Fe3_plus_';'H_plus_';'K_plus_';'Mg2_plus_';'Mn2_plus_';'Na_plus_';'Ni2_plus_';'Zn2_plus_'};
    % Also added are names of ions in PD map, for full version of MitoMap,
    % as ions are sometimes included in complexes

    % Carnitine to be reviewed later, if it should be visualized differently
    % from "general" metabolites or not (01082017)
    Mets{8} = {'^crn\[\w\]'};

    % Choose seperate color for each metabolite group. Avoid using bright red,
    % as that is default color for highlighting fluxes and moieties.
    Color{1} = 'fff0adbb'; %faded red/pink ;
    Color{2} = 'ff79adf5'; %blue
    Color{3} = 'ffb993ec'; %purple
    Color{4} = 'ff06f7e1'; %light blue
    Color{5} = 'fff0a10e'; %orange
    Color{6} = 'ff61f81b'; %green
    Color{7} = 'fff5f81b'; %yellow
    Color{8} = 'ff99edc5'; %sea green

    for i = 1:8
        list = Mets{i}; 
        %find species ID for each metabolite in a group
        index = [];
        for h = list'
           j = find(~cellfun(@isempty,regexp(newmap.specName,h)));
           index = [index;j];
        end
        specID = newmap.specID(index);
        % Find index of all aliases of each species
        index2 = find(ismember(newmap.molID,specID));
        % Change color and size (same size for all metabolite groups, smaller than "main metabolites")
        for k = index2'
           newmap.molColor{k} = Color{i}; 
           newmap.molWidth{k} = '50.0';
           newmap.molHeight{k} = '20.0';
        end
        % If complete structure is used, also change for included species
        if any(strcmp('rxnReactantLineColor',fieldnames(map))) == 1
            index3 = [];
            for h = list'
               j = find(~cellfun(@isempty,regexp(newmap.specIncName,h)));
               index3 = [index3;j];
            end
            specIncID = newmap.specIncID(index3);
            index4 = find(ismember(newmap.molID,specIncID)); 
            for k = index4'
               newmap.molColor{k} = Color{i}; 
               newmap.molWidth{k} = '50.0';
               newmap.molHeight{k} = '20.0';
            end
        end
    end

    % Define and change species type for known "secondary" metabolites from model
    % (all ions will acquire round shape instead of oval, no matter how width and height is defined)
    ions = {'^h\[\w\]';'^na1\[\w\]';'^cl\[\w\]';'^k\[\w\]';'^ca2\[\w\]';'^fe2\[\w\]';'^fe3\[\w\]';'^i\[\w\]';'^zn2\[\w\]';'Ca2_plus_';'Cl_minus_';'Co2_plus_';'Fe2_plus_';'Fe3_plus_';'H_plus_';'K_plus_';'Mg2_plus_';'Mn2_plus_';'Na_plus_';'Ni2_plus_';'Zn2_plus_'};
    non_ions = {'^atp\[\w\]';'^adp\[\w\]';'^amp\[\w\]';'^utp\[\w\]';'^udp\[\w\]';'^ump\[\w\]';'^ctp\[\w\]';'^cdp\[\w\]';'^cmp\[\w\]';'^gtp\[\w\]';'^gdp\[\w\]';'^gmp\[\w\]';'^imp\[\w\]';'^idp\[\w\]';'^itp\[\w\]';'^dgtp\[\w\]';'^dgdp\[\w\]';'^dgmp\[\w\]';'^datp\[\w\]';'^dadp\[\w\]';'^damp\[\w\]';'^dctp\[\w\]';'^dcdp\[\w\]';'^dcmp\[\w\]';'^dutp\[\w\]';'^dudp\[\w\]';'^dump\[\w\]';'^dttp\[\w\]';'^dtdp\[\w\]';'^dtmp\[\w\]';'^pppi\[\w\]';'^ppi\[\w\]';'^pi\[\w\]';'^h2o\[\w\]';'^nadp\[\w\]';'^nadph\[\w\]';'^nad\[\w\]';'^nadh\[\w\]';'^fad\[\w\]';'^fadh2\[\w\]';'^fmn\[\w\]';'^fmnh2\[\w\]';'^coa\[\w\]';'^h2o2\[\w\]';'^o2\[\w\]';'^co2\[\w\]';'^co\[\w\]';'^no\[\w\]';'^no2\[\w\]';'^o2s\[\w\]';'^oh1\[\w\]';'^nh4\[\w\]';'^hco3\[\w\]';'^h2co3\[\w\]';'^so4\[\w\]';'^so3\[\w\]';'^crn\[\w\]';'FAD';'FADH2';'NAD(_plus_)';'NADH'};
    ionindex = [];
    for i = ions'
       % Find species index for ions  
       j = find(~cellfun(@isempty,regexp(newmap.specName,i)));
       ionindex = [ionindex;j];
    end
    for j = ionindex'
        newmap.specType{j} = 'ION';
    end

    % If complete structure is used, also change for included species
    if any(strcmp('rxnReactantLineColor',fieldnames(map))) == 1
        ionIncindex = [];
        for i = ions'
           % Find species index for ions  
           m = find(~cellfun(@isempty,regexp(newmap.specIncName,i)));
           ionIncindex = [ionIncindex;m];
        end
        for m = ionIncindex'
            newmap.specType{m} = 'ION';
        end
    end

    % Give the type simple molecule, in case they were manually drawn with wrong
    % species type (this is not done for the whole species list, in case there are proteins, receptors, etc. present on map)
    ni_index = [];
    for i = non_ions'
        j = find(~cellfun(@isempty,regexp(newmap.specName,i)));
        ni_index = [ni_index;j];
    end
    for j = ni_index'
        newmap.specType{j} = 'SIMPLE_MOLECULE';
    end
    
    % If complete structure is used, also change for included species
    if any(strcmp('rxnReactantLineColor',fieldnames(map))) == 1
        niInc_index = [];
        for i = non_ions'
            m = find(~cellfun(@isempty,regexp(newmap.specIncName,i)));
            niInc_index = [niInc_index;m];
        end
        for m = niInc_index'
            newmap.specIncType{m} = 'SIMPLE_MOLECULE';
        end
    end
    
    % Give unified look to all proteins
    prot_ID = newmap.specID(ismember(newmap.specType,'PROTEIN'));
    prot_Alias = find(ismember(newmap.molID,prot_ID));    
    for i = prot_Alias'
        newmap.molColor{i} = 'ffccffcc';
        newmap.molWidth{i} = '55';
        newmap.molHeight{i} = '30';
    end
    % If complete structure is used, also change for included species
    if any(strcmp('rxnReactantLineColor',fieldnames(map))) == 1
        protInc_ID = newmap.specIncID(ismember(newmap.specIncType,'PROTEIN'));
        protInc_Alias = find(ismember(newmap.molID,protInc_ID));
        for i = protInc_Alias'
            newmap.molColor{i} = 'ffccffcc';
            newmap.molWidth{i} = '55';
            newmap.molHeight{i} = '30';
        end
    end

end