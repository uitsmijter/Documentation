---
title: 'Kubernetes'
weight: 1
---

# Install Uitsmijter on Kubernetes

Here are the steps to install Uitsmijter on Kubernetes:

## Prepare the installation

- Make sure the following requirements are met:
  - Kubernetes is up and running.
  - Traefik is up and running.
  - Your cluster can obtain valid certificates for Ingresses, e.g. with cert-manager.
- Ensure that you have the following authorizations in the Kubernetes cluster:
  - Permissions to deploy ClusterRole, ClusterRoleBinding and ServiceAccount.
  - Permissions to deploy CustomResourceDefinition.
  - Permissions to deploy various Kubernetes resources, including Namespace, ConfigMap, Secret, Service, Deployment, StatefulSet, Ingress and HorizontalPodAutoscaler.
  - Permissions to set up Traefik middlewares.
  - Permissions to create, list and edit CustomResources (client and tenant) in your namespaces.
- Download the file [values.yaml](https://raw.githubusercontent.com/uitsmijter/charts/refs/heads/main/charts/uitsmijter/values.yaml) from the Uitsmijter [Helm chart](https://charts.uitsmijter.io).
- [Customize](/configuration) the values in the file `values.yaml` to your needs.

## Install Uitsmijter

Add Uitsmijter Helm repository:
 ```
$ helm repo add uitsmijter https://charts.uitsmijter.io/
 ```

Update Helm:
 ```
$ helmet update
 ```

Install the Uitsmijter Helm chart:
 ```
$ helm install uitsmijter uitsmijter/uitsmijter
 ```

> Make sure that your user has the permissions to edit clients and tenants in your namespaces.

## Creating the first tenant

Create a new namespace for your tenant:
 ```
$ kubectl create ns <tenant-name>
 ```

Define your [tenant](/configuration/entities) in a YAML file. Make sure you specify 
valid [provider](/providers) scripts that connect to your user authentication service.

Apply the tenant to the namespace you created:
 ```
$ kubectl apply -n <tenant-name> <tenant-yaml-file>
 ```



## Creating a client

Define your [client](/configuration/entities) in a YAML file. Make sure that the tenant name matches the tenant 
you created and that the UUID “ident” is unique in the Uitsmijter universe in your cluster.

Apply the client to the namespace:
 ```
$ kubectl apply -n <tenant-name> <client-yaml-file>
 ```

## Check the Uitsmijter configuration

Check the auth server logs to ensure that the tenant and client have been loaded without errors:
 ```
 kubectl logs -n uitsmijter -l app=uitsmijter -l component=authserver
 ```

## Additional settings

Once you have completed these steps, you should have successfully installed Uitsmijter on your Kubernetes cluster. 
You can now start implementing OAuth login flows in your applications.

The sources do not contain information on how to customize the `Values.yaml` file for your needs. 
Additional information on customizing the `Values.yaml` file can be found in the 
Uitsmijter [Helm Chart](/configuration/helm) documentation.
