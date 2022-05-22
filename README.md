# Intro

# Prerequisites 
1. [Install the Openshift GitOps Operator](https://github.com/tommeramber/ArgoCD-GitOps-Helm-Based-Multi-Cluster-Structure/tree/main/docs/InstallOperator)
2. Add cluster-admin permission to the main Openshift-GitOps serviceAccount
> **Note!** From a security point of view, the main Openshift-GitOps instance is for infrastructure management purposes, which is equivalent to Openshift admin configuring the cluster.
```bash
$ oc adm policy add-cluster-role-to-user cluster-admin -z openshift-gitops-argocd-application-controller -n openshift-gitops
```
3. [Access the ArgoCD UI](https://github.com/tommeramber/ArgoCD-GitOps-Helm-Based-Multi-Cluster-Structure/tree/main/docs/LoginToArgo)
4. [Add the repository to ArgoCD](https://github.com/tommeramber/ArgoCD-GitOps-Helm-Based-Multi-Cluster-Structure/tree/main/docs/AddRepoToArgo)
5. Clone this repo and change the `values-<env>.yaml` files in the different components' directories based on your environment needs
6. Apply the following files based on your env (nocp, pocp, etc.)
```bash
$ cd ArgoCD-GitOps-Helm-Based-Multi-Cluster-Structure/argo-objects
$ oc apply -f projects
# oc apply -f applicationsets/<env> 
$ oc apply -f applicationsets/nocp #Example
```
---

# Architecture 
![architecture drawio](https://user-images.githubusercontent.com/60185557/169005408-61517f0c-eec3-451f-9497-8bce42122b44.png)

---

# Creating & Testing New Component
For each new component that you want to add to the cluster, you need to:
1. Decide in which upper-dir it should reside (core/apps/operators)
2. Generate a new helm chart for this component
```bash
$ helm create <NAME>
```
3. Create `values-<env>.yaml` for each environment you want - nocp, pocp, etc. with the proper variables for this component with correlation to this environment.
> The most important value is `required` that will define if the chart's objects should be deployed on this cluster or not.
4. Create in the `templates` dir the yaml files that this component is comprised of. Each such yaml file should start with `{{- if .Values.required }}` and end with `{{- end }}`
5. Run the following command in the directory where the files `Chart.yaml` and `values-<env>.yaml` are located, if it works, the chart is complete.
```bash
$ helm template . -f values-<env>.yaml
```
> If you made a change in one of the `values-<env>.yaml` files, test it in the same manner.

---

# Tree Structure
```
main
├── apps
│   ├── helm-operators
│   │   └── grafana
│   ├── metricbeat
│   └── trident
├── argo-objects
│   ├── applicationsets
│   │   └── nocp
│   │       ├── apps-applicationset.yaml
│   │       ├── core-applicationset.yaml
│   │       └── operators-applicationset.yaml
│   └── projects
│       ├── apps-project.yaml
│       ├── core-project.yaml
│       └── operators-project.yaml
├── core
│   ├── 500pods
│   │   ├── Chart.yaml
│   │   ├── README.md
│   │   ├── templates
│   │   │   └── job.yaml
│   │   └── values-nocp.yaml
│   ├── dnsforwarder
│   │   ├── Chart.yaml
│   │   ├── templates
│   │   │   └── dnsforwarder.yaml
│   │   └── values-nocp.yaml
│   ├── etcd-encryption
│   │   ├── Chart.yaml
│   │   ├── templates
│   │   │   └── apiserver.yaml
│   │   └── values-nocp.yaml
│   ├── jobs
│   │   ├── etcdbackup_cronjob
│   │   └── ldap-sync
│   ├── machineconfigs
│   │   ├── Chart.yaml
│   │   ├── templates
│   │   │   └── automatic-kubelet-reservation.yaml
│   │   └── values-nocp.yaml
│   ├── oauth
│   ├── project-bootstrap-template
│   ├── proxy
│   └── RBAC
│       ├── roles_and_bindings
│       ├── SCCs
│       └── serviceaccounts
└── operators
    ├── catalogsources
    ├── CRs-and-Subs
    │   ├── monitoring
    │   │   ├── Chart.yaml
    │   │   ├── templates
    │   │   │   └── cluster-monitoring-config.yaml
    │   │   └── values-nocp.yaml
    │   └── serverless
    │       └── serverless
    │           ├── Chart.yaml
    │           ├── templates
    │           │   └── subscription.yaml
    │           ├── values-nocp.yaml
    │           └── values-pocp.yaml
    └── imagecontentsourcepolicies

```
