---
title: 'Enterprise Edition Installation'
weight: 1
---

# Helm Chart
The Enterprise Edition can be easily installed via a [Helm Chart](https://helm.sh/docs/topics/charts/).

To use the Helm Repository, you need a [GitLab Access Token](https://git.ausdertechnik.de/uitsmijter/uitsmijter/-/settings/access_tokens) with `read_api` permissions and at least the `Reporter` role.

You can add the Uitsmijter Helm Repository by using the following commands:
```shell
helm repo add --username '[token name or gitlab user name]' --password '[gitlab access token]' uitsmijter https://git.ausdertechnik.de/api/v4/projects/528/packages/helm/stable
helm repo update
```

An overview of available configuration options can be found at [Helm configuration](/configuration/helm).

## Helm Usage
To install the newest version, run
```shell
helm upgrade --install uitsmijter uitsmijter/uitsmijter --namespace uitsmijter --create-namespace --devel
```

A list of all available packages can be shown using
```shell
helm search repo uitsmijter --devel
```

To show which version is currently installed:
```shell
helm list  --namespace uitsmijter
```
