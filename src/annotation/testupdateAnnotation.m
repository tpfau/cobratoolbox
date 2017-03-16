function testupdateAnnotation( )
%TESTUPDATEANNOTATION Summary of this function goes here
%   Detailed explanation goes here
global UPDATE_ANNOTATION_TESTING
global UPDATE_ANNOTATION_TESTING_FAILFIELD
global UPDATE_ANNOTATION_USERINPUTFAILFIELD
global UPDATE_ANNOTATION_USERINPUTSUCCESSFIELD
global UPDATE_ANNOTATION_GET_DATABASE_INPUT

UPDATE_ANNOTATION_TESTING = 1;
UPDATE_ANNOTATION_GET_DATABASE_INPUT = 'kegg.reaction';
UPDATE_ANNOTATION_TESTING_FAILFIELD = 1;
UPDATE_ANNOTATION_USERINPUTFAILFIELD = 'bla';
UPDATE_ANNOTATION_USERINPUTSUCCESSFIELD = 'reaction';

%First, create a toy model.
model = createToyModelForAnnotations();

%Now, lets automatically update the R1 reaction with an annotation matching
% to KEGG reaction R00002
keggReactionID = 'R00002'
keggDBID = 'KEGG'
AnnotatedReaction = 'R1'; % This identifier is present both as gene and as Reaction
%First Test with failure
updateAnnotation(model,AnnotatedReaction,keggDBID,keggReactionID);

%Now, test without failure
UPDATE_ANNOTATION_TESTING_FAILFIELD = 0;
updateAnnotation(model,AnnotatedReaction,keggDBID,keggReactionID);


end

