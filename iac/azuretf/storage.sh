az storage container create -n tfstate --account-name t6qemtbp4gxbw --account-key hrp0VhKtwcZAcE+u5WgOMsfvLNqbIZ/J0XZZ6hvoULt8A9WzswMCv+VNiMdzSYCOyfbNHzQUm9dVux8xpSzd7Q==
terraform init -backend-config="storage_account_name=t6qemtbp4gxbw" -backend-config="container_name=tfstate" -backend-config="access_key=hrp0VhKtwcZAcE+u5WgOMsfvLNqbIZ/J0XZZ6hvoULt8A9WzswMCv+VNiMdzSYCOyfbNHzQUm9dVux8xpSzd7Q==" -backend-config="key=codelab.microsoft.tfstate"

export TF_VAR_client_id=<service-principal-appid>
export TF_VAR_client_secret=<service-principal-password>

export ARM_CLIENT_ID=""
export ARM_CLIENT_SECRET=""
export ARM_SUBSCRIPTION_ID="82f8e28a-a01b-4dd3-a860-8c2354534e71"
export ARM_TENANT_ID="18de8207-6fe3-4572-a0c9-82d1ead85306"

