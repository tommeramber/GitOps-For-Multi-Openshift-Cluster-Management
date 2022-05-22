# Intro
This project is a suggestion on who to use `ArgoCD` as your Central infrastructure & Configuration Management tool for Openshift & Kubernetes based envrionments by using `Openshift-GitOps` Operator and `Helm Charts`.

# The Idea - Everything is Helm
As the title suggests, in this project I define everything that we may want to configure on our Openshift clusters (Post-Install infrastructure configurations) as Helm charts. 

With `Helm` we can define multiple `values` files, that holds different varaibles for a specific chart, that uppon deploying the chart Helm will "inject" into the yaml files.

The maing advantage of incoorporating ArgoCD with Helm charts is that we gain **flexability**.

For each component (i.e. OAuth, Etcd, APIServer, Proxy, Ingress, etc.) , we have its different decelrative yaml file/s that tells Openshift how it should work; **By using Helm we can manage multiple Openshift Clusters with different configurations from a single ArgoCD instance.**

## Example
You can take a look at the following component: [etcd-encryption](https://github.com/tommeramber/ArgoCD-GitOps-Helm-Based-Multi-Cluster-Structure/tree/main/core/etcd-encryption) that defines if the etcd of a specific cluster should be encrypted or not.

For each cluster we have (dev-ocp, test-ocp, prod-ocp, etc.) `values-<env>.yaml` in the specific chart directory, that holds the relevant values for this environment needs. The most important value in this file is `required`.

Each yaml file in this chart starts with an Helm `if` statement that checks if this `required` field is set to `true`, and only if it does, it will create it with the values from the specific `values-<env>.yaml` file.

## Take advantage of ApplicationSets
Argo ApplicationSet is an extention to the Kubernetes API provided by the ArgoCD operator.

Argo ApplicationSet tells Argo how to create Argo Application based on a template.

By using ApplicationSet object, we point ArgoCD to directories that holds our components, and it will create Argo Application for each of our charts, based on the `values-<env>.yaml` file with for our specific environment.

## Directories Structure 

# TODO
We have 4 main directories relevant for this solution;
1. [Argo-Objects](https://github.com/tommeramber/ArgoCD-GitOps-Helm-Based-Multi-Cluster-Structure/tree/main/argo-objects)
2. [Core](https://github.com/tommeramber/ArgoCD-GitOps-Helm-Based-Multi-Cluster-Structure/tree/main/core)
3. [Operators](https://github.com/tommeramber/ArgoCD-GitOps-Helm-Based-Multi-Cluster-Structure/tree/main/operators)
4. [Apps](https://github.com/tommeramber/ArgoCD-GitOps-Helm-Based-Multi-Cluster-Structure/tree/main/apps)


# Instructions 
1. [Install the Openshift GitOps Operator](https://github.com/tommeramber/ArgoCD-GitOps-Helm-Based-Multi-Cluster-Structure/tree/main/docs/InstallOperator)
2. Add cluster-admin permission to the main Openshift-GitOps serviceAccount
> **Note!** From a security point of view, the main Openshift-GitOps instance is for infrastructure management purposes, which is equivalent to Openshift admin configuring the cluster.
```bash
$ oc adm policy add-cluster-role-to-user cluster-admin -z openshift-gitops-argocd-application-controller -n openshift-gitops
```
3. [Access the ArgoCD UI](https://github.com/tommeramber/ArgoCD-GitOps-Helm-Based-Multi-Cluster-Structure/tree/main/docs/LoginToArgo)
4. [Add the repository to ArgoCD](https://github.com/tommeramber/ArgoCD-GitOps-Helm-Based-Multi-Cluster-Structure/tree/main/docs/AddRepoToArgo)
5. Clone this repo and change the `values-<env>.yaml` files in the different components' directories based on your environment needs
6. Apply the following files based on your env (dev-ocp, pocp, etc.)
```bash
$ cd ArgoCD-GitOps-Helm-Based-Multi-Cluster-Structure/argo-objects
$ oc apply -f projects
# oc apply -f applicationsets/<env> 
$ oc apply -f applicationsets/dev-ocp #Example
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
3. Create `values-<env>.yaml` for each environment you want - dev-ocp, pocp, etc. with the proper variables for this component with correlation to this environment.
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
│   │   └── dev-ocp
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
│   │   └── values-dev-ocp.yaml
│   ├── dnsforwarder
│   │   ├── Chart.yaml
│   │   ├── templates
│   │   │   └── dnsforwarder.yaml
│   │   └── values-dev-ocp.yaml
│   ├── etcd-encryption
│   │   ├── Chart.yaml
│   │   ├── templates
│   │   │   └── apiserver.yaml
│   │   └── values-dev-ocp.yaml
│   ├── jobs
│   │   ├── etcdbackup_cronjob
│   │   └── ldap-sync
│   ├── machineconfigs
│   │   ├── Chart.yaml
│   │   ├── templates
│   │   │   └── automatic-kubelet-reservation.yaml
│   │   └── values-dev-ocp.yaml
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
    │   │   └── values-dev-ocp.yaml
    │   └── serverless
    │       └── serverless
    │           ├── Chart.yaml
    │           ├── templates
    │           │   └── subscription.yaml
    │           ├── values-dev-ocp.yaml
    │           └── values-pocp.yaml
    └── imagecontentsourcepolicies

```


# Tips & Tricks

1. [IgnoreExtraneous](https://github.com/tommeramber/ArgoCD-GitOps-Helm-Based-Multi-Cluster-Structure/tree/main/docs/IgnoreExtraneous)
