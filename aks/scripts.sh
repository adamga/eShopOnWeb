az aks show -g <resource-group> -n <cluster-name> --query addonProfiles.azureKeyvaultSecretsProvider.identity.clientId -o tsv

# az identity create -g <resource-group> -n <identity-name> 
# az vmss identity assign -g <resource-group> -n <agent-pool-vmss> --identities <identity-resource-id>
# az vm identity assign -g <resource-group> -n <agent-pool-vm> --identities <identity-resource-id>




# set policy to access keys in your key vault
az keyvault set-policy -n <keyvault-name> --key-permissions get --spn <identity-client-id>
# set policy to access secrets in your key vault
az keyvault set-policy -n <keyvault-name> --secret-permissions get --spn <identity-client-id>
# set policy to access certs in your key vault
az keyvault set-policy -n <keyvault-name> --certificate-permissions get --spn <identity-client-id>

# This is a SecretProviderClass example using user-assigned identity to access your key vault
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: azure-kvname-user-msi
spec:
  provider: azure
  parameters:
    usePodIdentity: "false"
    useVMManagedIdentity: "true"          # Set to true for using managed identity
    userAssignedIdentityID: <client-id>   # Set the clientID of the user-assigned managed identity to use
    keyvaultName: <key-vault-name>        # Set to the name of your key vault
    cloudName: ""                         # [OPTIONAL for Azure] if not provided, the Azure environment defaults to AzurePublicCloud
    objects:  |
      array:
        - |
          objectName: secret1
          objectType: secret              # object types: secret, key, or cert
          objectVersion: ""               # [OPTIONAL] object versions, default to latest if empty
        - |
          objectName: key1
          objectType: key
          objectVersion: ""
    tenantId: <tenant-id>                 # The tenant ID of the key vault


    # This is a sample pod definition for using SecretProviderClass and the user-assigned identity to access your key vault
kind: Pod
apiVersion: v1
metadata:
  name: busybox-secrets-store-inline-user-msi
spec:
  containers:
    - name: busybox
      image: k8s.gcr.io/e2e-test-images/busybox:1.29-1
      command:
        - "/bin/sleep"
        - "10000"
      volumeMounts:
      - name: secrets-store01-inline
        mountPath: "/mnt/secrets-store"
        readOnly: true
  volumes:
    - name: secrets-store01-inline
      csi:
        driver: secrets-store.csi.k8s.io
        readOnly: true
        volumeAttributes:
          secretProviderClass: "azure-kvname-user-msi"




