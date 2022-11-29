# A Step Towards GitOps with ArgoCD. 

Using Kubernetes to deploy your application has significant advantages such as flexible scaling, managing distributed applications, and controlling different versions of the application. Kubernetes brings a lot of benefits, but it also introduces new problems As your deployment landscape becomes more complex, there is a growing need to have all configurations templatized. In order to increase the velocity of software deployment, Continuous Integration and Continuous Deployment (CI/CD) was introduced. CI/CD systems are usually highly abstracted to provide version control, change logging, and rollback functionality. One popular approach is GitOps. 

GitOps is a software development practice that relies on a Git repository as its single source of truth. Descriptive configurations are committed to Git, which is then used to create continuous delivery environments. All aspects of the environment are defined via the Git repository; there are no standalone scripts or manual setups.

The GitOps process begins with a pull request. A new configuration version is introduced via pull requests, merged with the main branch in the Git repository, and then automatically deployed. Throughout the development process, the Git repository contains detailed records of all changes, including all environmental details. 

Several tools on Kubernetes use Git as a focal point for DevOps processes. As part of this tutorial, we will look at Argo CD, an open-source content delivery tool based on GitOps principles, which pulls Kubernetes cluster configurations from GitHub.
When changes are made to your GitHub repository, Argo CD automatically synchronizes and deploys your application. Manages an application's deployment and lifecycle, providing solutions for version control, configurations, and application definitions in Kubernetes environments, and organizing complex data with an easy-to-use user interface. A variety of Kubernetes manifests are supported, including JSONnet, Kustomize applications, Helm charts, and YAML/json files, as well as webhook notifications from GitHub, GitLab, and Bitbucket.


In this guide, you will learn how to implement a continuous delivery (CD) workflow for Kubernetes development, using GitOps practices and ArgoCD. The process will be demonstrated using the ArgoCD UI and the Declarative Approach.

## Prerequisites

This guide will be a step-by-step tutorial. To follow along, be sure to have the following:

