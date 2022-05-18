```bash
oc adm policy add-cluster-role-to-user cluster-admin -z openshift-gitops-argocd-application-controller -n openshift-gitops
```


argo
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
├── operators
│   ├── catalogsources
│   ├── CRs-and-Subs
│   │   ├── monitoring
│   │   │   ├── Chart.yaml
│   │   │   ├── templates
│   │   │   │   └── cluster-monitoring-config.yaml
│   │   │   └── values-nocp.yaml
│   │   └── serverless
│   │       └── serverless
│   │           ├── Chart.yaml
│   │           ├── templates
│   │           │   └── subscription.yaml
│   │           ├── values-nocp.yaml
│   │           └── values-pocp.yaml
│   └── imagecontentsourcepolicies

