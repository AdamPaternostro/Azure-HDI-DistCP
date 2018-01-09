# Azure-HDI-DistCP
Creates a HDInsight cluster then runs distcp remotely to copy data between blob and/or data lake (ADLS).

## Service Principle
You will need a service principle for Azure Data Lake Store (ADLS) access.  See here to create one: https://github.com/AdamPaternostro/Azure-Create-HDInsight-Service-Principle

## Modify the HDIDistCP.json
You should code in all the parameters.  A unique cluster and storage account names are required (Azure wide unique).  Use the certificate data from the generated Service Principle.  Also, please grant the service principle access within your ADLS resource.  

## Modify and run the distcp-copy.sh
Change the parameters and run the script.

## Known issues
Right now the cluster does not delete itself since the script is not testing when the distcp job is complete.  I am looking into enhancing the script.
