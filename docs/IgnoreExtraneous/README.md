Based on the following [Github case](https://github.com/argoproj/argo-cd/issues/5792)

For some components being deployed, Argo add tags to unrelated components that the infrastructure is responsiable for, and the sync status of the entire app will be `Out-of-sync (Prune Required)`

Example:

