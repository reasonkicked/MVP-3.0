az ad sp create-for-rbac --name "mvp30spn-dev" --role contributor --scopes "/subscriptions/<subscription>" --json-auth

az aks get-credentials --resource-group <NazwaGrupyZasobów> --name <NazwaKlastra>

kubectl config current-context


az network bastion ssh --name <NazwaBastionu> --resource-group <NazwaGrupyZasobów> --auth-type ssh-key --username <TwojaNazwaUżytkownika> --ssh-key <ŚcieżkaDoKluczaSSH> --target-resource-id <IdentyfikatorZasobuVM>
kubectl get nodes
