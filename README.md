
# Prerequisites 
1. Install the Openshift GitOps Operator
![1](https://user-images.githubusercontent.com/60185557/169025130-e35e1306-f0d3-4d83-8162-4eee279e315c.png)
![2](https://user-images.githubusercontent.com/60185557/169025152-7267595a-e723-4d9b-8854-444e67150541.png)
![3](https://user-images.githubusercontent.com/60185557/169025164-d9bd4eeb-6342-4f0f-a03f-dad1b5d1f1dd.png)
![4](https://user-images.githubusercontent.com/60185557/169025168-f7a81c15-14c1-4cb3-a852-34a7da9ac285.png)

3. Add cluster-admin permissions to the main Openshift-GitOps serviceAccount
> Note! From a security point of view, the main Openshift-GitOps instance is for infrastructure management purposes, which is equivalent to Openshift admin configuring the cluster.
```bash
oc adm policy add-cluster-role-to-user cluster-admin -z openshift-gitops-argocd-application-controller -n openshift-gitops
```

# Architecture 
![architecture drawio](https://user-images.githubusercontent.com/60185557/169005408-61517f0c-eec3-451f-9497-8bce42122b44.png)


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
