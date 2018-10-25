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
        
        function result = parseArray(self, resultString)
            result = strsplit(resultString,'!');
        end
        
        function result = parseStruct(self,resultString)
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
        function parameters = buildParamString(self,Results,Defaults)
            parameters = {};
            resultNames = fieldnames(Results);
            for i = 1:numel(resultNames)
                if ~any(ismember(resultNames{i},Defaults))
                    parameters{end+1} = strcat(resultNames{i},'*',Results.(resultNames{i}));
                end
            end
            parameters = strjoin(parameters,'#');
        end
        
        
        function results = getLigandStructureIdByCompoundName(self,varargin)
            % getLigandStructureIdByCompoundName according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getLigandStructureIdByCompoundName(varargin)
            % INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                   - compoundName:    name of the compound to
            %                     retrieve the ID for
            % OUTPUT:
            %    results:    A cell array of  from the BRENDA database
            parser=inputParser();
            parser.addParameter('compoundName','',@ischar);
            parser.parse(varargin{:})
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) , parser.Results.compoundName}, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getLigandStructureIdByCompoundName'));
            resultString = call.invoke( {parameters} );
            results = self.parseArray(resultString);
        end
        
        
        function results = getReferenceById(self,varargin)
            % getReferenceById according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getReferenceById(varargin)
            % INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                   - id:    id from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - authors: The authorss stored in the BRENDA database
            %                  - title: The titles stored in the BRENDA database
            %                  - journal: The journals stored in the BRENDA database
            %                  - volume: The volumes stored in the BRENDA database
            %                  - pages: The pagess stored in the BRENDA database
            %                  - year: The years stored in the BRENDA database
            %                  - pubmedId: The pubmedIds stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('id','',@ischar);
            parser.parse(varargin{:})
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) , parser.Results.id}, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getReferenceById'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function results = getReferenceByPubmedId(self,varargin)
            % getReferenceByPubmedId according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getReferenceByPubmedId(varargin)
            % INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                   - pubmedid:    a valid pubmedid
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - authors: The authorss stored in the BRENDA database
            %                  - title: The titles stored in the BRENDA database
            %                  - journal: The journals stored in the BRENDA database
            %                  - volume: The volumes stored in the BRENDA database
            %                  - pages: The pagess stored in the BRENDA database
            %                  - year: The years stored in the BRENDA database
            %                  - pubmedId: The pubmedIds stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('pubmedid','',@ischar);
            parser.parse(varargin{:})
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) , parser.Results.pubmedid}, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getReferenceByPubmedId'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromActivatingCompound(self, varargin)
            % getEcNumbersFromActivatingCompound according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromActivatingCompound(varargin)
            % INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                   - activatingCompound:    a valid activating
            %                     Compound (e.g. 'rhodamine 123')
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            parser=inputParser();
            parser.addParameter('activatingCompound','',@ischar);
            parser.parse(varargin{:})
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            parameters = strjoin({self.userName , lower(self.password) ,parameters}, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromActivatingCompound'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        
        function Organisms = getOrganismsFromActivatingCompound(self)
            % getOrganismsFromActivatingCompound according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromActivatingCompound()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromActivatingCompound'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getActivatingCompound(self,varargin)
            % getActivatingCompound according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getActivatingCompound(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - activatingCompound: The activatingCompound from the BRENDA database
            %                   - commentary: The commentary from the BRENDA database
            %                   - ligandStructureId: The ligandStructureId from the BRENDA database
            %                   - literature: The literature from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - activatingCompound: The activatingCompounds stored in the BRENDA database
            %                  - commentary: The commentarys stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            %                  - ligandStructureId: The ligandStructureIds stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('activatingCompound','',@ischar);
            parser.addParameter('commentary','',@ischar);
            parser.addParameter('ligandStructureId','',@ischar);
            parser.addParameter('literature','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getActivatingCompound'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromApplication(self)
            % getEcNumbersFromApplication according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromApplication()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromApplication'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromApplication(self)
            % getOrganismsFromApplication according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromApplication()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromApplication'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getApplication(self,varargin)
            % getApplication according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getApplication(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - application: The application from the BRENDA database
            %                   - commentary: The commentary from the BRENDA database
            %                   - literature: The literature from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - application: The applications stored in the BRENDA database
            %                  - commentary: The commentarys stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('application','',@ischar);
            parser.addParameter('commentary','',@ischar);
            parser.addParameter('literature','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getApplication'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromCasRegistryNumber(self)
            % getEcNumbersFromCasRegistryNumber according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromCasRegistryNumber()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromCasRegistryNumber'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function results = getCasRegistryNumber(self,varargin)
            % getCasRegistryNumber according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getCasRegistryNumber(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - casRegistryNumber: The casRegistryNumber from the BRENDA database
            %                   - commentary: The commentary from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - casRegistryNumber: The casRegistryNumbers stored in the BRENDA database
            %                  - commentary: The commentarys stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('casRegistryNumber','',@ischar);
            parser.addParameter('commentary','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getCasRegistryNumber'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromCloned(self)
            % getEcNumbersFromCloned according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromCloned()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromCloned'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromCloned(self)
            % getOrganismsFromCloned according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromCloned()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromCloned'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getCloned(self,varargin)
            % getCloned according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getCloned(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - commentary: The commentary from the BRENDA database
            %                   - literature: The literature from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - commentary: The commentarys stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('commentary','',@ischar);
            parser.addParameter('literature','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getCloned'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromCofactor(self)
            % getEcNumbersFromCofactor according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromCofactor()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromCofactor'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromCofactor(self)
            % getOrganismsFromCofactor according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromCofactor()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromCofactor'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getCofactor(self,varargin)
            % getCofactor according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getCofactor(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - cofactor: The cofactor from the BRENDA database
            %                   - commentary: The commentary from the BRENDA database
            %                   - ligandStructureId: The ligandStructureId from the BRENDA database
            %                   - literature: The literature from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - cofactor: The cofactors stored in the BRENDA database
            %                  - commentary: The commentarys stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            %                  - ligandStructureId: The ligandStructureIds stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('cofactor','',@ischar);
            parser.addParameter('commentary','',@ischar);
            parser.addParameter('ligandStructureId','',@ischar);
            parser.addParameter('literature','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getCofactor'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromCrystallization(self)
            % getEcNumbersFromCrystallization according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromCrystallization()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromCrystallization'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromCrystallization(self)
            % getOrganismsFromCrystallization according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromCrystallization()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromCrystallization'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getCrystallization(self,varargin)
            % getCrystallization according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getCrystallization(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - commentary: The commentary from the BRENDA database
            %                   - literature: The literature from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - commentary: The commentarys stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('commentary','',@ischar);
            parser.addParameter('literature','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getCrystallization'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromDisease(self)
            % getEcNumbersFromDisease according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromDisease()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromDisease'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function results = getDisease(self,varargin)
            % getDisease according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getDisease(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - disease: The disease from the BRENDA database
            %                   - pubmedId: The pubmedId from the BRENDA database
            %                   - titlePub: The titlePub from the BRENDA database
            %                   - category: The category from the BRENDA database
            %                   - highestConfidenceLevel: The highestConfidenceLevel from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - disease: The diseases stored in the BRENDA database
            %                  - pubmedId: The pubmedIds stored in the BRENDA database
            %                  - titlePub: The titlePubs stored in the BRENDA database
            %                  - category: The categorys stored in the BRENDA database
            %                  - highestConfidenceLevel: The highestConfidenceLevels stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('disease','',@ischar);
            parser.addParameter('pubmedId','',@ischar);
            parser.addParameter('titlePub','',@ischar);
            parser.addParameter('category','',@ischar);
            parser.addParameter('highestConfidenceLevel','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getDisease'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromEcNumber(self)
            % getEcNumbersFromEcNumber according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromEcNumber()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromEcNumber'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function results = getEcNumber(self,varargin)
            % getEcNumber according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getEcNumber(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - commentary: The commentary from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - commentary: The commentarys stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('commentary','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumber'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromEngineering(self)
            % getEcNumbersFromEngineering according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromEngineering()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromEngineering'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromEngineering(self)
            % getOrganismsFromEngineering according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromEngineering()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromEngineering'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getEngineering(self,varargin)
            % getEngineering according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getEngineering(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - engineering: The engineering from the BRENDA database
            %                   - commentary: The commentary from the BRENDA database
            %                   - literature: The literature from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - engineering: The engineerings stored in the BRENDA database
            %                  - commentary: The commentarys stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('engineering','',@ischar);
            parser.addParameter('commentary','',@ischar);
            parser.addParameter('literature','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getEngineering'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromEnzymeNames(self)
            % getEcNumbersFromEnzymeNames according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromEnzymeNames()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromEnzymeNames'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function results = getEnzymeNames(self,varargin)
            % getEnzymeNames according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getEnzymeNames(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - synonyms: The synonyms from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - synonyms: The synonymss stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('synonyms','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getEnzymeNames'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromGeneralStability(self)
            % getEcNumbersFromGeneralStability according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromGeneralStability()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromGeneralStability'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromGeneralStability(self)
            % getOrganismsFromGeneralStability according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromGeneralStability()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromGeneralStability'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getGeneralStability(self,varargin)
            % getGeneralStability according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getGeneralStability(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - generalStability: The generalStability from the BRENDA database
            %                   - literature: The literature from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - generalStability: The generalStabilitys stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('generalStability','',@ischar);
            parser.addParameter('literature','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getGeneralStability'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromIc50Value(self)
            % getEcNumbersFromIc50Value according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromIc50Value()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromIc50Value'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromIc50Value(self)
            % getOrganismsFromIc50Value according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromIc50Value()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromIc50Value'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getIc50Value(self,varargin)
            % getIc50Value according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getIc50Value(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - ic50Value: The ic50Value from the BRENDA database
            %                   - ic50ValueMaximum: The ic50ValueMaximum from the BRENDA database
            %                   - inhibitor: The inhibitor from the BRENDA database
            %                   - commentary: The commentary from the BRENDA database
            %                   - ligandStructureId: The ligandStructureId from the BRENDA database
            %                   - literature: The literature from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - icValue: The icValues stored in the BRENDA database
            %                  - icValueMaximum: The icValueMaximums stored in the BRENDA database
            %                  - inhibitor: The inhibitors stored in the BRENDA database
            %                  - commentary: The commentarys stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            %                  - ligandStructureId: The ligandStructureIds stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('ic50Value','',@ischar);
            parser.addParameter('ic50ValueMaximum','',@ischar);
            parser.addParameter('inhibitor','',@ischar);
            parser.addParameter('commentary','',@ischar);
            parser.addParameter('ligandStructureId','',@ischar);
            parser.addParameter('literature','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getIc50Value'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromInhibitors(self)
            % getEcNumbersFromInhibitors according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromInhibitors()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromInhibitors'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromInhibitors(self)
            % getOrganismsFromInhibitors according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromInhibitors()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromInhibitors'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getInhibitors(self,varargin)
            % getInhibitors according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getInhibitors(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - inhibitors: The inhibitors from the BRENDA database
            %                   - commentary: The commentary from the BRENDA database
            %                   - ligandStructureId: The ligandStructureId from the BRENDA database
            %                   - literature: The literature from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - inhibitors: The inhibitorss stored in the BRENDA database
            %                  - commentary: The commentarys stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            %                  - ligandStructureId: The ligandStructureIds stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('inhibitors','',@ischar);
            parser.addParameter('commentary','',@ischar);
            parser.addParameter('ligandStructureId','',@ischar);
            parser.addParameter('literature','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getInhibitors'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromKcatKmValue(self)
            % getEcNumbersFromKcatKmValue according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromKcatKmValue()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromKcatKmValue'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromKcatKmValue(self)
            % getOrganismsFromKcatKmValue according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromKcatKmValue()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromKcatKmValue'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getKcatKmValue(self,varargin)
            % getKcatKmValue according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getKcatKmValue(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - kcatKmValue: The kcatKmValue from the BRENDA database
            %                   - kcatKmValueMaximum: The kcatKmValueMaximum from the BRENDA database
            %                   - substrate: The substrate from the BRENDA database
            %                   - commentary: The commentary from the BRENDA database
            %                   - ligandStructureId: The ligandStructureId from the BRENDA database
            %                   - literature: The literature from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - kcatKmValue: The kcatKmValues stored in the BRENDA database
            %                  - kcatKmValueMaximum: The kcatKmValueMaximums stored in the BRENDA database
            %                  - substrate: The substrates stored in the BRENDA database
            %                  - commentary: The commentarys stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            %                  - ligandStructureId: The ligandStructureIds stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('kcatKmValue','',@ischar);
            parser.addParameter('kcatKmValueMaximum','',@ischar);
            parser.addParameter('substrate','',@ischar);
            parser.addParameter('commentary','',@ischar);
            parser.addParameter('ligandStructureId','',@ischar);
            parser.addParameter('literature','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getKcatKmValue'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromKiValue(self)
            % getEcNumbersFromKiValue according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromKiValue()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromKiValue'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromKiValue(self)
            % getOrganismsFromKiValue according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromKiValue()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromKiValue'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getKiValue(self,varargin)
            % getKiValue according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getKiValue(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - kiValue: The kiValue from the BRENDA database
            %                   - kiValueMaximum: The kiValueMaximum from the BRENDA database
            %                   - inhibitor: The inhibitor from the BRENDA database
            %                   - commentary: The commentary from the BRENDA database
            %                   - ligandStructureId: The ligandStructureId from the BRENDA database
            %                   - literature: The literature from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - kiValue: The kiValues stored in the BRENDA database
            %                  - kiValueMaximum: The kiValueMaximums stored in the BRENDA database
            %                  - inhibitor: The inhibitors stored in the BRENDA database
            %                  - commentary: The commentarys stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            %                  - ligandStructureId: The ligandStructureIds stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('kiValue','',@ischar);
            parser.addParameter('kiValueMaximum','',@ischar);
            parser.addParameter('inhibitor','',@ischar);
            parser.addParameter('commentary','',@ischar);
            parser.addParameter('ligandStructureId','',@ischar);
            parser.addParameter('literature','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getKiValue'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromKmValue(self)
            % getEcNumbersFromKmValue according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromKmValue()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromKmValue'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromKmValue(self)
            % getOrganismsFromKmValue according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromKmValue()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromKmValue'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getKmValue(self,varargin)
            % getKmValue according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getKmValue(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - kmValue: The kmValue from the BRENDA database
            %                   - kmValueMaximum: The kmValueMaximum from the BRENDA database
            %                   - substrate: The substrate from the BRENDA database
            %                   - commentary: The commentary from the BRENDA database
            %                   - ligandStructureId: The ligandStructureId from the BRENDA database
            %                   - literature: The literature from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - kmValue: The kmValues stored in the BRENDA database
            %                  - kmValueMaximum: The kmValueMaximums stored in the BRENDA database
            %                  - substrate: The substrates stored in the BRENDA database
            %                  - commentary: The commentarys stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            %                  - ligandStructureId: The ligandStructureIds stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('kmValue','',@ischar);
            parser.addParameter('kmValueMaximum','',@ischar);
            parser.addParameter('substrate','',@ischar);
            parser.addParameter('commentary','',@ischar);
            parser.addParameter('ligandStructureId','',@ischar);
            parser.addParameter('literature','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getKmValue'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromLigands(self)
            % getEcNumbersFromLigands according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromLigands()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromLigands'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromLigands(self)
            % getOrganismsFromLigands according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromLigands()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromLigands'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getLigands(self,varargin)
            % getLigands according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getLigands(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - role: The role from the BRENDA database
            %                   - ligand: The ligand from the BRENDA database
            %                   - ligandStructureId: The ligandStructureId from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - role: The roles stored in the BRENDA database
            %                  - ligand: The ligands stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            %                  - ligandStructureId: The ligandStructureIds stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('role','',@ischar);
            parser.addParameter('ligand','',@ischar);
            parser.addParameter('ligandStructureId','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getLigands'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromLocalization(self)
            % getEcNumbersFromLocalization according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromLocalization()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromLocalization'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromLocalization(self)
            % getOrganismsFromLocalization according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromLocalization()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromLocalization'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getLocalization(self,varargin)
            % getLocalization according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getLocalization(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - localization: The localization from the BRENDA database
            %                   - commentary: The commentary from the BRENDA database
            %                   - idGo: The idGo from the BRENDA database
            %                   - literature: The literature from the BRENDA database
            %                   - textmining: The textmining from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - localization: The localizations stored in the BRENDA database
            %                  - commentary: The commentarys stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            %                  - idGo: The idGos stored in the BRENDA database
            %                  - textmining: The textminings stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('localization','',@ischar);
            parser.addParameter('commentary','',@ischar);
            parser.addParameter('idGo','',@ischar);
            parser.addParameter('literature','',@ischar);
            parser.addParameter('textmining','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getLocalization'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromMetalsIons(self)
            % getEcNumbersFromMetalsIons according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromMetalsIons()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromMetalsIons'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromMetalsIons(self)
            % getOrganismsFromMetalsIons according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromMetalsIons()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromMetalsIons'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getMetalsIons(self,varargin)
            % getMetalsIons according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getMetalsIons(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - metalsIons: The metalsIons from the BRENDA database
            %                   - commentary: The commentary from the BRENDA database
            %                   - ligandStructureId: The ligandStructureId from the BRENDA database
            %                   - literature: The literature from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - metalsIons: The metalsIonss stored in the BRENDA database
            %                  - commentary: The commentarys stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            %                  - ligandStructureId: The ligandStructureIds stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('metalsIons','',@ischar);
            parser.addParameter('commentary','',@ischar);
            parser.addParameter('ligandStructureId','',@ischar);
            parser.addParameter('literature','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getMetalsIons'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromMolecularWeight(self)
            % getEcNumbersFromMolecularWeight according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromMolecularWeight()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromMolecularWeight'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromMolecularWeight(self)
            % getOrganismsFromMolecularWeight according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromMolecularWeight()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromMolecularWeight'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getMolecularWeight(self,varargin)
            % getMolecularWeight according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getMolecularWeight(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - molecularWeight: The molecularWeight from the BRENDA database
            %                   - molecularWeightMaximum: The molecularWeightMaximum from the BRENDA database
            %                   - commentary: The commentary from the BRENDA database
            %                   - literature: The literature from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - molecularWeight: The molecularWeights stored in the BRENDA database
            %                  - molecularWeightMaximum: The molecularWeightMaximums stored in the BRENDA database
            %                  - commentary: The commentarys stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('molecularWeight','',@ischar);
            parser.addParameter('molecularWeightMaximum','',@ischar);
            parser.addParameter('commentary','',@ischar);
            parser.addParameter('literature','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getMolecularWeight'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromNaturalProduct(self)
            % getEcNumbersFromNaturalProduct according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromNaturalProduct()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromNaturalProduct'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromNaturalProduct(self)
            % getOrganismsFromNaturalProduct according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromNaturalProduct()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromNaturalProduct'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getNaturalProduct(self,varargin)
            % getNaturalProduct according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getNaturalProduct(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - naturalProduct: The naturalProduct from the BRENDA database
            %                   - naturalReactionPartners: The naturalReactionPartners from the BRENDA database
            %                   - ligandStructureId: The ligandStructureId from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - naturalProduct: The naturalProducts stored in the BRENDA database
            %                  - naturalReactionPartners: The naturalReactionPartnerss stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            %                  - ligandStructureId: The ligandStructureIds stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('naturalProduct','',@ischar);
            parser.addParameter('naturalReactionPartners','',@ischar);
            parser.addParameter('ligandStructureId','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getNaturalProduct'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromNaturalSubstrate(self)
            % getEcNumbersFromNaturalSubstrate according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromNaturalSubstrate()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromNaturalSubstrate'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromNaturalSubstrate(self)
            % getOrganismsFromNaturalSubstrate according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromNaturalSubstrate()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromNaturalSubstrate'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getNaturalSubstrate(self,varargin)
            % getNaturalSubstrate according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getNaturalSubstrate(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - naturalSubstrate: The naturalSubstrate from the BRENDA database
            %                   - naturalReactionPartners: The naturalReactionPartners from the BRENDA database
            %                   - ligandStructureId: The ligandStructureId from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - naturalSubstrate: The naturalSubstrates stored in the BRENDA database
            %                  - naturalReactionPartners: The naturalReactionPartnerss stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            %                  - ligandStructureId: The ligandStructureIds stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('naturalSubstrate','',@ischar);
            parser.addParameter('naturalReactionPartners','',@ischar);
            parser.addParameter('ligandStructureId','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getNaturalSubstrate'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromNaturalSubstratesProducts(self)
            % getEcNumbersFromNaturalSubstratesProducts according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromNaturalSubstratesProducts()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromNaturalSubstratesProducts'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function results = getNaturalSubstratesProducts(self,varargin)
            % getNaturalSubstratesProducts according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getNaturalSubstratesProducts(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - naturalSubstrates: The naturalSubstrates from the BRENDA database
            %                   - organismNaturalSubstrates: The organismNaturalSubstrates from the BRENDA database
            %                   - commentaryNaturalSubstrates: The commentaryNaturalSubstrates from the BRENDA database
            %                   - naturalProducts: The naturalProducts from the BRENDA database
            %                   - commentaryNaturalProducts: The commentaryNaturalProducts from the BRENDA database
            %                   - organismNaturalProducts: The organismNaturalProducts from the BRENDA database
            %                   - reversibility: The reversibility from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - naturalSubstrates: The naturalSubstratess stored in the BRENDA database
            %                  - organismNaturalSubstrates: The organismNaturalSubstratess stored in the BRENDA database
            %                  - commentaryNaturalSubstrates: The commentaryNaturalSubstratess stored in the BRENDA database
            %                  - naturalProducts: The naturalProductss stored in the BRENDA database
            %                  - commentaryNaturalProducts: The commentaryNaturalProductss stored in the BRENDA database
            %                  - organismNaturalProducts: The organismNaturalProductss stored in the BRENDA database
            %                  - reversibility: The reversibilitys stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('naturalSubstrates','',@ischar);
            parser.addParameter('organismNaturalSubstrates','',@ischar);
            parser.addParameter('commentaryNaturalSubstrates','',@ischar);
            parser.addParameter('naturalProducts','',@ischar);
            parser.addParameter('commentaryNaturalProducts','',@ischar);
            parser.addParameter('organismNaturalProducts','',@ischar);
            parser.addParameter('reversibility','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getNaturalSubstratesProducts'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromOrganicSolventStability(self)
            % getEcNumbersFromOrganicSolventStability according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromOrganicSolventStability()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromOrganicSolventStability'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromOrganicSolventStability(self)
            % getOrganismsFromOrganicSolventStability according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromOrganicSolventStability()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromOrganicSolventStability'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getOrganicSolventStability(self,varargin)
            % getOrganicSolventStability according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getOrganicSolventStability(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - organicSolvent: The organicSolvent from the BRENDA database
            %                   - commentary: The commentary from the BRENDA database
            %                   - literature: The literature from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - organicSolvent: The organicSolvents stored in the BRENDA database
            %                  - commentary: The commentarys stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('organicSolvent','',@ischar);
            parser.addParameter('commentary','',@ischar);
            parser.addParameter('literature','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganicSolventStability'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromOrganism(self)
            % getEcNumbersFromOrganism according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromOrganism()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromOrganism'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromOrganism(self)
            % getOrganismsFromOrganism according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromOrganism()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromOrganism'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getOrganism(self,varargin)
            % getOrganism according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getOrganism(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - sequenceCode: The sequenceCode from the BRENDA database
            %                   - commentary: The commentary from the BRENDA database
            %                   - literature: The literature from the BRENDA database
            %                   - textmining: The textmining from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - organism: The organisms stored in the BRENDA database
            %                  - sequenceCode: The sequenceCodes stored in the BRENDA database
            %                  - commentary: The commentarys stored in the BRENDA database
            %                  - textmining: The textminings stored in the BRENDA database
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('sequenceCode','',@ischar);
            parser.addParameter('commentary','',@ischar);
            parser.addParameter('literature','',@ischar);
            parser.addParameter('textmining','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganism'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromOxidationStability(self)
            % getEcNumbersFromOxidationStability according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromOxidationStability()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromOxidationStability'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromOxidationStability(self)
            % getOrganismsFromOxidationStability according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromOxidationStability()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromOxidationStability'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getOxidationStability(self,varargin)
            % getOxidationStability according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getOxidationStability(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - oxidationStability: The oxidationStability from the BRENDA database
            %                   - literature: The literature from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - oxidationStability: The oxidationStabilitys stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('oxidationStability','',@ischar);
            parser.addParameter('literature','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getOxidationStability'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromPathway(self)
            % getEcNumbersFromPathway according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromPathway()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromPathway'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function results = getPathway(self,varargin)
            % getPathway according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getPathway(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - pathway: The pathway from the BRENDA database
            %                   - link: The link from the BRENDA database
            %                   - source_database: The source_database from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - pathway: The pathways stored in the BRENDA database
            %                  - link: The links stored in the BRENDA database
            %                  - source_database: The source_databases stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('pathway','',@ischar);
            parser.addParameter('link','',@ischar);
            parser.addParameter('source_database','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getPathway'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromPdb(self)
            % getEcNumbersFromPdb according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromPdb()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromPdb'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromPdb(self)
            % getOrganismsFromPdb according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromPdb()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromPdb'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getPdb(self,varargin)
            % getPdb according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getPdb(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - pdb: The pdb from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - pdb: The pdbs stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('pdb','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getPdb'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromPhOptimum(self)
            % getEcNumbersFromPhOptimum according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromPhOptimum()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromPhOptimum'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromPhOptimum(self)
            % getOrganismsFromPhOptimum according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromPhOptimum()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromPhOptimum'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getPhOptimum(self,varargin)
            % getPhOptimum according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getPhOptimum(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - phOptimum: The phOptimum from the BRENDA database
            %                   - phOptimumMaximum: The phOptimumMaximum from the BRENDA database
            %                   - commentary: The commentary from the BRENDA database
            %                   - literature: The literature from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - phOptimum: The phOptimums stored in the BRENDA database
            %                  - phOptimumMaximum: The phOptimumMaximums stored in the BRENDA database
            %                  - commentary: The commentarys stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('phOptimum','',@ischar);
            parser.addParameter('phOptimumMaximum','',@ischar);
            parser.addParameter('commentary','',@ischar);
            parser.addParameter('literature','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getPhOptimum'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromPhRange(self)
            % getEcNumbersFromPhRange according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromPhRange()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromPhRange'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromPhRange(self)
            % getOrganismsFromPhRange according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromPhRange()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromPhRange'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getPhRange(self,varargin)
            % getPhRange according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getPhRange(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - phRange: The phRange from the BRENDA database
            %                   - phRangeMaximum: The phRangeMaximum from the BRENDA database
            %                   - commentary: The commentary from the BRENDA database
            %                   - literature: The literature from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - phRange: The phRanges stored in the BRENDA database
            %                  - phRangeMaximum: The phRangeMaximums stored in the BRENDA database
            %                  - commentary: The commentarys stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('phRange','',@ischar);
            parser.addParameter('phRangeMaximum','',@ischar);
            parser.addParameter('commentary','',@ischar);
            parser.addParameter('literature','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getPhRange'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromPhStability(self)
            % getEcNumbersFromPhStability according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromPhStability()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromPhStability'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromPhStability(self)
            % getOrganismsFromPhStability according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromPhStability()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromPhStability'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getPhStability(self,varargin)
            % getPhStability according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getPhStability(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - phStability: The phStability from the BRENDA database
            %                   - phStabilityMaximum: The phStabilityMaximum from the BRENDA database
            %                   - commentary: The commentary from the BRENDA database
            %                   - literature: The literature from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - phStability: The phStabilitys stored in the BRENDA database
            %                  - phStabilityMaximum: The phStabilityMaximums stored in the BRENDA database
            %                  - commentary: The commentarys stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('phStability','',@ischar);
            parser.addParameter('phStabilityMaximum','',@ischar);
            parser.addParameter('commentary','',@ischar);
            parser.addParameter('literature','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getPhStability'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromPiValue(self)
            % getEcNumbersFromPiValue according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromPiValue()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromPiValue'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromPiValue(self)
            % getOrganismsFromPiValue according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromPiValue()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromPiValue'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getPiValue(self,varargin)
            % getPiValue according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getPiValue(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - piValue: The piValue from the BRENDA database
            %                   - piValueMaximum: The piValueMaximum from the BRENDA database
            %                   - commentary: The commentary from the BRENDA database
            %                   - literature: The literature from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - piValue: The piValues stored in the BRENDA database
            %                  - piValueMaximum: The piValueMaximums stored in the BRENDA database
            %                  - commentary: The commentarys stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('piValue','',@ischar);
            parser.addParameter('piValueMaximum','',@ischar);
            parser.addParameter('commentary','',@ischar);
            parser.addParameter('literature','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getPiValue'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromPosttranslationalModification(self)
            % getEcNumbersFromPosttranslationalModification according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromPosttranslationalModification()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromPosttranslationalModification'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromPosttranslationalModification(self)
            % getOrganismsFromPosttranslationalModification according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromPosttranslationalModification()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromPosttranslationalModification'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getPosttranslationalModification(self,varargin)
            % getPosttranslationalModification according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getPosttranslationalModification(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - posttranslationalModification: The posttranslationalModification from the BRENDA database
            %                   - commentary: The commentary from the BRENDA database
            %                   - literature: The literature from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - posttranslationalModification: The posttranslationalModifications stored in the BRENDA database
            %                  - commentary: The commentarys stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('posttranslationalModification','',@ischar);
            parser.addParameter('commentary','',@ischar);
            parser.addParameter('literature','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getPosttranslationalModification'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromProduct(self)
            % getEcNumbersFromProduct according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromProduct()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromProduct'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromProduct(self)
            % getOrganismsFromProduct according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromProduct()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromProduct'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getProduct(self,varargin)
            % getProduct according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getProduct(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - product: The product from the BRENDA database
            %                   - reactionPartners: The reactionPartners from the BRENDA database
            %                   - ligandStructureId: The ligandStructureId from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - product: The products stored in the BRENDA database
            %                  - reactionPartners: The reactionPartnerss stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            %                  - ligandStructureId: The ligandStructureIds stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('product','',@ischar);
            parser.addParameter('reactionPartners','',@ischar);
            parser.addParameter('ligandStructureId','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getProduct'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromPurification(self)
            % getEcNumbersFromPurification according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromPurification()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromPurification'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromPurification(self)
            % getOrganismsFromPurification according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromPurification()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromPurification'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getPurification(self,varargin)
            % getPurification according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getPurification(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - commentary: The commentary from the BRENDA database
            %                   - literature: The literature from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - commentary: The commentarys stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('commentary','',@ischar);
            parser.addParameter('literature','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getPurification'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromReaction(self)
            % getEcNumbersFromReaction according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromReaction()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromReaction'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromReaction(self)
            % getOrganismsFromReaction according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromReaction()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromReaction'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getReaction(self,varargin)
            % getReaction according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getReaction(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - reaction: The reaction from the BRENDA database
            %                   - commentary: The commentary from the BRENDA database
            %                   - literature: The literature from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - reaction: The reactions stored in the BRENDA database
            %                  - commentary: The commentarys stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('reaction','',@ischar);
            parser.addParameter('commentary','',@ischar);
            parser.addParameter('literature','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getReaction'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromReactionType(self)
            % getEcNumbersFromReactionType according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromReactionType()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromReactionType'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromReactionType(self)
            % getOrganismsFromReactionType according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromReactionType()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromReactionType'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getReactionType(self,varargin)
            % getReactionType according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getReactionType(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - reactionType: The reactionType from the BRENDA database
            %                   - commentary: The commentary from the BRENDA database
            %                   - literature: The literature from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - reactionType: The reactionTypes stored in the BRENDA database
            %                  - commentary: The commentarys stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('reactionType','',@ischar);
            parser.addParameter('commentary','',@ischar);
            parser.addParameter('literature','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getReactionType'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromRecommendedName(self)
            % getEcNumbersFromRecommendedName according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromRecommendedName()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromRecommendedName'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function results = getRecommendedName(self,varargin)
            % getRecommendedName according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getRecommendedName(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - recommendedName: The recommendedName from the BRENDA database
            %                   - goNumber: The goNumber from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - recommendedName: The recommendedNames stored in the BRENDA database
            %                  - goNumber: The goNumbers stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('recommendedName','',@ischar);
            parser.addParameter('goNumber','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getRecommendedName'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromReference(self)
            % getEcNumbersFromReference according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromReference()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromReference'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromReference(self)
            % getOrganismsFromReference according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromReference()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromReference'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getReference(self,varargin)
            % getReference according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getReference(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - reference: The reference from the BRENDA database
            %                   - authors: The authors from the BRENDA database
            %                   - title: The title from the BRENDA database
            %                   - journal: The journal from the BRENDA database
            %                   - volume: The volume from the BRENDA database
            %                   - pages: The pages from the BRENDA database
            %                   - year: The year from the BRENDA database
            %                   - commentary: The commentary from the BRENDA database
            %                   - pubmedId: The pubmedId from the BRENDA database
            %                   - textmining: The textmining from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - reference: The references stored in the BRENDA database
            %                  - authors: The authorss stored in the BRENDA database
            %                  - title: The titles stored in the BRENDA database
            %                  - journal: The journals stored in the BRENDA database
            %                  - volume: The volumes stored in the BRENDA database
            %                  - pages: The pagess stored in the BRENDA database
            %                  - year: The years stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            %                  - commentary: The commentarys stored in the BRENDA database
            %                  - pubmedId: The pubmedIds stored in the BRENDA database
            %                  - textmining: The textminings stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('reference','',@ischar);
            parser.addParameter('authors','',@ischar);
            parser.addParameter('title','',@ischar);
            parser.addParameter('journal','',@ischar);
            parser.addParameter('volume','',@ischar);
            parser.addParameter('pages','',@ischar);
            parser.addParameter('year','',@ischar);
            parser.addParameter('commentary','',@ischar);
            parser.addParameter('pubmedId','',@ischar);
            parser.addParameter('textmining','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getReference'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromRenatured(self)
            % getEcNumbersFromRenatured according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromRenatured()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromRenatured'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromRenatured(self)
            % getOrganismsFromRenatured according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromRenatured()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromRenatured'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getRenatured(self,varargin)
            % getRenatured according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getRenatured(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - commentary: The commentary from the BRENDA database
            %                   - literature: The literature from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - commentary: The commentarys stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('commentary','',@ischar);
            parser.addParameter('literature','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getRenatured'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromSequence(self)
            % getEcNumbersFromSequence according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromSequence()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromSequence'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromSequence(self)
            % getOrganismsFromSequence according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromSequence()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromSequence'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getSequence(self,varargin)
            % getSequence according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getSequence(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - sequence: The sequence from the BRENDA database
            %                   - noOfAminoAcids: The noOfAminoAcids from the BRENDA database
            %                   - firstAccessionCode: The firstAccessionCode from the BRENDA database
            %                   - source: The source from the BRENDA database
            %                   - id: The id from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - sequence: The sequences stored in the BRENDA database
            %                  - noOfAminoAcids: The noOfAminoAcidss stored in the BRENDA database
            %                  - firstAccessionCode: The firstAccessionCodes stored in the BRENDA database
            %                  - source: The sources stored in the BRENDA database
            %                  - id: The ids stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('sequence','',@ischar);
            parser.addParameter('noOfAminoAcids','',@ischar);
            parser.addParameter('firstAccessionCode','',@ischar);
            parser.addParameter('source','',@ischar);
            parser.addParameter('id','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getSequence'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromSourceTissue(self)
            % getEcNumbersFromSourceTissue according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromSourceTissue()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromSourceTissue'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromSourceTissue(self)
            % getOrganismsFromSourceTissue according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromSourceTissue()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromSourceTissue'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getSourceTissue(self,varargin)
            % getSourceTissue according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getSourceTissue(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - sourceTissue: The sourceTissue from the BRENDA database
            %                   - commentary: The commentary from the BRENDA database
            %                   - literature: The literature from the BRENDA database
            %                   - textmining: The textmining from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - sourceTissue: The sourceTissues stored in the BRENDA database
            %                  - commentary: The commentarys stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            %                  - textmining: The textminings stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('sourceTissue','',@ischar);
            parser.addParameter('commentary','',@ischar);
            parser.addParameter('literature','',@ischar);
            parser.addParameter('textmining','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getSourceTissue'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromSpecificActivity(self)
            % getEcNumbersFromSpecificActivity according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromSpecificActivity()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromSpecificActivity'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromSpecificActivity(self)
            % getOrganismsFromSpecificActivity according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromSpecificActivity()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromSpecificActivity'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getSpecificActivity(self,varargin)
            % getSpecificActivity according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getSpecificActivity(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - specificActivity: The specificActivity from the BRENDA database
            %                   - specificActivityMaximum: The specificActivityMaximum from the BRENDA database
            %                   - commentary: The commentary from the BRENDA database
            %                   - literature: The literature from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - specificActivity: The specificActivitys stored in the BRENDA database
            %                  - specificActivityMaximum: The specificActivityMaximums stored in the BRENDA database
            %                  - commentary: The commentarys stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('specificActivity','',@ischar);
            parser.addParameter('specificActivityMaximum','',@ischar);
            parser.addParameter('commentary','',@ischar);
            parser.addParameter('literature','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getSpecificActivity'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromStorageStability(self)
            % getEcNumbersFromStorageStability according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromStorageStability()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromStorageStability'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromStorageStability(self)
            % getOrganismsFromStorageStability according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromStorageStability()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromStorageStability'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getStorageStability(self,varargin)
            % getStorageStability according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getStorageStability(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - storageStability: The storageStability from the BRENDA database
            %                   - literature: The literature from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - storageStability: The storageStabilitys stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('storageStability','',@ischar);
            parser.addParameter('literature','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getStorageStability'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromSubstrate(self)
            % getEcNumbersFromSubstrate according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromSubstrate()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromSubstrate'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromSubstrate(self)
            % getOrganismsFromSubstrate according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromSubstrate()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromSubstrate'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getSubstrate(self,varargin)
            % getSubstrate according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getSubstrate(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - substrate: The substrate from the BRENDA database
            %                   - reactionPartners: The reactionPartners from the BRENDA database
            %                   - ligandStructureId: The ligandStructureId from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - substrate: The substrates stored in the BRENDA database
            %                  - reactionPartners: The reactionPartnerss stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            %                  - ligandStructureId: The ligandStructureIds stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('substrate','',@ischar);
            parser.addParameter('reactionPartners','',@ischar);
            parser.addParameter('ligandStructureId','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getSubstrate'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromSubstratesProducts(self)
            % getEcNumbersFromSubstratesProducts according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromSubstratesProducts()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromSubstratesProducts'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function results = getSubstratesProducts(self,varargin)
            % getSubstratesProducts according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getSubstratesProducts(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - substrates: The substrates from the BRENDA database
            %                   - commentarySubstrates: The commentarySubstrates from the BRENDA database
            %                   - literatureSubstrates: The literatureSubstrates from the BRENDA database
            %                   - organismSubstrates: The organismSubstrates from the BRENDA database
            %                   - products: The products from the BRENDA database
            %                   - commentaryProducts: The commentaryProducts from the BRENDA database
            %                   - literatureProducts: The literatureProducts from the BRENDA database
            %                   - organismProducts: The organismProducts from the BRENDA database
            %                   - reversibility: The reversibility from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - substrates: The substratess stored in the BRENDA database
            %                  - commentarySubstrates: The commentarySubstratess stored in the BRENDA database
            %                  - literatureSubstrates: The literatureSubstratess stored in the BRENDA database
            %                  - organismSubstrates: The organismSubstratess stored in the BRENDA database
            %                  - products: The productss stored in the BRENDA database
            %                  - commentaryProducts: The commentaryProductss stored in the BRENDA database
            %                  - literatureProducts: The literatureProductss stored in the BRENDA database
            %                  - organismProducts: The organismProductss stored in the BRENDA database
            %                  - reversibility: The reversibilitys stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('substrates','',@ischar);
            parser.addParameter('commentarySubstrates','',@ischar);
            parser.addParameter('literatureSubstrates','',@ischar);
            parser.addParameter('organismSubstrates','',@ischar);
            parser.addParameter('products','',@ischar);
            parser.addParameter('commentaryProducts','',@ischar);
            parser.addParameter('literatureProducts','',@ischar);
            parser.addParameter('organismProducts','',@ischar);
            parser.addParameter('reversibility','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getSubstratesProducts'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromSubunits(self)
            % getEcNumbersFromSubunits according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromSubunits()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromSubunits'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromSubunits(self)
            % getOrganismsFromSubunits according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromSubunits()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromSubunits'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getSubunits(self,varargin)
            % getSubunits according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getSubunits(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - subunits: The subunits from the BRENDA database
            %                   - commentary: The commentary from the BRENDA database
            %                   - literature: The literature from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - subunits: The subunitss stored in the BRENDA database
            %                  - commentary: The commentarys stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('subunits','',@ischar);
            parser.addParameter('commentary','',@ischar);
            parser.addParameter('literature','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getSubunits'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromSynonyms(self)
            % getEcNumbersFromSynonyms according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromSynonyms()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromSynonyms'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromSynonyms(self)
            % getOrganismsFromSynonyms according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromSynonyms()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromSynonyms'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getSynonyms(self,varargin)
            % getSynonyms according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getSynonyms(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - synonyms: The synonyms from the BRENDA database
            %                   - commentary: The commentary from the BRENDA database
            %                   - literature: The literature from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - synonyms: The synonymss stored in the BRENDA database
            %                  - commentary: The commentarys stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('synonyms','',@ischar);
            parser.addParameter('commentary','',@ischar);
            parser.addParameter('literature','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getSynonyms'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromSystematicName(self)
            % getEcNumbersFromSystematicName according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromSystematicName()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromSystematicName'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function results = getSystematicName(self,varargin)
            % getSystematicName according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getSystematicName(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - systematicName: The systematicName from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - systematicName: The systematicNames stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('systematicName','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getSystematicName'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromTemperatureOptimum(self)
            % getEcNumbersFromTemperatureOptimum according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromTemperatureOptimum()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromTemperatureOptimum'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromTemperatureOptimum(self)
            % getOrganismsFromTemperatureOptimum according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromTemperatureOptimum()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromTemperatureOptimum'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getTemperatureOptimum(self,varargin)
            % getTemperatureOptimum according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getTemperatureOptimum(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - temperatureOptimum: The temperatureOptimum from the BRENDA database
            %                   - temperatureOptimumMaximum: The temperatureOptimumMaximum from the BRENDA database
            %                   - commentary: The commentary from the BRENDA database
            %                   - literature: The literature from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - temperatureOptimum: The temperatureOptimums stored in the BRENDA database
            %                  - temperatureOptimumMaximum: The temperatureOptimumMaximums stored in the BRENDA database
            %                  - commentary: The commentarys stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('temperatureOptimum','',@ischar);
            parser.addParameter('temperatureOptimumMaximum','',@ischar);
            parser.addParameter('commentary','',@ischar);
            parser.addParameter('literature','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getTemperatureOptimum'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromTemperatureRange(self)
            % getEcNumbersFromTemperatureRange according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromTemperatureRange()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromTemperatureRange'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromTemperatureRange(self)
            % getOrganismsFromTemperatureRange according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromTemperatureRange()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromTemperatureRange'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getTemperatureRange(self,varargin)
            % getTemperatureRange according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getTemperatureRange(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - temperatureRange: The temperatureRange from the BRENDA database
            %                   - temperatureRangeMaximum: The temperatureRangeMaximum from the BRENDA database
            %                   - commentary: The commentary from the BRENDA database
            %                   - literature: The literature from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - temperatureRange: The temperatureRanges stored in the BRENDA database
            %                  - temperatureRangeMaximum: The temperatureRangeMaximums stored in the BRENDA database
            %                  - commentary: The commentarys stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('temperatureRange','',@ischar);
            parser.addParameter('temperatureRangeMaximum','',@ischar);
            parser.addParameter('commentary','',@ischar);
            parser.addParameter('literature','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getTemperatureRange'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromTemperatureStability(self)
            % getEcNumbersFromTemperatureStability according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromTemperatureStability()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromTemperatureStability'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromTemperatureStability(self)
            % getOrganismsFromTemperatureStability according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromTemperatureStability()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromTemperatureStability'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end
        
        
        function results = getTemperatureStability(self,varargin)
            % getTemperatureStability according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getTemperatureStability(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - temperatureStability: The temperatureStability from the BRENDA database
            %                   - temperatureStabilityMaximum: The temperatureStabilityMaximum from the BRENDA database
            %                   - commentary: The commentary from the BRENDA database
            %                   - literature: The literature from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - temperatureStability: The temperatureStabilitys stored in the BRENDA database
            %                  - temperatureStabilityMaximum: The temperatureStabilityMaximums stored in the BRENDA database
            %                  - commentary: The commentarys stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('temperatureStability','',@ischar);
            parser.addParameter('temperatureStabilityMaximum','',@ischar);
            parser.addParameter('commentary','',@ischar);
            parser.addParameter('literature','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getTemperatureStability'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end
        
        
        function ECNumbers = getEcNumbersFromTurnoverNumber(self)
            % getEcNumbersFromTurnoverNumber according to the BRENDA SOAP api.
            % USAGE:
            %    ECNumbers = BrendaClient.getEcNumbersFromTurnoverNumber()
            % OUTPUT:
            %    ECNumbers:    A cell array of EC Number from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getEcNumbersFromTurnoverNumber'));
            resultString = call.invoke( {parameters} );
            ECNumbers = self.parseArray(resultString);
        end
        
        
        function Organisms = getOrganismsFromTurnoverNumber(self)
            % getOrganismsFromTurnoverNumber according to the BRENDA SOAP api.
            % USAGE:
            %    Organisms = BrendaClient.getOrganismsFromTurnoverNumber()
            % OUTPUT:
            %    Organisms:    A cell array of Organism from the BRENDA database
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            parameters = strjoin({self.userName , lower(self.password) }, ',');
            call.setOperationName(QName('http://soapinterop.org/', 'getOrganismsFromTurnoverNumber'));
            resultString = call.invoke( {parameters} );
            Organisms = self.parseArray(resultString);
        end               
        
        function results = getTurnoverNumber(self,varargin)
            % getTurnoverNumber according to the BRENDA SOAP api.
            % USAGE:
            %    results = BrendaClient.getTurnoverNumber(varargin)
            % OPTIONAL INPUTS:
            %    varargin:     A struct with any of the following fields, or parameter/value pairs with the following names.
            %                  At least one of the parameters/fields marked with * must be present.
            %                  Otherwise the return value is empty.
            %                   - ecNumber: The ecNumber from the BRENDA database*
            %                   - organism: The organism from the BRENDA database*
            %                   - turnoverNumber: The turnoverNumber from the BRENDA database
            %                   - turnoverNumberMaximum: The turnoverNumberMaximum from the BRENDA database
            %                   - substrate: The substrate from the BRENDA database
            %                   - commentary: The commentary from the BRENDA database
            %                   - ligandStructureId: The ligandStructureId from the BRENDA database
            %                   - literature: The literature from the BRENDA database
            % OUTPUT:
            %    results:    A struct with the following fields:
            %                  - ecNumber: The ecNumbers stored in the BRENDA database
            %                  - turnOverNumber: The turnOverNumbers stored in the BRENDA database
            %                  - turnOverNumberMaximum: The turnOverNumberMaximums stored in the BRENDA database
            %                  - substrate: The substrates stored in the BRENDA database
            %                  - commentary: The commentarys stored in the BRENDA database
            %                  - organism: The organisms stored in the BRENDA database
            %                  - ligandStructureId: The ligandStructureIds stored in the BRENDA database
            parser=inputParser();
            parser.addParameter('ecNumber','',@ischar);
            parser.addParameter('organism','',@ischar);
            parser.addParameter('turnoverNumber','',@ischar);
            parser.addParameter('turnoverNumberMaximum','',@ischar);
            parser.addParameter('substrate','',@ischar);
            parser.addParameter('commentary','',@ischar);
            parser.addParameter('ligandStructureId','',@ischar);
            parser.addParameter('literature','',@ischar);
            parser.parse(varargin{:})
            parameters = self.buildParamString(parser.Results,parser.UsingDefaults);
            import javax.xml.namespace.*;
            call = self.brendaService.createCall();
            call.setTargetEndpointAddress(java.net.URL(self.brendaURL));
            if isempty(parameters)
                parameters = strjoin({self.userName , lower(self.password) }, ',');
            else
                parameters = strjoin({self.userName , lower(self.password) , parameters}, ',');
            end
            call.setOperationName(QName('http://soapinterop.org/', 'getTurnoverNumber'));
            resultString = call.invoke( {parameters} );
            results = self.parseStruct(resultString);
        end 
    end
end