* **Docker:** To install Docker on your local machine, follow the [download instructions](https://www.docker.com/get-started/).

* **Kubectl:**  To install Kubectl on your local machine, follow the [download instructions](https://kubernetes.io/docs/tasks/tools/).

* **Kubernetes cluster:**  To install Kubernetes on your local machine, follow the [download instructions](https://kubernetes.io/docs/tasks/tools/).

* ** Github Account:** To get started with GitHub, follow these [instruction](https://docs.github.com/en/get-started/signing-up-for-github/signing-up-for-a-new-github-account). 




 






![Architectural Diagram of ArgoCD Deployment]()


## Deploying ArgoCD to a Kubernetes cluster.

The first step is to create a namespace in the Kubernetes cluster. It will establish a separate place in your Kubernetes cluster for the ArgoCD resources to be deployed into. To do so, run
the following commands on the command line. 

```
Kubectl create namespace argocd
```

After you have created the namespace the next step is to deploy the argoCD components into the namespace. To do so run the following commands.

```
Kubectl apply -f -n argocd https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml 
```
After deploying the ArgoCD deployment into your cluster, you need to verify the deployment. To do this, run the following commands.
```
Kubectl get pods -n argocd
```

![ArgoCD components running the cluster]()

Pods for ArgoCD components have been deployed in your cluster. If any of these pods are in the "Pending" state, run the command again in a couple of seconds to confirm that they have been created.

To access the ArgoCD UI after verifying deployment, you will need to forward traffic to the ArgoCD server. However, before forwarding traffic, you must first obtain the password, which will be in base64 format and used to access the ArgoCD UI. To accomplish this, run the following commands if you're using a Mac or Linux machine. 

```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -D; echo
```
If you're using a Windows machine, use the following commands to get the password and decode, [check](https://www.base64decode.org/). 

```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}"
```
Make sure you store this password securely, as it will be used to gain access to your ArgoCD UI. 

After you have gotten your password, the next step is to forward traffic to the Argocd server in the Kubernetes cluster. To do this, run the following command to get the server name. 

```
Kubectl get all -n argocd

```

![ArgoCD Deployment ]()

After getting the name of the server, forward traffic to it to be able to access the ArgoCD UI. To do this, run the following commands.

```
kubectl port-forward service/argocd-server -n argocd 8085:80
```

![Port-forward session]()

In your browser, navigate to `http://local:8085` or `http://Your-Server-Ip/8085` if you're following on a cloud machine.

![ArgoCD Login Page]()

Note: If you receive the message "Your connection is not private,"  ignore it and proceed. The reason for this is that Argocd uses a self-signed certificate, which is not trusted by your browser. 

Now sign in with the username `Admin` and the password you saved, then click on the sign-in button. 


![ArgoCD Home Page]()

## Deploying to Application Kubernetes Cluster with ArgoCD UI

ArgoCD is now installed in your Kubernetes cluster; the next step is to demonstrate its capabilities using a basic application.

To begin, you will require an application to deploy to the cluster. For this guide, a [GitHub repository](https://github.com/segunjkf/Argocd-demo) has been created, so feel free to fork it, or use a repository containing a Kubernetes manifest of your choice. The configuration below contains a deployment named 'argocd' and two replicas, including a DockerHub image named 'kaytheog/argocd:latest' that listens on port 80 and is hosted on Github.

```
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: argocd
  name: argocd
spec:
  replicas: 2
  selector:
    matchLabels:
      app: argocd
  strategy: {}
  template:
    metadata:
      labels:
        app: argocd
    spec:
      containers:
      - image: kaytheog/argocd:latest
        name: argocd
        ports:
        - containerPort: 80

---
apiVersion: v1
kind: Service
metadata:
  name: "argocd-service"
  labels:
    app: "argocd-service"
spec:
  ports:
  - name: argocd
    port: 80
  selector:
    app: argocd

``` 

On the browser In web UI, click on create Application or New app and fill in the following:

*Application Name*: This is the name of the ArgoCD application you want to create. You can name it anything you want but in this guide, it is going to be called `argocd-demo`.
 
*Sync Policy*:This determines how ArgoCD will function. There are two options: automatic and manual. ArgoCD automatically syncs to the cluster whenever a change is made to the source of truth Git, whereas manual changes must be manually synced into the cluster. Set this to 'Automatic.'

*Source*: This is the source of truth. Set this to the URL of the Git repository you forked.

* Cluster Url*: This refers to the URL of the Kubernetes cluster we are connecting to. Select https://kubernetes.default.svc.

* Namespace*: This refers to the namespace in which you will be deploying your application. Set this to `default`. 


![Argocd Create Application Page]()


![Argocd Create Application Page]()

Keep the other options as default and click on the Create button. This will create a new ArgoCD application.


![]()

Give it a few seconds, and you should see that our application is `OutOfSync`. Since we set the sync policy to automatic, Argocd will automatically sync the cluster state defined in Git. 


![ArgoCD Resource Monitoring Page]()

You can see below that you’ve successfully deployed an Argocd-demo application that is now synced with your Git repository and is healthy. You can also see the deployment and service of the Argocd-demo application with two pods running as defined in the Github repository. Any further pushes to this Github repository will automatically be reflected in ArgoCD, which will resync your deployment while providing continuous availability.

Alternatively, open another terminal, and run the below command to get the number of pods running in your default namespace.

```
Kubectl get pods
```
Below, you can confirm two pods are listed and both running in the cluster deployed by ArgoCD.

![Argo-demo Applications Pods]()

To verify all is as it should be, run the kubectl port-forward command to forward traffic to the deployed application so you can access it from the browser. 

```
Kubectl port-forward svc/argocd-service 8086:80
```
In your browser go to http://localhost:8086 or http://your-server-Ip:8086 if you're using a cloud server.


![Deployed Application]()

You've successfully installed ArgoCD and used it to deploy an application to a Kubernetes cluster. Now, let's go over some ArgoCD concepts that we need to get out of the way.

## ArgoCD concepts you should know

### Application health 

As you saw in the demo above, ArgoCD keeps track of the sync status of all your applications, whether they are Synced or OutOfSync . It keeps track of the health of applications deployed in the cluster as well.

* Healthy: The resource is at a 100% optimal state.

* Progressing: The resource is not yet healthy but can still reach the Healthy state.

* Suspended: The resource is suspended or paused. Example a cron job that is currently not being executed.

* Missing: The resource can’t be found in the cluster.

* Degraded: The resource couldn’t reach a healthy state or failed.

* Unknown: The resource health state is unknown.


The health checks vary depending on the type of Kubernetes resource. For custom resources, you can write your own health-checks using [Lua script](https://www.lua.org/). To learn more about ArgoCD health-checks, check out the [official documentation](https://argo-cd.readthedocs.io/en/stable/operator-manual/health/).

### Sync strategies

When you created your application in the demo above, you used the automatic sync policy. That means ArgoCD will automatically apply cluster changes when they are detected. When configuring the sync strategy, you can set three parameters.

*Manual/automatic sync:** The automatic sync basically means that whenever a change is detected in our Git repository, ArgoCD should update the cluster state to match it, automatically,  whereas the manual sync means that when a change is detected in your git repository, ArgoCD will detect the change but will not sync the changes to the cluster, which must be done manually.

*Auto-prune:** When auto-prune is enabled, ArgoCD deletes the corresponding resource from the cluster each time a file is deleted in our Git repository. ArgoCD will never delete any resource from the cluster otherwise.

*Self heal:** If this option is enabled, any manual change in the cluster will automatically be reverted by ArgoCD.

Note: Self-heal and Auto-prune are only available for the automatic sync.

By default, ArgoCD checks the Git repository for changes every 3 minutes. However, this can be changed as needed. For a full GitOps structure, it is usually advisable to enable automatic sync, Auto-prune and Self heal.

### Deploying Use the declarative Approach 

In the preceding section, you should notice that you create the AgroCd deployment using the ArgoCD UI, which is fine but goes against GitOps principles. However, using the Declarative approach, you can create ArgoCD components such as applications and Projects using manifest files in the same way that you would create any other Kubernetes resource. You create a YAML file in which you define the application's specifications, and then you apply it with the kubectl apply command.

The first step is to create a yaml in which ArgoCD configuration is declared. Created a file and name it appliaction.yaml, paste the following configuration code

```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: declarative-app # Name of the application.
  namespace: argocd # The namespace where the application should be created.

spec:
  project: default
  source:
    repoURL: https://github.com/segunjkf/Argocd-demo # Remote Github repository where ArgoCD should pull configurations from. Please replace this with the Url you have forked.
    targetRevision: HEAD # The last commit in the remote repository.
    path: "demo-de" # Track and sync the dev path in the repository.

  destination:
    server: https://kubernetes.default.svc # Address of the Kubernetes cluster.
    namespace: declarative-app  # Indicates that ArgoCD should apply the configurations from the git repository to the declarative-app namespace.

  syncPolicy:
    syncOptions:
    - CreateNamespace=true  # Create the declarative-app namespace if it doesn't exist.

    automated:
      selfHeal: true  # Automatically sync changes from the Git repository.
      prune: true # ArgoCD will delete this application if the configuration settings are deleted from Git.

```
On navigate to the directory of the file you have created and run the following command on the command line.

```
Kubectl apply -f application.yaml
```


Now, go back to the ArgoCD UI, you will see your new application.


![]()

The Demo application has been successfully deployed and is now synced with your Git repository. In order to confirm that the application has been successfully deployed, you will forward traffic to the newly created pods. To do so run the following commands

```
Kubectl port-forward svc/argocd-declear-service 8087:80
```
In your browser, go to `http://localhost:8085/` or `http://YOUR_SERVER_IP:8087/` if you’re running on a cloud machine.



## Conclusion

In this guide, we have discussed ArgoCD, how to install it, how to deploy applications using the ArgoCD UI and declarative way with yaml files, and some deployment strategies you can use with ArgoCD. GitOps makes Kubernetes deployments maintainable due to its abstraction layering. It can be difficult to deploy applications to Kubernetes. Fortunately, tools like ArgoCD have greatly simplified the process and improved the developer experience.
 

