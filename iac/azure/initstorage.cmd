@ECHO OFF

SET RESOURCE_GROUP_NAME=tstate
SET STORAGE_ACCOUNT_NAME=tfstatestage1234567890
SET CONTAINER_NAME=tstate

REM Create resource group
call az group create --name %RESOURCE_GROUP_NAME% --location westeurope

REM Create storage account
call az storage account create --resource-group %RESOURCE_GROUP_NAME% --name %STORAGE_ACCOUNT_NAME% --sku Standard_LRS --encryption-services blob

REM Get storage account key
call az storage account keys list --resource-group %RESOURCE_GROUP_NAME% --account-name %STORAGE_ACCOUNT_NAME% --query [0].value -o tsv > tmpFile
SET /p ACCOUNT_KEY= < tmpFile
DEL tmpFile

REM Create blob container
call az storage container create --name %CONTAINER_NAME% --account-name %STORAGE_ACCOUNT_NAME% --account-key %ACCOUNT_KEY%

REM "storage_account_name: %STORAGE_ACCOUNT_NAME%"
REM "container_name: %CONTAINER_NAME%"
REM "access_key: %ACCOUNT_KEY%"

SET ARM_ACCESS_KEY=%ACCOUNT_KEY%