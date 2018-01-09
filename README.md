# Azure-HDI-DistCP
Creates a HDInsight cluster then runs distcp remotely to copy data between blob and/or data lake (ADLS).

## Service Principle
You will need a service principle for Azure Data Lake Store (ADLS) access.  See here to create one: https://github.com/AdamPaternostro/Azure-Create-HDInsight-Service-Principle

## Modify the HDIDistCP.json
Modify the parameters.  A unique cluster and storage account names are required (Azure wide unique).  Use the certificate data from the generated Service Principle.  Also, grant the service principle access within your ADLS resource.  

## Modify and run the distcp-copy.sh
Modify the parameters and run the script.

## Adding additional storage accounts
If you need to add additional storage accounts you will need to add them to the HDIDistCP.json (see second snippet below)
```
"storageProfile": {
    "storageaccounts": [
        {
            "name": "[concat(parameters('clusterStorageAccountName'),'.blob.core.windows.net')]",
            "isDefault": true,
            "container": "[parameters('clusterName')]",
            "key": "[listKeys(resourceId('Microsoft.Storage/storageAccounts', parameters('clusterStorageAccountName')), '2015-05-01-preview').key1]"
        },
        {
            "name": "<<REMOVED>>.blob.core.windows.net",
            "isDefault": false,
            "container": "blank",
            "key": "[listKeys('/subscriptions/<<REMOVED>>/resourceGroups/<<REMOVED>>/providers/Microsoft.Storage/storageAccounts/<<REMOVED>>', '2015-05-01-preview').key1]"
        }
    ]
},
```


## Known issues
Right now the cluster does not delete itself since the script is not testing when the distcp job is complete.  I am looking into enhancing the script.
This is using a SSH username and password, you can modify to use a key. 
