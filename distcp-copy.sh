##########################################
# Create HDInsight cluster
##########################################
# Login to Azure
# Create resource group
# Create HDI cluster via ARM template
# Run the script to copy the data
# Delete the reource group (pending, this needs to wait until the distcp is complete)

# The location must match the region of your HDInsight cluster
# The service principle here does not need to be the service principle used for your HDInsight cluster
location="eastus2"
subscriptionId="<<REMOVED>>"
resourceGroupName="HDIDistCP"
deploymentName="HDIDistCP"
templateFilePath="HDIDistCP.json"
servicePrinciple="<<REMOVED>> e.g. must be in https form => https://adam-service-principle.com"
servicePrinciplePassword="<<REMOVED>>"
servicePrincipleTenant="<<REMOVED>>.onmicrosoft.com"
sshPassword="<<REMOVED>>"
sshServer="<<REMOVED>> e.g. adampaternostro01-ssh.azurehdinsight.net"
sshLogin="<<REMOVED>>  e.g. sshuser@adampaternostro01-ssh.azurehdinsight.net"


# Login (service principle must be a subscription contributor or specific permissions set)
az login --service-principal -u $servicePrinciple -p $servicePrinciplePassword --tenant $servicePrincipleTenant

# Select your subscription
az account set --subscription $subscriptionId

# Create a resource group
az group create --name $resourceGroupName --location $location

# Deploy the ARM template
az group deployment create --name $deploymentName --resource-group $resourceGroupName --template-file $templateFilePath


##########################################
# SSH (Run distcp remotely)
# You can change this to use SSH keys (generate the keys on the client machine)
##########################################
# TODO: Only install once the client machine (the one that is running this script)
# sudo apt-get install sshpass

# TODO: Only add once (for each time you create the cluster)
# This skips the prompt of adding the machine which can stop the script for input
ssh-keyscan $sshServer >> ~/.ssh/known_hosts

# Not needed to run script just a sample
# Login with password (you can also do ssh keys)
# sshpass -p $sshPassword ssh -o StrictHostKeyChecking=no $sshLogin

# Start copy (use nohup in case you get disconnected)
# Sample Data Lake (ADLS) to ADLS (TODO: change this for your copy)
sshpass -p $sshPassword ssh -o StrictHostKeyChecking=no $sshLogin 'nohup time hadoop distcp -Ddistcp.dynamic.max.chunks.ideal=10000 -Ddistcp.dynamic.max.chunks.tolerable=10000 -Dmapreduce.fileoutputcommitter.algorithm.version=2 -Ddistcp.dynamic.recordsPerChunk=100 -Djava.io.tmpdir=. -overwrite -strategy dynamic -m 200 -bandwidth 200 adl://<<REMOVED>>.azuredatalakestore.net/mysource  adl://<<REMOVED>>.azuredatalakestore.net/mydest > distcplog_1.out 2>&1 &'

# Sample Blob to ADLS (TODO: change this for your copy)
sshpass -p $sshPassword ssh -o StrictHostKeyChecking=no $sshLogin 'nohup time hadoop distcp -Ddistcp.dynamic.max.chunks.ideal=10000 -Ddistcp.dynamic.max.chunks.tolerable=10000 -Dmapreduce.fileoutputcommitter.algorithm.version=2 -Ddistcp.dynamic.recordsPerChunk=100 -Djava.io.tmpdir=. -overwrite -strategy dynamic -m 200 -bandwidth 200 wasb://mysourcecontainer@<<REMOVED>>.blob.core.windows.net/  adl://<<REMOVED>>.azuredatalakestore.net/myblolbdest > distcplog_2.out 2>&1 &'


##########################################
# Clean up (this deletes the HDIcluster which has an associated storage account)
##########################################
# Need to wait until the processes are done (TODO: how to monitor this? cURL command to Ambari?)
# az group delete --yes --name $resourceGroupName


