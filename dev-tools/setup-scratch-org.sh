sfdx force:org:create -f ./config/project-scratch-def.json --setdefaultusername &&
sfdx force:source:push &&
sfdx force:user:permset:assign --permsetname "Admin" &&
sfdx force:org:open 


# apply user permset
#sfdx force:user:permset:assign --permsetname "Standard" &&

# execute anon apex
# sfdx force:apex:execute -f ./config/setup.scratch.org.anonapex &&

# tetlow's csv plugin
# sfdx sampleData:import
