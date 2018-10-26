function retrieveBRENDA(folderName)


persistent lastStart;
persistent lastField;

if isempty(lastStart)
    lastStart = 1;
    lastField = 1;
end


CBT_Folder = fileparts(which('initCobraToolbox.m'));

if ~exist('folderName','var')
    folderName = [CBT_Folder filesep 'Databases' filesep 'BRENDA'];
end

if ~exist(folderName,'file')
    mkdir(folderName)
end

bclient = BrendaClient();

fields = {'KM','MW','PATH','SA','KCAT'};

for lastField = lastField:numel(fields)
    switch fields{lastField}
        case 'KM'
            ECs = bclient.getEcNumbersFromKmValue();            
        case 'MW'
            ECs = bclient.getEcNumbersFromMolecularWeight();
        case 'PATH'
            ECs = bclient.getEcNumbersFromPathway();
        case 'SEQ'
            ECs = bclient.getEcNumbersFromSequence();
        case 'SA'
            ECs = bclient.getEcNumbersFromSpecificActivity();
        case 'KCAT'
            ECs = bclient.getEcNumbersFromTurnoverNumber();
    end
    % go through all unprocessed values
    for lastStart = lastStart:numel(ECs)
       fileName = ['EC' ECs{lastStart} '_' fields{lastField}];
       data = struct();
       switch fields{lastField}
        case 'KM'
            data = bclient.getKmValue('ecNumber', ECs{lastStart});            
        case 'MW'
            data = bclient.getMolecularWeight('ecNumber', ECs{lastStart});
        case 'PATH'
            data = bclient.getPathway('ecNumber', ECs{lastStart});
        case 'SEQ'
            data = bclient.getSequence('ecNumber', ECs{lastStart});
        case 'SA'
            data = bclient.getSpecificActivity('ecNumber', ECs{lastStart});
        case 'KCAT'
            data = bclient.getTurnoverNumber('ecNumber', ECs{lastStart});
       end 
       save([folderName filesep fileName],'data');
    end    
    % reset lastStart
    lastStart = 1;    
end
    