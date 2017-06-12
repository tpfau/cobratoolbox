function ConstraintMap = parseConstraintData(Dataline,specialSubstrates)
% Parses metabolites into test data.
%
% USAGE:
%    ConstraintMap = parseConstraintData(Dataline,specialSubstrates)
%
% INPUTS:
%    DataLine:             A char line with etabolite names and indicators. 
%                          "-MetName" will be translated into {MetName,-1};
%                          "MetaName" or "+MetName" will be translated into
%                          {MetName, 1} and "=MetName" will be translated
%                          into {MetName, 0}
%    specialSubstrates:    - a struct containing fields for special
%                            substrates (e.g. whole Formulations of
%                            available substrates). If a metabolite in any
%                            column matches a special substrate, the
%                            respective cell arrays for that substrate will
%                            eb appended.
% OUTPUTS:
%    ConstraintMap:      A X by 2 Cell array wiith Metabolite IDs and
%                        indicators                        
%
% .. Authors: 
%    Thomas Pfau June 2017
    ConstraintMap = cell(0,2);
    %disp(Dataline)    
    entries = strsplit(Dataline,' ');
    substrateList = fieldnames(specialSubstrates);
    if ~isa(Dataline,'char')
        disp('This is not a char!!')
    end
    for i=1:numel(entries)
        directionvalue = 1;
        value = entries{i};
        if isempty(value)
            continue
        end                
        if ~isempty(find(ismember(value,substrateList)))            
            Substrate = specialSubstrates.(value);
            ConstraintMap = [ConstraintMap ; Substrate];            
            continue
        end
        if strcmp(value,'fail')
            ConstraintMap(1,1:2) = {'fail',0};
            return
        end
        %Now check whether we are pos, neg or "indiff"
        if strcmp(value(1),'-')
            directionvalue = -1;
            value = value(2:end);
        end
        if strcmp(value(1),'+')
            directionvalue = 1;
            value = value(2:end);
        end
        if strcmp(value(1),'=')
            directionvalue = 0;
            value = value(2:end);
        end
        %now lookup the correct metabolite
        ConstraintMap(end+1,1:2) = {value,directionvalue};
    end
    
end