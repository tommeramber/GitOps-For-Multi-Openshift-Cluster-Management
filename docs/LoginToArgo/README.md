```bash
$ oc -n multicluster-mgmt-argocd extract secret/argocd-cluster --to=-
```
Copy the output and use it for login to the ArgoCD UI

```bash
$ echo https://$(oc get route -n multicluster-mgmt-argocd argocd-server -o json | jq -r '.spec.host')
```
![Screenshot from 2022-05-22 10-48-52](https://user-images.githubusercontent.com/60185557/169684787-f20db9fe-544d-442d-931c-7bdc6ba6c6d2.png)
