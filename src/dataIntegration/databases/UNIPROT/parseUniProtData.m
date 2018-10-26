function uniprotData = parseUniProtData(inputStruct, varargin)
% Download the uniprot data for a specific organism
% By default, only the following data will be downloaded:
% Entry, Protein Name, Gene Names, EC Number, Sequence
% Other fields are not yet implemented.
% USAGE:
%    uniprotData = parseUniProtData(inputStruct, varargin)
% 
% INPUTS:
%    inputStruct:       The Uniprot result structure.
%    varargin:          Fields and function names for additional fields to
%                       parse (e.g. 'SubUnits',str2func(parseComponents));
%                       The function needs to work on the basic struct
%                       returned by uniprot, and return a structural array
%                       that will be assigned to the given field name
%                       (which must be valid)
% OUTPUT:
%    uniprotStruct:     a struct containing data from the Uniprot Database.
%                       basic fields are: 
%                        * EC - The EC number
%                        * Entry - The Accession number
%                        * Sequence - The Sequence
%                        * Genes - The Associated Genes
%                        * Proteins - The associated proteins (recommended Name is the first element, if available)
%                        

uniprotData = struct('Entry',inputStruct.accession,'Proteins','','Genes','','EC','','Sequence',char(inputStruct.sequence.sequence));
if isfield(inputStruct.protein,'recommendedName') && isfield(inputStruct.protein.recommendedName,'ecNumber')
    uniprotData.EC = char(inputStruct.protein.recommendedName.ecNumber.value);    
end
% handle the genes.
genes = {};
if isfield(inputStruct,'gene') 
    % if they have a name, add it
    if isfield(inputStruct.gene,'name')    
        genes = {char(inputStruct.gene.name.value)};
    end
    % also add the synonyms
    if isfield(inputStruct.gene,'synonyms')    
        synonyms = cellfun(@char, {inputStruct.gene.synonyms.value},'Uniform',false);
        genes = [genes, synonyms];
    end
    % and potential open reading frame names
    if isfield(inputStruct.gene,'orfNames')    
        synonyms = cellfun(@char, {inputStruct.gene.orfNames.value},'Uniform',false);
        genes = [genes, synonyms];
    end        
end
uniprotData.Genes = genes;
proteins = {};
% set the protein name data.
if isfield(inputStruct.protein,'recommendedName')
    % first the recommended Name
    if isfield(inputStruct.protein.recommendedName,'fullName')
        proteins = {char(inputStruct.protein.recommendedName.fullName.value)};
    end
    % or any alternative names
    if isfield(inputStruct.protein,'alternativeName') 
        try
            cdata = inputStruct.protein.alternativeName;
            if ~iscell(cdata)
                cdata =  mat2cell(cdata,ones(numel(cdata),1),1)';    
            end        
            altNames = cellfun(@parseAltNames,cdata,'Uniform',0);
            proteins = [proteins , [altNames{:}]];        
        catch ME
            keyboard
        end
    end    
end
% then potential submitted names
if isfield(inputStruct.protein,'submittedName')
    proteins = [proteins, cellfun(@(x) char(x.value),{inputStruct.protein.submittedName.fullName},'Uniform',0)];
end
uniprotData.Proteins = proteins;

%subs = struct('name','','short','');
%if isfield(inputStruct.protein,'component')
%    subs = cellfun(@parseComponents, inputStruct);
%end
%uniprotData.Subunits = subs;

for i=1:2:numel(varargin)    
    uniprotData.(varargin{i}) = varargin{i+1}(inputStruct);
end
end

function altNames = parseAltNames(inputStruct)

altNames = {char(inputStruct.fullName.value)};
if isfield(inputStruct,'shortName')
    altNames = [altNames , cellfun(@char, {inputStruct.shortName.value},'Uniform',false)];
end
end

