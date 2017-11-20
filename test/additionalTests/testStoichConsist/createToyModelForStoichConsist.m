function model = createToyModelForStoichConsist()
%createToyModelForStoichConsist creates a toy model for
%Stoichiometric consistency checks
% The model created looks as follows:
%
%
%   <-> A -----> B ---> C --> E <->
%        \       ^
%         \     /
%          -> 2 D 
%           
% This should be flagged as stoichiometrically inconsistent (in particular,
% A -> 2 D ; A -> B and D -> B leads to a stoichiometrically inconsistent
% subset (As A -> 2 B and A -> B are inconsistent, i.e. A, B and D are definitely inconsistent)
model = createModel();
%Reactions in {Rxn Name, MetaboliteNames, Stoichiometric coefficient} format
Reactions = {'R1',{'A','B'},[-1 1],-1000,1000;...
             'R2',{'A', 'D'},[-1 2],0,1000;...
             'R3',{'D','B'},[-1 1 ],0,1000;...
             'R4',{'B','C'},[-1 1],0,1000;...
             'R5',{'C','E'},[-1 1],0,1000;};
ExchangedMets = {'A','E'};
%Add Reactions
for i = 1:size(Reactions,1)
    %All reactions are irreversible
    model = addReaction(model,Reactions{i,1},'metaboliteList',Reactions{i,2},'stoichCoeffList',Reactions{i,3},'lowerBound',Reactions{i,4},'upperBound',Reactions{i,5});
end

%Add Exchangers
model = addExchangeRxn(model,ExchangedMets,-1000*ones(numel(ExchangedMets),1),1000*ones(numel(ExchangedMets),1));
model = changeObjective(model,'EX_E',1);