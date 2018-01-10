# Azure-HDI-DistCP
Creates a HDInsight cluster then runs distcp remotely to copy data between blob and/or data lake (ADLS).  Distcp is ideal for 100 GB+ to 100TB+.  There are other tools like PowerShell, CLI 2.0, Azure Python SDK, ADLCopy and Azure Data Factory.  For really large sizes and/or millions of files distcp gets the job done quick and easy.  

## Service Principle
You will need a service principle for Azure Data Lake Store (ADLS) access.  See here to create one: https://github.com/AdamPaternostro/Azure-Create-HDInsight-Service-Principle

## Modify the HDIDistCP.json
Modify the parameters.  A unique cluster and storage account names are required (Azure wide unique).  Use the certificate data from the generated Service Principle.  Also, grant the service principle access within your ADLS resource.  

## Modify and run the distcp-copy.sh
Modify the parameters and run the script.

## Adding additional storage accounts
If you need to add additional storage accounts you will need to add them to the HDIDistCP.json (e.g. you would add the REMOVED.blob.core.windows.net item to your template)
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
## Estimating your data copy 
This is a way to get a ballpark estimate of your copy time.  This will depend on many factors like you distcp parameters, the number of files, the size of the files, etc... so, please use this as a general best case guideline.

| Description                 | Value   | Other |
| --------------------------- |--------:| ------|
| Amount of data to copy (TB) | 40      | |
| Amount of data to copy (GB) | 40000   | |
| Standard_DS5_v2 (Gbps)      | 12      | https://github.com/AdamPaternostro/Azure-VM-Network-Bandwidth  |
| Standard_DS5_v2 (GBps)      | 1.5     | |
| Number of Machines          | 5       | |
| Total GBps                  | 7.5     | |
| Total Seconds to Copy       | 5333.33 | |
| Total Minutes to Copy       | 88.89   | You need to add some overhead to this figure. I typically double for a SWAG. |

Things to consider:
* ADLS has a bandwidth limit (check you ADLS logs for throttling errors)
* Azure Blob storage has a bandwidth limit (check your storage for throttling errors)
* If you are getting throttled contact Azure support to see if the can raise your bandwidth)
* Please review: https://docs.microsoft.com/en-us/azure/data-lake-store/data-lake-store-copy-data-wasb-distcp
* Some Azure machines have their bandwidth published here: https://docs.microsoft.com/en-us/azure/virtual-machines/windows/sizes (or run my bandwidth test on this Github).

## Known issues
* Right now the cluster does not delete itself since the script is not testing when the distcp job is complete.  I am looking into enhancing the script.
* This is using a SSH username and password, you can modify to use a key. 
* You need to optimize your distcp parameters.  Make sure you do not create too many mappers and run out of memory.
