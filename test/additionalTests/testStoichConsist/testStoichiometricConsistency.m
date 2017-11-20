model = createToyModelForStoichConsist();

[SConsistentMetBool, SConsistentRxnBool, SInConsistentMetBool, SInConsistentRxnBool, unknownSConsistencyMetBool, unknownSConsistencyRxnBool] = findStoichConsistentSubset(model);

assert(~any(SConsistentMetBool(ismember(model.mets,{'A','B','D'}))));
assert(~any(SConsistentRxnBool(ismember(model.rxns,{'R1','R2','R3'}))));

[inform, m] = checkStoichiometricConsistency(model);

assert(inform == 0);