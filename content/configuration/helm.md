---
title: 'Helm configuration'
weight: 1
---

# Helm configuration parameters

Uitsmijter is best to install over [helm](https://helm.sh).

```shell
helm repo add uitsmijter https://charts.uitsmijter.io/
helm update
```

To list available versions run: 

```shell
helm search repo uitsmijter
```

To see a list with release candidates included: 

```shell
helm search repo uitsmijter --devel
```


The complete `Values.yaml` is presented first, than the parameters are described as on overview. For detailed
information please read the [quick start](/general/quickstart) guide.

## Full Values.yaml

```yaml
namespaceOverride: ""

image:
  repository: docker.ausdertechnik.de/uitsmijter/uitsmijter
  # Overrides the image tag whose default is the chart appVersion.
  tag: ""
  pullPolicy: Always

imagePullSecrets:
  - name: gitlab-auth
jwtSecret: "vosai0za6iex8AelahGemaeBooph6pah6Saezae0oojahfa7Re6leibeeshiu8ie"
redisPassword: "Shohmaz1"
storageClassName: "default-ext4"
installCRD: true
installSA: true

config:
  # Log format options: console|ndjson
  logFormat: "console"
  # Log level options: trace|info|error|critical
  logLevel: "info"
  cookieExpirationInDays: 7
  tokenExpirationInHours: 2
  tokenRefreshExpirationInHours: 720
  # show the version information at /versions
  displayVersion: true

domains:
  - domain: "nightly.example.com"
    tlsSecretName: "example.com"
  - domain: "nightly2.example.com"
    tlsSecretName: "example.com"
```

## Parameter description

| Parameter                            | Default    | Description                                                                                                                                                                                              |
|--------------------------------------|------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| namespaceOverride                    | uitsmijter | Namespace to install Uitsmijter to.                                                                                                                                                                      | 
| image.repository                     |            | Docker repository for the Uitsmijter server image.                                                                                                                                                       |
| image.tag                            |            | Version-Tag to install. Must be present in the `image.repository`.                                                                                                                                       |
| image.pullPolicy                     | Always     | The pull policy of the used image.                                                                                                                                                                       |
| imagePullSecrets.name                |            | When using a private repository, the name of the dockerPullSecret. See [🔗 Pull an Image from a Private Registry](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/) |
| jwtSecret                            |            | Passphrase with that each JWT-token is signed.                                                                                                                                                           |
| redisPassword                        |            | Password for the [🔗 Redis](https://redis.io) database where all refresh tokens are stored.                                                                                                              |
| storageClassName                     |            | Kubernetes [🔗 Storage Class](https://kubernetes.io/docs/concepts/storage/storage-classes/) to use to store the redis data.                                                                              |
| installCRD                           | true       | Install necessary [🔗 Custom Resource Definitions](https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definitions/) for `Tenants` and `Clients`.                        |
| installSA                            | true       | Install [🔗 Service Accounts](https://kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin/) to allow to read `Tenants` and `Clients`.                                                 |
| config.logFormat                     | console    | Log format options: `console` or `ndjson`.                                                                                                                                                               |                                                                                                                                                                                                         |
| config.logLevel                      | info       | Level of log verbosity. Options: `trace`, `info`, `error` or `critical`                                                                                                                                  |
| config.cookieExpirationInDays        | 7          | Days a cookie is valid without refreshing its value.                                                                                                                                                     |
| config.tokenExpirationInHours        | 2          | Invalidates the JWT-Token after number of hours.                                                                                                                                                         |
| config.tokenRefreshExpirationInHours | 720        | Invalidates the refresh token after number of hours.                                                                                                                                                     |
| config.displayVersion                | true       | Displays the version information of Uitsmijter under /versions publicly for all. You can turn this off for security reasons.                                                                             |
| domains.domain                       |            | List of Domains. Entry of the domain where Uitsmijter is listening on.                                                                                                                                   |
| domains.tlsSecretName                |            | List of Domains. Entry of the name of the certificate secret.                                                                                                                                            |

## Install Uitsmijter Helm Charts

```shell
helm install uitsmijter -f values.yaml uitsmijter/uitsmijter
```


## Overwrite Parameters in a CI/CD-Pipeline from source

Overwriting parameters from the command line is possible. For example install Uitsmijter in a feature branch, it is not
handy to provide extra `Values.yaml`'s, but set the parameters at the shell directly.

Here is an example from our gitlab pipeline to install feature-branches in its own namespace:

```shell
    - helm upgrade
      --install uitsmijter ./Deployment/helm/uitsmijter
      --set image.tag=${CONTAINER_IMAGE_TAG}
      --set "domains[0].domain=${CI_COMMIT_REF_SLUG}.example.com"
      --set "domains[0].tlsSecretName=example.com"
      --set "installCRD=false"
      --set "config.logLevel=debug"
      --namespace "uitsmijter-${CI_COMMIT_REF_SLUG}"
```

You can overwrite every parameter from the parameter description.
