---
title: 'Example Deployment'
weight: 3
---

# Interceptor Mode

The interceptor mode is shown in an [example deployment](/resources/demopage). The same nginx pod is accessible
via two separate ingresses, [one](/resources/demopage/ingress-secured.yaml) is secured by the
interceptor middleware, the [other](/resources/demopage/ingress-open.yaml) is not secured.

## Configuration

To secure an ingress with the interceptor middleware you have to set an `annotation` to the `Ingress`.

Add this annotation to the [Ingress configuration](/resources/demopage/ingress-secured.yaml).

```yaml
  annotations:
    traefik.ingress.kubernetes.io/router.middlewares: uitsmijter-forward-auth@kubernetescrd
```

On an existing ingress you can add the annotation with kubectl

````shell
kubectl patch ingress <my-ingress-name> -p '{"metadata":{"annotations":{"traefik.ingress.kubernetes.io/router.middlewares":"uitsmijter-forward-auth@kubernetescrd"}}}'
````

The resources k8s service behind the ingress is secured by the Uitsmijter middleware for [🔗 Traefik](https://traefik.io).
More information about ForwardAuth middleware can be found on the
[🔗 Traefik website](https://doc.traefik.io/traefik/middlewares/http/forwardauth/), but you don't have to read all
of it, because Uitsmijter just uses it to grab the traffic and injects the authentication.

## Information for the resource server

If a user is logged in and the call is passed through the middleware it will be forwarded to the original called target
(resource server). Besides the remitted access to the resource server the call will be enhanced by
a `bearerAuthorization` header that holds information about the currently logged-in user.
The information about the user in wrapped into a [🔗 JWT](https://jwt.io) that is secured by a shared password. To decode
and validate the JWT-Token you have to sync the secret that is shared by the `uitsmijter` namespace into your
application's namespace.
The Chapter "Advanced configuration for applications behind the Interceptor-Mode" in
the [Interceptor Mode](/interceptor/interceptor)
section provides more details about the shared secret and how to consume it.

> Note: [JSON Web Key (JWK)](https://www.rfc-editor.org/rfc/rfc7517) and .well-known ist not part of Uitsmijter, yet.

This is an example namespace resource that syncs the secret into your namespace:

```yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: mySecuredAppNamespace
  labels:
    jwt-secret/sync: "true"
```

By adding the label `jwt-secret/sync: "true"` to the metadata section of the namespace definition,
[🔗 config-syncer](https://github.com/kubeops/config-syncer) will create a proper secret named `jwt-secret` in your
namespace.
In that way, when you decide to rotate the JWT secret key, all applications in the cluster automatically get the new key
to verify further JWT tokens.

## Further readings

- detailed explained example as a [walkthrough guide](/interceptor/quickstart) for securing static webserver resources.
- A best practise guide to [migrate a monolith](/interceptor/migrating_monolith) into microservices with Uitsmijter
