function [fbcVersion, groupsVersion] = getFBCAndgroupsVersions(modelSBML)
fbcEnabled = modelSBML.isPackageEnabled('fbc');
groupsEnabled = modelSBML.isPackageEnabled('groups');
if fbcEnabled
    fbcVersion = modelSBML.getPackageVersion('fbc');
else
    fbcVersion = -1;
end

if groupsEnabled
    groupsVersion = modelSBML.getPackageVersion('groups');
else
    groupsVersion = -1;
end