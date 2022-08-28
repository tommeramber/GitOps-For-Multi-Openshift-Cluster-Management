# Install everything from scratch  
1. Install `argocd cli` locally - you can get it from here: https://argo-cd.readthedocs.io/en/stable/cli_installation/
0. Create a dedicated `multicluster-mgmt-argocd` namespace
```bash
oc create ns multicluster-mgmt-argocd
oc project multicluster-mgmt-argocd
```
1. Clone this repo
2. [Install Openshift-GitOps Operator via OperatorHub](https://github.com/tommeramber/ArgoCD-GitOps-Helm-Based-Multi-Cluster-Structure/tree/main/docs/InstallOperator)
3. Delete the default openshift-gitops namespace
```bash
oc delete gitopsservice.pipelines.openshift.io cluster
oc delete ns openshift-gitops
```
4. Deploy Argo instance in the `multicluster-mgmt-argocd` namespace and give its ServiceAccount `cluster-admin` permissions
```bash
oc apply -f argo-objects/argo/argocd.yaml
oc create sa argocd 
oc adm policy add-cluster-role-to-user cluster-admin -z argocd
oc delete appproject default
```
5. Retrieve kubeconfig from UI for the ServiceAccount
* User Management -> service accounts -> 3 dots next to user -> download kubeconfig
* Copy to server under /tmp/kubeconfig


6. Retrieve argo default admin password 
```bash
oc edit secret argocd-cluster
echo "<PASTE_SECRET_HERE>" |base64 -d
```
---
## Notes
> You should only have 1 argocd in your network that will manage multiple OCPs

> Add all the OCP clusters that this Argo will manage, including the one it runs on
---

# Add the central cluster to ArgoCD management
1. Login into argocd using cli as admin
```bash
argocd login argocd-server-xxx.XXXXXXX:443
```
2. Set context:
```bash
export KUBECONFIG=/tmp/kubeconfig
oc config get-clusters
oc config get-contexts
```
3. Add cluster
```bash
argocd cluster add --kubeconfig=/tmp/kubeconfig argocd --name=main-cluster --system-namespace=multicluster-mgmt-argocd
```

# Add a new cluster to ArgoCD
0. Create the `managed-by-argocd` namespace
```bash
oc create ns managed-by-argocd
oc project managed-by-argocd
```
1. Create ServiceAccount that your remote Argo will use
```base
oc create sa argocd
oc adm policy add-cluster-role-to-user cluster-admin -z argocd -n managed-by-argocd
```
2. Retrieve kubeconfig from UI for the sa
* User Management -> service accounts -> 3 dots next to user -> download kubeconfig
* Copy to server under /tmp/kubeconfig

3. Login into your remote argocd using cli as admin
```bash
argocd login argocd-server-xxx.XXXXXX:443
```
4. Set context:
```bash
export KUBECONFIG=/tmp/<ENV>-kubeconfig
oc config set-context <ENV> --cluster=XXXXXXXX:6443 --user=argocd
```
5. Add the cluster
```bash
argocd cluster add --kubeconfig=/tmp/<ENV>-kubeconfig <ENV> --system-namespace=managed-by-argocd
```
