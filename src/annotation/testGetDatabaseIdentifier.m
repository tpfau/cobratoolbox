function testGetDatabaseIdentifier()
%TESTGETDATABASEIDENTIFIER This function tests the getDataBaseIdentifier
%function.
%  WARNING! Since this function relies on a web service, it does nto work
%  if there is no internet connection, or if the Webserver is down.
%  In addition: Changes in the Webservice might lead to this function
%  failing in some tests.

global GET_DATABASEID_TESTING
global GET_DATABASEID_TESTING_POSITIONINPUT
global GET_DATABASEID_TESTING_LABELINPUT

%This should give a single response
[Id,Pattern] = getDataBaseIdentifier('HMDB',getRegistryURL);
assert(strcmp(Id,'hmdb'))
assert(strcmp(Pattern,'^HMDB\d{5}$'))

%This is not checking identifiers.org at all
[Id,Pattern] = getDataBaseIdentifier('HMDB','SomeRegistry');
assert(strcmp(Id,'HMDB'))
assert(strcmp(Pattern,'.*'))

GET_DATABASEID_TESTING = 1;
GET_DATABASEID_TESTING_POSITIONINPUT = '1';
[Id,Pattern] = getDataBaseIdentifier('cyc',getRegistryURL);
assert(strcmp(Id,'biocyc'))
assert(strcmp(Pattern,'^[A-Z-0-9]+(?<!CHEBI)(\:)?[A-Za-z0-9+_.%-]+$'));
%Reset the Position Input
GET_DATABASEID_TESTING_POSITIONINPUT = [];

[Id,Pattern] = getDataBaseIdentifier('kegg',getRegistryURL);
assert(strcmp(Id,'kegg'));
assert(strcmp(Pattern,'^([CHDEGTMKR]\d+)|(\w+:[\w\d\.-]*)|([a-z]{3,5})|(\w{2,4}\d{5})$'));

GET_DATABASEID_TESTING_LABELINPUT = 'Protein Data Bank';
[Id,Pattern] = getDataBaseIdentifier('db',getRegistryURL);
assert(strcmp(Id,'pdb'));
assert(strcmp(Pattern,'^[0-9][A-Za-z0-9]{3}$'));
%And Reset the global variables.
GET_DATABASEID_TESTING_LABELINPUT = [];
GET_DATABASEID_TESTING = [];

%Now, check whether the MetaNetX an kegg subselection with provided field work properly
[Id,Pattern] = getDataBaseIdentifier('MetaNetX',getRegistryURL,'annotatedField','reaction');
assert(strcmp(Id,'metanetx.reaction'));
assert(strcmp(Pattern,'^MNXR\d+$'));

[Id,Pattern] = getDataBaseIdentifier('kegg',getRegistryURL,'annotatedField','gene');
assert(strcmp(Id,'kegg.genes'));
assert(strcmp(Pattern,'^\w+:[\w\d\.-]*$'));

%And check that the right error gets thrown if the database is not
%available.
try
    getDataBaseIdentifier('blubb',getRegistryURL);
catch ME
    assert(strcmp(sprintf('%s not present in the registry (%s).\nPlease check the provided database identifier','blubb',getRegistryURL()),ME.message));
end

