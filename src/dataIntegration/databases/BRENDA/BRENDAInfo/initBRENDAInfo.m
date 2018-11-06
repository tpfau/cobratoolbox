function [brendaInfo] = initBRENDAInfo()
% Initialize a BRENDA Info struct 
% USAGE:
%    [brendaInfo] = initBRENDAInfo()
%
% OUTPUT:
%    brendaInfo:     A Structure Array with ECNumbers and additional
%                    brendaInfo fields.

bclient = startBRENDAClient();
% get EC numbers for all fields we store info about.
ECs.KM = bclient.getEcNumbersFromKmValue();
ECs.MW = bclient.getEcNumbersFromMolecularWeight();
ECs.PATH = bclient.getEcNumbersFromPathway();

ECs.SEQ = bclient.getEcNumbersFromSequence();
ECs.SA = bclient.getEcNumbersFromSpecificActivity();
ECs.KCAT = bclient.getEcNumbersFromTurnoverNumber();
datafields = fieldnames(ECs);
for i = 1:numel(datafields)
    cField = datafields{i};
    corrects = ~cellfun(@isempty, regexp(ECs.(cField),'^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+[A-Za-z]*$'));
    ECs.(cField) = ECs.(cField)(corrects);
end

ECNumbers = unique(horzcat(ECs.KM,ECs.MW,ECs.PATH,ECs.SEQ,ECs.SA,ECs.KCAT));
brendaInfo = columnVector(struct('ECNumber',ECNumbers,'KM',1,...
                             'MW',1,'PATH',1,...
                             'SA',1,'KCAT',1,'SEQ',1)); 
% get all elements not in the update list, these can't have the respective
% field, i.e. value of 0.

for i = 1:numel(datafields)
    cField = datafields{i};
    cECs = ECs.(cField);
    pos = ismember(ECNumbers,cECs);
    [brendaInfo(pos).(cField)] = deal(2);                             
end
