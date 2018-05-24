classdef BrendaClient < handle
    % BrendaClient is a class that offers access to the BRENDA library
    % using the BRENDA SOAP API.
    % USAGE:
    %    client = BrendaClient()
    %
    % NOTE:
    %    You need to be registered with BRENDA in order to use the client.
    %    This class offers a few convenience functions for some of the SOAP
    %    commands
    
    properties(Access=private)
        password
        userName
        brendaService
    end
    properties(Constant)
        brendaURL = 'http://www.brenda-enzymes.org/soap/brenda_server.php';
    end
    methods
        function obj = BrendaClient()
            loadAxis();
            obj.init()
        end
        
        function init(self)
            import org.apache.axis.client.*;
            import javax.xml.namespace.*;
            import java.security.*;
            import java.math.*;
            self.brendaService = Service();
            %get User Name and password
            detailscorrect = false;
            while ~detailscorrect
                if isMatlabGUI()
                    userName = impinputdlg('Please enter your BRENDA user name');
                    userName = userName{1};
                    password = impinputdlg('Please enter your BRENDA password');
                    password = password{1};
                else
                    userName = input('Please enter your BRENDA user name:');
                    userName = userName{1};
                    password = input('Please enter your BRENDA password:');
                    password = password{1};
                    
                end
                call = self.brendaService.createCall();
                md = MessageDigest.getInstance('SHA-256');
                hash = md.digest(double(password));
                bi = BigInteger(1, hash);
                password = char(java.lang.String.format('%064x', bi));
                call.setTargetEndpointAddress(java.net.URL(self.brendaURL) );
                parameters = [userName ',' lower(password) ',ecNumber*1.1.1.1#organism*Mus musculus'];
                call.setOperationName(QName('http://soapinterop.org/', 'getKmValue'));
                resultString = call.invoke( {parameters} );
                if isempty(regexp(resultString,'Authentication required'))
                    self.password = lower(password);
                    self.userName = userName;
                    detailscorrect = true;
                end
            end
        end
        
        
        function getCall(self)
        end
        
        function result = parseArray(resultString)
            result = strsplit(resultString,'!');
        end
        
        function result = parseStruct(resultString)
            entries = strsplit(resultString,'!');
            if ~isempty(entries)
                fields = regexp(entries{1},'(?<fieldID>[^"#!*]*)\*(?<values>[^#$!"]*)','names');
                values = cellfun(@(x) cell(1,numel(entries)),{fields.values},'Uniform',0);
                fieldIDs = {fields.fieldID};
                for i = 1:numel(entries)
                    fields = regexp(entries{i},'(?<fieldID>[^"#!*]*)\*(?<values>[^#$!"]*)','names');
                    for j = 1:numel(values)
                        values{j}{i} = fields(j).values;
                    end
                end
                structdata = [fieldIDs;values];
                structdata = structdata(:);
                result = struct(structdata{:});
            else
                result = struct();
            end
        end
        function output = getLigandStructureIdByCompoundName(compoundName)
            % getLigandStructureIdByCompoundName according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getLigandStructureIdByCompoundName(compoundName):
            % INPUTS:
            %    compoundName:    name of the compund (e.g. Zn2+)
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' compoundName];
            call.setOperationName(QName('http://soapinterop.org/', 'getLigandStructureIdByCompoundName'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getReferenceById(brendaID)
            % getReferenceById according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getReferenceById(brendaID):
            % INPUTS:
            %    brendaID:    the Brenda ID
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' brendaID];
            call.setOperationName(QName('http://soapinterop.org/', 'getReferenceById'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getReferenceByPubmedId(parameter1)
            % getReferenceByPubmedId according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getReferenceByPubmedId(parameter1):
            % INPUTS:
            %    parameter1:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1];
            call.setOperationName(QName('http://soapinterop.org/', 'getReferenceByPubmedId'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromActivatingCompound()
            % getEcNumbersFromActivatingCompound according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromActivatingCompound():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromActivatingCompound'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromActivatingCompound()
            % getOrganismsFromActivatingCompound according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromActivatingCompound():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromActivatingCompound'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getActivatingCompound(parameter1, parameter2)
            % getActivatingCompound according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getActivatingCompound(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getActivatingCompound'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromApplication()
            % getEcNumbersFromApplication according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromApplication():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromApplication'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromApplication()
            % getOrganismsFromApplication according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromApplication():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromApplication'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getApplication(parameter1, parameter2)
            % getApplication according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getApplication(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getApplication'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromCasRegistryNumber()
            % getEcNumbersFromCasRegistryNumber according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromCasRegistryNumber():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromCasRegistryNumber'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getCasRegistryNumber(parameter1)
            % getCasRegistryNumber according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getCasRegistryNumber(parameter1):
            % INPUTS:
            %    parameter1:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1];
            call.setOperationName(QName('http://soapinterop.org/', 'getCasRegistryNumber'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromCloned()
            % getEcNumbersFromCloned according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromCloned():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromCloned'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromCloned()
            % getOrganismsFromCloned according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromCloned():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromCloned'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getCloned(parameter1, parameter2)
            % getCloned according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getCloned(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getCloned'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromCofactor()
            % getEcNumbersFromCofactor according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromCofactor():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromCofactor'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromCofactor()
            % getOrganismsFromCofactor according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromCofactor():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromCofactor'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getCofactor(parameter1, parameter2)
            % getCofactor according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getCofactor(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getCofactor'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromCrystallization()
            % getEcNumbersFromCrystallization according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromCrystallization():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromCrystallization'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromCrystallization()
            % getOrganismsFromCrystallization according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromCrystallization():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromCrystallization'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getCrystallization(parameter1, parameter2)
            % getCrystallization according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getCrystallization(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getCrystallization'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromDisease()
            % getEcNumbersFromDisease according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromDisease():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromDisease'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getDisease(parameter1)
            % getDisease according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getDisease(parameter1):
            % INPUTS:
            %    parameter1:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1];
            call.setOperationName(QName('http://soapinterop.org/', 'getDisease'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromEcNumber()
            % getEcNumbersFromEcNumber according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromEcNumber():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromEcNumber'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getEcNumber(parameter1)
            % getEcNumber according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumber(parameter1):
            % INPUTS:
            %    parameter1:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumber'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromEngineering()
            % getEcNumbersFromEngineering according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromEngineering():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromEngineering'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromEngineering()
            % getOrganismsFromEngineering according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromEngineering():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromEngineering'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getEngineering(parameter1, parameter2)
            % getEngineering according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEngineering(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getEngineering'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromEnzymeNames()
            % getEcNumbersFromEnzymeNames according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromEnzymeNames():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromEnzymeNames'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getEnzymeNames(parameter1)
            % getEnzymeNames according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEnzymeNames(parameter1):
            % INPUTS:
            %    parameter1:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1];
            call.setOperationName(QName('http://soapinterop.org/', 'getEnzymeNames'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromGeneralStability()
            % getEcNumbersFromGeneralStability according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromGeneralStability():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromGeneralStability'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromGeneralStability()
            % getOrganismsFromGeneralStability according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromGeneralStability():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromGeneralStability'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getGeneralStability(parameter1, parameter2)
            % getGeneralStability according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getGeneralStability(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getGeneralStability'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromIc50Value()
            % getEcNumbersFromIc50Value according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromIc50Value():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromIc50Value'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromIc50Value()
            % getOrganismsFromIc50Value according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromIc50Value():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromIc50Value'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getIc50Value(parameter1, parameter2)
            % getIc50Value according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getIc50Value(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getIc50Value'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromInhibitors()
            % getEcNumbersFromInhibitors according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromInhibitors():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromInhibitors'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromInhibitors()
            % getOrganismsFromInhibitors according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromInhibitors():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromInhibitors'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getInhibitors(parameter1, parameter2)
            % getInhibitors according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getInhibitors(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getInhibitors'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromKcatKmValue()
            % getEcNumbersFromKcatKmValue according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromKcatKmValue():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromKcatKmValue'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromKcatKmValue()
            % getOrganismsFromKcatKmValue according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromKcatKmValue():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromKcatKmValue'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getKcatKmValue(parameter1, parameter2)
            % getKcatKmValue according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getKcatKmValue(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getKcatKmValue'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromKiValue()
            % getEcNumbersFromKiValue according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromKiValue():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromKiValue'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromKiValue()
            % getOrganismsFromKiValue according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromKiValue():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromKiValue'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getKiValue(parameter1, parameter2)
            % getKiValue according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getKiValue(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getKiValue'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromKmValue()
            % getEcNumbersFromKmValue according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromKmValue():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromKmValue'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromKmValue()
            % getOrganismsFromKmValue according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromKmValue():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromKmValue'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getKmValue(parameter1, parameter2)
            % getKmValue according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getKmValue(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getKmValue'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromLigands()
            % getEcNumbersFromLigands according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromLigands():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromLigands'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromLigands()
            % getOrganismsFromLigands according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromLigands():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromLigands'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getLigands(parameter1, parameter2)
            % getLigands according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getLigands(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getLigands'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromLocalization()
            % getEcNumbersFromLocalization according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromLocalization():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromLocalization'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromLocalization()
            % getOrganismsFromLocalization according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromLocalization():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromLocalization'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getLocalization(parameter1, parameter2)
            % getLocalization according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getLocalization(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getLocalization'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromMetalsIons()
            % getEcNumbersFromMetalsIons according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromMetalsIons():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromMetalsIons'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromMetalsIons()
            % getOrganismsFromMetalsIons according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromMetalsIons():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromMetalsIons'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getMetalsIons(parameter1, parameter2)
            % getMetalsIons according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getMetalsIons(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getMetalsIons'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromMolecularWeight()
            % getEcNumbersFromMolecularWeight according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromMolecularWeight():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromMolecularWeight'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromMolecularWeight()
            % getOrganismsFromMolecularWeight according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromMolecularWeight():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromMolecularWeight'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getMolecularWeight(parameter1, parameter2)
            % getMolecularWeight according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getMolecularWeight(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getMolecularWeight'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromNaturalProduct()
            % getEcNumbersFromNaturalProduct according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromNaturalProduct():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromNaturalProduct'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromNaturalProduct()
            % getOrganismsFromNaturalProduct according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromNaturalProduct():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromNaturalProduct'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getNaturalProduct(parameter1, parameter2)
            % getNaturalProduct according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getNaturalProduct(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getNaturalProduct'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromNaturalSubstrate()
            % getEcNumbersFromNaturalSubstrate according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromNaturalSubstrate():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromNaturalSubstrate'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromNaturalSubstrate()
            % getOrganismsFromNaturalSubstrate according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromNaturalSubstrate():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromNaturalSubstrate'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getNaturalSubstrate(parameter1, parameter2)
            % getNaturalSubstrate according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getNaturalSubstrate(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getNaturalSubstrate'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromNaturalSubstratesProducts()
            % getEcNumbersFromNaturalSubstratesProducts according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromNaturalSubstratesProducts():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromNaturalSubstratesProducts'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getNaturalSubstratesProducts(parameter1)
            % getNaturalSubstratesProducts according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getNaturalSubstratesProducts(parameter1):
            % INPUTS:
            %    parameter1:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1];
            call.setOperationName(QName('http://soapinterop.org/', 'getNaturalSubstratesProducts'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromOrganicSolventStability()
            % getEcNumbersFromOrganicSolventStability according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromOrganicSolventStability():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromOrganicSolventStability'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromOrganicSolventStability()
            % getOrganismsFromOrganicSolventStability according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromOrganicSolventStability():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromOrganicSolventStability'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganicSolventStability(parameter1, parameter2)
            % getOrganicSolventStability according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganicSolventStability(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganicSolventStability'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromOrganism()
            % getEcNumbersFromOrganism according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromOrganism():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromOrganism'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromOrganism()
            % getOrganismsFromOrganism according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromOrganism():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromOrganism'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganism(parameter1, parameter2)
            % getOrganism according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganism(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganism'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromOxidationStability()
            % getEcNumbersFromOxidationStability according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromOxidationStability():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromOxidationStability'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromOxidationStability()
            % getOrganismsFromOxidationStability according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromOxidationStability():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromOxidationStability'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOxidationStability(parameter1, parameter2)
            % getOxidationStability according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOxidationStability(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getOxidationStability'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromPathway()
            % getEcNumbersFromPathway according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromPathway():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromPathway'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getPathway(parameter1)
            % getPathway according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getPathway(parameter1):
            % INPUTS:
            %    parameter1:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1];
            call.setOperationName(QName('http://soapinterop.org/', 'getPathway'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromPdb()
            % getEcNumbersFromPdb according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromPdb():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromPdb'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromPdb()
            % getOrganismsFromPdb according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromPdb():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromPdb'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getPdb(parameter1, parameter2)
            % getPdb according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getPdb(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getPdb'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromPhOptimum()
            % getEcNumbersFromPhOptimum according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromPhOptimum():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromPhOptimum'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromPhOptimum()
            % getOrganismsFromPhOptimum according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromPhOptimum():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromPhOptimum'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getPhOptimum(parameter1, parameter2)
            % getPhOptimum according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getPhOptimum(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getPhOptimum'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromPhRange()
            % getEcNumbersFromPhRange according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromPhRange():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromPhRange'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromPhRange()
            % getOrganismsFromPhRange according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromPhRange():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromPhRange'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getPhRange(parameter1, parameter2)
            % getPhRange according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getPhRange(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getPhRange'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromPhStability()
            % getEcNumbersFromPhStability according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromPhStability():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromPhStability'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromPhStability()
            % getOrganismsFromPhStability according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromPhStability():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromPhStability'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getPhStability(parameter1, parameter2)
            % getPhStability according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getPhStability(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getPhStability'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromPiValue()
            % getEcNumbersFromPiValue according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromPiValue():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromPiValue'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromPiValue()
            % getOrganismsFromPiValue according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromPiValue():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromPiValue'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getPiValue(parameter1, parameter2)
            % getPiValue according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getPiValue(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getPiValue'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromPosttranslationalModification()
            % getEcNumbersFromPosttranslationalModification according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromPosttranslationalModification():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromPosttranslationalModification'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromPosttranslationalModification()
            % getOrganismsFromPosttranslationalModification according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromPosttranslationalModification():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromPosttranslationalModification'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getPosttranslationalModification(parameter1, parameter2)
            % getPosttranslationalModification according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getPosttranslationalModification(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getPosttranslationalModification'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromProduct()
            % getEcNumbersFromProduct according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromProduct():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromProduct'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromProduct()
            % getOrganismsFromProduct according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromProduct():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromProduct'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getProduct(parameter1, parameter2)
            % getProduct according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getProduct(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getProduct'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromPurification()
            % getEcNumbersFromPurification according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromPurification():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromPurification'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromPurification()
            % getOrganismsFromPurification according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromPurification():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromPurification'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getPurification(parameter1, parameter2)
            % getPurification according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getPurification(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getPurification'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromReaction()
            % getEcNumbersFromReaction according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromReaction():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromReaction'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromReaction()
            % getOrganismsFromReaction according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromReaction():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromReaction'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getReaction(parameter1, parameter2)
            % getReaction according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getReaction(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getReaction'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromReactionType()
            % getEcNumbersFromReactionType according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromReactionType():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromReactionType'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromReactionType()
            % getOrganismsFromReactionType according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromReactionType():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromReactionType'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getReactionType(parameter1, parameter2)
            % getReactionType according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getReactionType(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getReactionType'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromRecommendedName()
            % getEcNumbersFromRecommendedName according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromRecommendedName():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromRecommendedName'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getRecommendedName(parameter1)
            % getRecommendedName according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getRecommendedName(parameter1):
            % INPUTS:
            %    parameter1:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1];
            call.setOperationName(QName('http://soapinterop.org/', 'getRecommendedName'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromReference()
            % getEcNumbersFromReference according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromReference():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromReference'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromReference()
            % getOrganismsFromReference according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromReference():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromReference'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getReference(parameter1, parameter2)
            % getReference according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getReference(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getReference'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromRenatured()
            % getEcNumbersFromRenatured according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromRenatured():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromRenatured'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromRenatured()
            % getOrganismsFromRenatured according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromRenatured():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromRenatured'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getRenatured(parameter1, parameter2)
            % getRenatured according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getRenatured(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getRenatured'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromSequence()
            % getEcNumbersFromSequence according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromSequence():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromSequence'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromSequence()
            % getOrganismsFromSequence according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromSequence():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromSequence'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getSequence(parameter1, parameter2)
            % getSequence according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getSequence(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getSequence'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromSourceTissue()
            % getEcNumbersFromSourceTissue according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromSourceTissue():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromSourceTissue'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromSourceTissue()
            % getOrganismsFromSourceTissue according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromSourceTissue():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromSourceTissue'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getSourceTissue(parameter1, parameter2)
            % getSourceTissue according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getSourceTissue(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getSourceTissue'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromSpecificActivity()
            % getEcNumbersFromSpecificActivity according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromSpecificActivity():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromSpecificActivity'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromSpecificActivity()
            % getOrganismsFromSpecificActivity according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromSpecificActivity():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromSpecificActivity'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getSpecificActivity(parameter1, parameter2)
            % getSpecificActivity according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getSpecificActivity(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getSpecificActivity'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromStorageStability()
            % getEcNumbersFromStorageStability according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromStorageStability():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromStorageStability'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromStorageStability()
            % getOrganismsFromStorageStability according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromStorageStability():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromStorageStability'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getStorageStability(parameter1, parameter2)
            % getStorageStability according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getStorageStability(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getStorageStability'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromSubstrate()
            % getEcNumbersFromSubstrate according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromSubstrate():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromSubstrate'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromSubstrate()
            % getOrganismsFromSubstrate according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromSubstrate():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromSubstrate'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getSubstrate(parameter1, parameter2)
            % getSubstrate according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getSubstrate(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getSubstrate'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromSubstratesProducts()
            % getEcNumbersFromSubstratesProducts according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromSubstratesProducts():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromSubstratesProducts'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getSubstratesProducts(parameter1)
            % getSubstratesProducts according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getSubstratesProducts(parameter1):
            % INPUTS:
            %    parameter1:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1];
            call.setOperationName(QName('http://soapinterop.org/', 'getSubstratesProducts'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromSubunits()
            % getEcNumbersFromSubunits according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromSubunits():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromSubunits'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromSubunits()
            % getOrganismsFromSubunits according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromSubunits():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromSubunits'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getSubunits(parameter1, parameter2)
            % getSubunits according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getSubunits(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getSubunits'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromSynonyms()
            % getEcNumbersFromSynonyms according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromSynonyms():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromSynonyms'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromSynonyms()
            % getOrganismsFromSynonyms according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromSynonyms():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromSynonyms'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getSynonyms(parameter1, parameter2)
            % getSynonyms according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getSynonyms(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getSynonyms'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromSystematicName()
            % getEcNumbersFromSystematicName according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromSystematicName():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromSystematicName'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getSystematicName(parameter1)
            % getSystematicName according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getSystematicName(parameter1):
            % INPUTS:
            %    parameter1:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1];
            call.setOperationName(QName('http://soapinterop.org/', 'getSystematicName'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromTemperatureOptimum()
            % getEcNumbersFromTemperatureOptimum according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromTemperatureOptimum():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromTemperatureOptimum'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromTemperatureOptimum()
            % getOrganismsFromTemperatureOptimum according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromTemperatureOptimum():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromTemperatureOptimum'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getTemperatureOptimum(parameter1, parameter2)
            % getTemperatureOptimum according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getTemperatureOptimum(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getTemperatureOptimum'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromTemperatureRange()
            % getEcNumbersFromTemperatureRange according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromTemperatureRange():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromTemperatureRange'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromTemperatureRange()
            % getOrganismsFromTemperatureRange according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromTemperatureRange():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromTemperatureRange'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getTemperatureRange(parameter1, parameter2)
            % getTemperatureRange according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getTemperatureRange(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getTemperatureRange'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromTemperatureStability()
            % getEcNumbersFromTemperatureStability according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromTemperatureStability():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromTemperatureStability'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromTemperatureStability()
            % getOrganismsFromTemperatureStability according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromTemperatureStability():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromTemperatureStability'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getTemperatureStability(parameter1, parameter2)
            % getTemperatureStability according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getTemperatureStability(parameter1, parameter2):
            % INPUTS:
            %    parameter1:    ParameDescription
            %    parameter2:    ParameDescription
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' parameter1 '#' parameter2];
            call.setOperationName(QName('http://soapinterop.org/', 'getTemperatureStability'));
            resultString = call.invoke( {parameters} );
            output = self.parseStruct(resultString);
        end
        
        
        function output = getEcNumbersFromTurnoverNumber()
            % getEcNumbersFromTurnoverNumber according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getEcNumbersFromTurnoverNumber():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromTurnoverNumber'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        function output = getOrganismsFromTurnoverNumber()
            % getOrganismsFromTurnoverNumber according to the Brenda SOAP api.
            % USAGE:
            %    output = BrendaClient.getOrganismsFromTurnoverNumber():
            % OUTPUT:
            %    output:    Description
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            parameters = [self.userName ',' lower(self.password) ',' ];
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromTurnoverNumber'));
            resultString = call.invoke( {parameters} );
            output = self.parseArray(resultString);
        end
        
        
        
    end
end


