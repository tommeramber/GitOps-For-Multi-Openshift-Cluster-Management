Based on the following [Github case](https://github.com/argoproj/argo-cd/issues/5792)

For some components being deployed, Argo add tags to unrelated components that the infrastructure is responsiable for, and the sync status of the entire app will be `Out-of-sync (Prune Required)`

Example:
![Screenshot from 2022-05-22 14-45-58](https://user-images.githubusercontent.com/60185557/169693813-80669355-c14b-468c-ada9-393edcfa2f7a.png)
![Screenshot from 2022-05-22 14-46-03](https://user-images.githubusercontent.com/60185557/169693815-a9c91f94-fca2-41b2-b290-4f761aac68a0.png)

In this case, we can add the two annotations to the relevant component that causes Openshift to recognize the extraneous object as managed by Argo:
![Screenshot from 2022-05-22 14-47-01](https://user-images.githubusercontent.com/60185557/169693819-07bcf296-eeac-46cf-9724-135f26c028a8.png)
![Screenshot from 2022-05-22 14-48-00](https://user-images.githubusercontent.com/60185557/169693825-2dd81859-f6d0-4c13-aba6-dc6a3bac1f9a.png)

And we can see that the Sync status is getting fixed as required.
![Screenshot from 2022-05-22 14-48-24](https://user-images.githubusercontent.com/60185557/169693831-b21f9fe6-6273-4183-be69-f80f952535c8.png)
![Screenshot from 2022-05-22 14-48-24](https://user-images.githubusercontent.com/60185557/169693840-62822f95-e23b-4273-84a0-ff841163a3ba.png)

