function GeneAssoc = createGeneAssociation(model,headnode)

if isa(headnode,'LiteralNode')
    GeneAssoc = org.sbml.jsbml.ext.fbc.GeneProductRef();
    id = headnode.getID();
    GeneAssoc.setGeneProduct(model.genes(str2num(id)));
    return
end

if isa(headnode,'AndNode')
    GeneAssoc = org.sbml.jsbml.ext.fbc.And();
    for i = 1:numel(headnode.children)
        GeneAssoc.addChild(createGeneAssociation(model,headnode.children(i)));
    end
end

if isa(headnode,'OrNode')
    GeneAssoc = org.sbml.jsbml.ext.fbc.Or();
    for i = 1:numel(headnode.children)
        GeneAssoc.addChild(createGeneAssociation(model,headnode.children(i)));
    end
end
