function keggData = getKEGGGeneData(organismID, geneID)
% Get the data for a KEGG GENE in a struct determined by the data returned
% by: webread(['http://rest.kegg.jp/get/' organismID ':' geneID]);

% USAGE:
%    keggData = getKEGGGeneData(organismID, geneID)
%
% INPUT:
%    organismID:        The KEGG organism identifier
%    geneID:            The KEGG Gene id 
%
% OUTPUT:
%    keggData:          The data returned in a struct array with the following fields:
%                        * organism     - the organism of the returned element
%                        * entry        - the entry (for hsa:763 the id would be 763 of the element)
%                        * id:          - the Kegg ID (e.g. T01001)
%                        * definition   - The definition of the gene
%                        * name         - The abbreviation name
%                        * pathway      - a struct with id/name for each pathway the gene is in 
%                        * dblinks      - a struct with fields db/ids
%                        * aaseq        - the amino acid sequence
%
% .. Author - Thomas Pfau Oct 2018
%    

KEGGResponse = webread(['http://rest.kegg.jp/get/' organismID ':' geneID]);

KEGGLines = strsplit(KEGGResponse,'\n');
% we have to remove empy lines (mostly the last one, but just to make
% sure...
currentField = '';
keggData = struct('organism','','organismid','','entry','','id','','definition','','EC','','name','','pathway',struct('id',{},'name',{}),'dblinks',struct('db','','ids',cell(0)),'aaseq','');

for i = 1:numel(KEGGLines)
    if length(KEGGLines{i}) < 12 
        % those lines can be skipped
        continue;
    end
    lineField = strtrim(KEGGLines{i}(1:12));
    if ~isempty(lineField)
        currentField = lineField;
    end
    switch currentField
        case 'ENTRY'            
            cline = strsplit(KEGGLines{i},' ');
            keggData.entry = cline{2};
            keggData.id = cline{4};
        case 'ORGANISM'
            cline = strsplit(KEGGLines{i},' ');
            keggData.organism = cline{3};
            keggData.organismid = cline{2};
        case 'ORTHOLOGY'
            [ecstart,ecend] = regexp(KEGGLines{i},'(?<=\[EC:)[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(?=\])');
            if ~isempty(ecstart)
                keggData.EC = KEGGLines{i}(ecstart:ecend);
            end
        case 'PATHWAY'
            cline = strsplit(KEGGLines{i}(13:end),'  ');
            keggData.pathway(end+1) = struct('id',cline{1},'name',strjoin(cline(2:end),'  '));
        case 'DEFINITION'
            keggData.definition = regexprep(KEGGLines{i},'^\(RefSeq\)','');
        case 'AASEQ'
            aaseqdata = strtrim(KEGGLines{i}(13:end));
            if isempty(regexp(aaseqdata,'[0-9]+','ONCE'))
                % ignore the number
                keggData.aaseq = [keggData.aaseq , aaseqdata];
            end
        case 'DBLINKS'
            cline = strsplit(KEGGLines{i}(13:end),':');
            dbstruct = struct('db',cline{1});
            dbstruct.ids = strsplit(strtrim(strjoin(cline(2:end),':')),' ');
            keggData.dblinks(end+1) = dbstruct;            
        case 'NAME'
            cline = strsplit(KEGGLines{i},' ');            
            keggData.name = cline(2);
    end
end