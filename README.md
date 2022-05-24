# Intro
This project is a suggestion on who to use `ArgoCD` as your Central infrastructure & Configuration Management tool for Openshift & Kubernetes based environments by using `Openshift-GitOps` Operator and `Helm Charts`.

# The Idea - Everything is Helm
As the title suggests, in this project I define everything that we may want to configure on our Openshift clusters (Post-Install infrastructure configurations) as Helm charts. 

With `Helm` we can define multiple `values` files, that hold different variables for a specific chart, that upon deploying the chart Helm will "inject" into the yaml files.

The main advantage of incorporating ArgoCD with Helm charts is that we gain **flexibility**.

For each component (i.e. OAuth, Etcd, APIServer, Proxy, Ingress, etc.) , we have its different declarative yaml file/s that tell Openshift how it should work; **By using Helm we can manage multiple Openshift Clusters with different configurations from a single ArgoCD instance.**

## Example
You can take a look at the following component: [etcd-encryption](https://github.com/tommeramber/ArgoCD-GitOps-Helm-Based-Multi-Cluster-Structure/tree/main/core/etcd-encryption) which defines if the etcd of a specific cluster should be encrypted or not.

For each cluster we have (dev-ocp, test-ocp, prod-ocp, etc.) `values-<env>.yaml` in the specific chart directory, that holds the relevant values for this environment's needs. The most important value in this file is `required`.

Each yaml file in this chart starts with a Helm `if` statement that checks if this `required` field is set to `true`, and only if it does, it will create it with the values from the specific `values-<env>.yaml` file.

In many cases you'll take existing charts/standard apps with multiple yaml files, and you'll want to apply the `if` statement to the beginning of all of them with a one-liner and the closing `end` to the end of them all; Run the following command to make it reality:
```bash
for file in /PATH/TO/CHART/templates/*; do \
echo '{{- end }}' >> $file ;
sed -i '1i{{- if .Values.required}}' $file ;
done
```

## Take advantage of ApplicationSets
Argo ApplicationSet is an extension to the Kubernetes API provided by the ArgoCD operator.

Argo ApplicationSet tells Argo how to create Argo Application based on a template.

Using ApplicationSet object, we point ArgoCD to directories that hold our components. It will create Argo Application for each of our charts, based on the `values-<env>.yaml` file with for our specific environment.

## Non-Cascade delete
From the [ArgoCD site](https://argo-cd.readthedocs.io/en/stable/user-guide/app_deletion/)
Apps can be deleted with or without a cascade option. A cascade delete, deletes both the app and its resources, rather than only the app. 
To perform a non-cascade delete, make sure your applicationsets does not have the following lines:
```yaml
metadata:
  finalizers:
    - resources-finalizer.argocd.argoproj.io
```
In this project non of our applicationsets has these lines because its purpose is Cluster Management and most of the objects that this Argo manges **should not/cannot be deleted by any means**

## Directories Structure 
> This separation is only for convenience and based on my perspective, it is completely flexible and can be edited based on your needs, but don't forget to edit the [ApplicationSets in the following dir](https://github.com/tommeramber/ArgoCD-GitOps-Helm-Based-Multi-Cluster-Structure/tree/main/argo-objects/applicationsets)

We have 4 main directories relevant for this solution;
1. [Core](https://github.com/tommeramber/ArgoCD-GitOps-Helm-Based-Multi-Cluster-Structure/tree/main/core) - Every built-in component in Openshift/Kubernetes 
2. [Operators](https://github.com/tommeramber/ArgoCD-GitOps-Helm-Based-Multi-Cluster-Structure/tree/main/operators) - Everything related to OLM operators, including imageContentSourcePolicies (ICSP), catalogSources , Subscriptions, CustomResources relevant for the specific Operator, etc. 
3. [Apps](https://github.com/tommeramber/ArgoCD-GitOps-Helm-Based-Multi-Cluster-Structure/tree/main/apps) - Everything extra i.e. PersistentStorage 3rd Party CSI (e.g. Trident), helm operators / deployments for PaaS teams (e.g. Grafana, SealedSecrets, metricbeat, etc.)
4. [Argo-Objects](https://github.com/tommeramber/ArgoCD-GitOps-Helm-Based-Multi-Cluster-Structure/tree/main/argo-objects) - **This is the main directory that we are going to use with this project**; It holds 2 things we must work with in Argo - 

   4.1. **Argo Projects** - Logical separation to envrionments inside Argo; It can be used purely for organizing your apps and you can grant access to other teams in your organization to specific projects. In our case there is going to be a project per repo dir (core, apps, operators).
   
   4.2. **Argo ApplicationSets** - Points ArgoCD to directories that holds our components, and it will create Argo Application for each of our charts, based on the `values-<env>.yaml` file with for our specific environment. In our case there is going to be an applicationset per repo dir (core, apps, operators).


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
3. Create `values-<env>.yaml` for each environment you want - dev-ocp, pocp, etc. with the proper variables for this component correlated to this environment.
> The most important value is `required` that will define if the chart's objects should be deployed on this cluster or not.
4. Create in the `templates` dir the yaml files that this component comprises. Each such yaml file should start with `{{- if .Values.required }}` and end with `{{- end }}`
5. Run the following command in the directory where the files `Chart.yaml` and `values-<env>.yaml` are located, if it works, the chart is complete.
```bash
$ helm template . -f values-<env>.yaml
```
> If you made a change in one of the `values-<env>.yaml` files, test it in the same manner.

---

# Tree Structure
```
.
├── apps
│   ├── helm-operators
│   │   ├── grafana
│   │   └── sealedsecerts
│   ├── metricbeat
│   └── trident
├── argo-objects
│   ├── applicationsets
│   │   └── dev-ocp
│   │       ├── apps.yaml
│   │       ├── core.yaml
│   │       └── operators.yaml
│   └── projects
│       ├── apps.yaml
│       ├── core.yaml
│       └── operators.yaml
├── core
│   ├── 500pods
│   ├── dnsforwarder
│   ├── etcd-encryption
│   │   ├── Chart.yaml
│   │   ├── templates
│   │   │   └── apiserver.yaml
│   │   └── values-dev-ocp.yaml
│   ├── jobs
│   │   ├── etcdbackup_cronjob
│   │   └── ldap-sync
│   ├── machine-config-pools
│   ├── machineconfigs
│   ├── oauth
│   │   ├── Chart.yaml
│   │   ├── files
│   │   │   ├── create_htpasswd.sh
│   │   │   └── htpasswd
│   │   ├── templates
│   │   │   ├── htpasswd-secret.yaml
│   │   │   └── oauth.yaml
│   │   └── values-dev-ocp.yaml
│   ├── project-bootstrap-template
│   ├── proxy
│   │   ├── Chart.yaml
│   │   ├── files
│   │   │   ├── ca.crt
│   │   │   ├── ca.key
│   │   │   ├── create-ca.sh
│   │   │   └── csr_answer.txt
│   │   ├── templates
│   │   │   ├── proxy.yaml
│   │   │   └── user-ca-bundle.yaml
│   │   └── values-dev-ocp.yaml
│   ├── rbac
│   │   ├── self-provisioner
│   │   │   ├── Chart.yaml
│   │   │   ├── templates
│   │   │   │   └── disable-self-provisioners.yaml
│   │   │   └── values-dev-ocp.yaml
│   │   └── serviceaccounts
│   └── scc
└── operators
    ├── catalogsources
    ├── imagecontentsourcepolicies
    └── subs-and-customresources
        ├── gatekeeper
        │   ├── Chart.yaml
        │   ├── templates
        │   │   ├── gatekeeper-instance.yaml
        │   │   └── subscription.yaml
        │   └── values-dev-ocp.yaml
        └── monitoring
            ├── Chart.yaml
            ├── templates
            │   └── cluster-monitoring-config.yaml
            └── values-dev-ocp.yaml
```


# Tips & Tricks

1. [IgnoreExtraneous](https://github.com/tommeramber/ArgoCD-GitOps-Helm-Based-Multi-Cluster-Structure/tree/main/docs/IgnoreExtraneous)
