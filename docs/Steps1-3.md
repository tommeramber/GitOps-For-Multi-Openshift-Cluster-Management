# Install everything from scratch  

## Step 1 - Install operator & Prerequists 
1. Install `argocd cli` locally - you can get it from here: https://argo-cd.readthedocs.io/en/stable/cli_installation/
2. Login to main/central cluster
3. Install openshift-gitops operator
4. Delete Default objects : (just a personal preference)
```bash
oc delete argocd instance -n openshift-gitops
oc delete appproject default
```
3. Create Argocd instance, and login using `argocd` CLI:
```bash
oc apply -f GitOps-For-Multi-Openshift-Cluster-Management/argo-objects/argo/argocd.yaml
ADMIN_INITIAL_SECRET=$(oc -n openshift-gitops extract secret/argocd-cluster --to=-)
ARGO_ROUTE=$(oc -n openshift-gitops get route argocd-server -o jsonpath="{.status.ingress[].host}")
argocd --insecure --grpc-web login $ARGO_ROUTE:443 --username admin --password $ADMIN_INITIAL_SECRET
argocd cluster list 
# optional - change the default password
```
> Note! By default, the operator links the openshift oauth to argocd using dex

## Step 2 - Add external clusters to ArgoCD 
> Run on every cluster you want to manage with argocd
> You need to run the same process on the main/central cluster so it will be managed like all other clusters
```bash
oc login ... # connect to external cluster
# You need to stay logged in to the argocd server using the argocd cli thouought this process
SERVER_API=$(oc whoami --show-server)
SERVER_NAME=$(echo $SERVER_API | awk -F'api.' '{print $2}' | awk -F'.' '{print $1}')

oc create ns openshift-gitops
oc project openshift-gitops
oc create sa argocd
oc adm policy add-cluster-role-to-user cluster-admin -z argocd 
TOKEN=`oc extract $(oc get secret -o name | grep argocd-token ) --to=- --keys=token`

# The following commands will generate the $SERVER_NAME-kubeconfig4argocd file for us
oc config --kubeconfig=$SERVER_NAME-kubeconfig4argocd set-cluster $SERVER_NAME --server=$SERVER --insecure-skip-tls-verify=true
oc config --kubeconfig=$SERVER_NAME-kubeconfig4argocd set-context $SERVER_NAME --cluster=$SERVER_NAME 
oc config --kubeconfig=$SERVER_NAME-kubeconfig4argocd set-credentials $SERVER_NAME argocd --token=$TOKEN
oc config --kubeconfig=$SERVER_NAME-kubeconfig4argocd set-context $SERVER_NAME --user=argocd --namespace=openshift-gitops
oc config get-contexts --kubeconfig $SERVER_NAME-kubeconfig4argocd

export KUBECONFIG=$(pwd)/$SERVER_NAME-kubeconfig4argocd
oc config --kubeconfig=$SERVER_NAME-kubeconfig4argocd use-context $SERVER_NAME
argocd cluster add $SERVER_NAME
argocd cluster list
export KUBECONFIG=""
```
