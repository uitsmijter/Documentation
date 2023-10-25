---
title: 'Requirements'
weight: 4
---

# Requirements

## Kubernetes

This application is mainly meant to run on Kubernetes (K8s) and protect resources that run on Kubernetes clusters.
Uitsmijter is tested on Kubernetes version `1.22.0` and above.

### Must have preinstalled resources

- [🔗 Traefik](https://traefik.io) in version >= 2.9
  Currently the [Interceptor Mode](/interceptor/interceptor) is only available for Traefik at the moment. If you are
  using other ingress controllers, please feel free to [contact us](mailto:sales@uitsmijter.io). We are constantly
  working on new features and integrations.
  > **Attention**: You have to enable **allowExternalNameServices** in Traefik!
  > See
  > [🔗 this Traefik documentation](https://doc.traefik.io/traefik/providers/kubernetes-ingress/#allowexternalnameservices)
  > to set up Traefik correctly.
  >
  > Settings in Traefik deployment
  > ```yaml
  > - --providers.kubernetesingress.allowExternalNameServices=true
  >  ``` 

- [🔗 Helm](https://helm.sh) in version > 3.0
  We provide a setup routine in Helm Charts that installs Uitsmijter onto Kubernetes with all necessary resources. Read
  more about the installation process in the [quick start](/general/quickstart) tutorial.

- [🔗 Cert-Manager](https://cert-manager.io)
  Valid certificates are a must-have for a secure login. We recommend to use cert-manager to get
  valid [🔗 Let’s Encrypt](https://letsencrypt.org) certificates for your cluster ingresses.

### Optional but recommended resources

- [🔗 config-syncer](https://github.com/kubeops/config-syncer)
  The authorization server signs the JWT with a secret that every client must know. Rather than storing various secrets
  in different namespaces that are hard to keep in sync we recommend to use config-syncer to distribute the one secret
  to
  every namespace that is allowed to consume the secret.

- [🔗 Prometheus](https://prometheus.io)
  Uitsmijter does not have its own management portal because it is not necessary and would _brand_ the product. For the
  sake of simplicity and fully respect of your workflow everything can be configured as declarative code
  in [🔗 custom resources](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/) and
  [🔗 configmaps](https://kubernetes.io/docs/concepts/configuration/configmap/).
  To see what is Uitsmijter doing, it provides a wide set of metrics data in the [🔗 OpenMetrics](https://openmetrics.io)
  format. We recommend to use Prometheus to collect the metrics.

- [🔗 Grafana](https://grafana.com)
  Because of the absence of an administrative portal that would dictate you how to take a look on the metrics,
  Uitsmijter
  offers a wide range of OpenMetrics data. To show them in meaningfully graphs a Grafana Dashboard is provided. You may
  want to use the dashboard as a starting point and bring in your own business metrics.

## Docker

It is possible to run Uitsmijter in a docker environment for production. Unfortunately this operational mode is not
documented yet.

### Must have preinstalled resources

- [🔗 Docker](https://www.docker.com) in version 20.10
- [🔗 Docker Compose](https://docs.docker.com/compose/) in version 2.13.0
- [🔗 Traefik](https://traefik.io) in version >= 2.9

If you are using docker or some other kind of orchestration please feel free
to [contact us](mailto:sales@uitsmijter.io). We are open to share some information and can help to implement Uitsmijter
in a different setup than Kubernetes.

## Further readings

- [Quick Start Guide](/general/quickstart) for Kubernetes.
