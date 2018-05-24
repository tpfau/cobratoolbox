classdef BrendaClient < handle
    %BRENDACLIENT Summary of this class goes here
    %   Detailed explanation goes here
    
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
    end
    
end

