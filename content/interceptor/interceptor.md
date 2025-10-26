---
title: 'Interceptor Mode'
weight: 2
---

# Interceptor Mode

Interceptor mode is used within Traefik2 as a middleware authorization controller.
When a resource is requested, the middleware checks if the current user is logged in. If not, the request is
redirected to the login page. If the user making the request is logged in, the middleware forwards the request
to the requested resource.

> For support of other ingress controllers, please feel free to [contact](mailto:sales@uitsmijter.io) our development and
> consulting team. We are constantly adding support for other controllers and documenting them as needed.

## Flow

```text
┌────────────────────────┐               ┌────────────────────────┐            ┌───────────────────────┐
│                        │               │                        │            │                       │
│                        │  request >    │                        │     ok >   │                       │
│                        ├───────────────►                        ├────────────►                       │
│     Resource owner     │               │      AuthForward       │            │    resource server    │
│                        ◄───────────────┤                        │            │                       │
│                        │   < error     │                        │            │                       │
└────────────────────────┘               └──────────────────▲──┬──┘            └───────────────────────┘
                                                            │  │
                                                            │  │
                                                            │  │
                                                         ┌──┴──▼────────────────────┐
                                                         │                          │
                                                         │                          │
                                                         │                          │
                                                         │        Uitsmijter        │
                                                         │                          │
                                                         │                          │
                                                         └──────────────────────────┘
```

1. The resource owner makes a request to the resource server
2. The AuthForward delegates the request to `Uitsmijter` first
3. If the user is not logged in, a login mask is provided
4. If the login fails, the AuthForward responds with an error code
5. If the login succeeds, or the user is already logged in, Uitsmijter adds the JWT to the header and the AuthForwarder
   forwards the request to the resource server.

## Login status

The status of whether a user is logged in is stored in a cookie that is strictly bound to the domain of the
middleware. The domain must be set at the tenant level, as shown in the [example](/interceptor/examples) section.
An encoded JWT is stored inside the cookie. This JWT will be added to the `Authorization` header for every
request.

> **In your application:**
>
> **Do not read the cookie yourself, but use the `Authorization` header sent with the request.**

## Refresh the token

The middleware will refresh the request's JWT automatically when 3/4 of the lifetime has passed.

> This could potentially lead to a situation where two different valid JWTs arrive at the underlying application if
> the application fires parallel requests against itself. Even though both tokens are valid and encode the same
> information, some applications may not handle this well when storing the original token. The solution for this scenario is
> simple: validate the token as soon as possible and decode the payload first. Save the decoded payload for comparison,
> not the token. This "problem" is primarily academic because if your application makes requests with a token that is
> already known, you are already in the Single-Page-Application landscape. In this case, please use a
> proper [OAuth-Flow](/oauth/flow) instead. In a server-rendered application, parallel requests with different tokens
> will never be a problem if you decode the payload first.

## Configuration and Examples

To protect your resource server with the interceptor mode of Uitsmijter, you mainly need to add an ingress annotation:

```yaml
annotations:
  traefik.ingress.kubernetes.io/router.middlewares: uitsmijter-forward-auth@kubernetescrd
```

If your setup operates on the same top-level domain, then that is all that is needed. For example, if Uitsmijter's main domain
is `login.example.com` and the resource server to protect is located at `secured.example.com`.

It is more challenging when projects are on different top-level domains. For example, if the Uitsmijter installation is still
located at `login.example.com`, but the resource server to protect is located at `toast.example.com`.
Because cookies must be from within the same domain, the trick is to proxy the service into the new domain via an
[🔗 external service](https://kubernetes.io/docs/concepts/services-networking/service/#externalname) and then defining
an own ingress to that service.

> **Cookie settings**
> The cookie must be set for the domain in which both the Uitsmijter service (or its ingress to the proxy) and the
> resource server are located!
>
> **Attention:**
> Every backend service that is located on this domain or a subdomain of this domain can read the JWT out of the cookie.
> It is accessible to all services on this domain tree.
>
> Example:
> - Uitsmijter is accessible at `id.example.com`
> - The resource server is accessible at `secretinfo.srv.example.com`
> - Then you have to set `example.com` as tenants `interceptor.cookie` domain


If Uitsmijter is installed onto a server without Kubernetes, you have to be sure that the environment is
set correctly. Installations outside Kubernetes is not documented, yet. If you have any questions please do not
hesitate [to ask](mailto:sales@uitsmijter.io)

Install this proxy service to a new namespace. It links to Uitsmijter:

```yaml
---
kind: Service
apiVersion: v1
metadata:
  name: uitsmijter-proxy
spec:
  type: ExternalName
  externalName: uitsmijter-authserver.uitsmijter.svc.cluster.local
  ports:
    - port: 80
```

_save this to `uitsmijter-proxy.yaml` file_

This external service defines a proxy into the authentication server in the uitsmijter namespace. You can create this
service in every namespace on your cluster.

1. Ensure Uitsmijter is installed properly in the `uitsmijter` namespace. (If not set up yet, please read
   the [quick start](/general/quickstart) now.)
2. Create (_if not done by now_) a namespace for the resource server:
   ```yaml
    kubectl create namespace "my-resources"
    ```
3. Apply the proxy service mentioned above:
   ```yaml
    kubectl apply -n "my-resources" -f uitsmijter-proxy.yaml
    ```

When the resource server is available at **toast.example.com** a login page at the same domain level is needed, like
**login.example.com** for example.

This is an example ingress that points to the proxy service and _serves_ uitsmijter from the new domain.

```yaml
---
apiVersion: networking.k8s.io/v1
kind: Ingress

metadata:
  name: uitsmijter
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: websecure
    traefik.ingress.kubernetes.io/router.tls: "true"
    traefik.ingress.kubernetes.io/router.middlewares: uitsmijter-forward-header@kubernetescrd

spec:
  tls:
    - secretName: example.com

  rules:
    - host: login.example.com
      http:
        paths:
          - path: "/"
            pathType: Prefix
            backend:
              service:
                name: uitsmijter-proxy
                port:
                  number: 80
```

> An ingress can only refer to a service in the same namespace, but a service can address a resource in another
> namespace. This is why we have to do both: a proxy service and an ingress to the proxy service.

> Do not overlook this line:
> **traefik.ingress.kubernetes.io/router.middlewares: uitsmijter-forward-header@kubernetescrd**
>
> It is important to set specific headers that Uitsmijter needs for proper operation.

To protect static resources, like discussed in
the [Walkthrough guide for securing static webserver resources](/interceptor/quickstart) all to do is to define a tenant
next

Let's create a file for the `example`-tenant named `example-tenant.yaml`:

```yaml
---
apiVersion: "uitsmijter.io/v1"
kind: Tenant
metadata:
  name: example
spec:
  hosts:
    - login.example.com
    - toast.example.com
  interceptor:
    enabled: true
    domain: login.example.com
    cookie: .example.com
  informations:
    imprint_url: https://example.com/imprint
    privacy_url: https://example.com/privacy
    register_url: https://login.example.com/register
  providers:
    - class UserLoginProvider {
      constructor(credentials) { commit(true); }
      get canLogin() { return true; }
      get userProfile() { return {message:"DO NOT USE THIS IN PRODUCTION"}; }
      get role() { return "development"; }
      }
    - class UserValidationProvider {
      constructor(args) { commit(true); }
      get isValid() { return true; }
      }
```

_The UserLoginProvider accepts every combination of any user for now. We can change it later._

4. Apply the tenant and restart Uitsmijter to load the new tenant:
   ```yaml
    kubectl apply -n "my-resources" -f example-tenant.yaml
    kubectl delete pod -n uitsmijter -l app=uitsmijter -l component=authserver
    ```

When a user requests https://toast.example.com the first time the browser will be redirected to the Uitsmijter login
page
at https://login.example.com. After login successfully the user will redirect back to https://toast.example.com. A
cookie is
stored at the users browser for all domains in the `.example.com` landscape, including `toast.example.com` - but
also `egg.example.com`. Maybe this is what you want, otherwise fine tune the `interceptor.cookie` settings in the tenant
definition file. If you do not want to allow an SSO to all the subdomains at `*.example.com`, but just and only
to `toast.example.com`, change the `interceptor.cookie` setting to `toast.example.com`. Remember that the login page
must be part of
the domain-scope. Maybe you want to change the ingress from the domain `login.example.com` to `toast.example.com/login`.

### Advanced configuration for applications behind the Interceptor-Mode

Protecting a static web server behind Uitsmijter is very simple, as the chapter up to here could show. The static
websites do nothing with the authorisation header set by Uitsmijter. It just has to be present.

A very little more difficult is when a server side rendering application sits behind the protected resources that has to
know something about the concrete user and maybe has to decode the profile from the Bearer token.

The application has to validate the JWT with a shared secret, checks that the token is still valid and then decode the
profile from it.

But first things first: sharing the secret. While installation a shared secret is given
(see [Quick Start Guide for Kubernetes](/general/quickstart) for more details on how to set a secret into the
`Values.yaml`). For installations outside of Kubernetes ensure that the environment variable `JWT_SECRET` is set.

When Uitsmijter is installed on Kubernetes with the provided Helm Chart and all [requirements](/general/requirements)
are met. Sharing the JWT-secret into namespaces that needs them to validates the JWT is easy. Uitsmijter sets
annotations for [🔗 config-syncer](https://github.com/kubeops/config-syncer). All the other namespace has to do is set
the labels to the namespace, too.

Here is an example namespace definition for `my-resources`:

```yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: my-resources
  labels:
    jwt-secret/sync: "true"
```

`jwt-secret/sync: "true"` will sync the secret into the namespace. To have the content in your applications environment
you should link the secret to your environment:

```yaml
  #[ ... _deployment_ ... ]

  envFrom:
    - secretRef:
        name: jwt-secret

  #[ ... _rest_of_the_deployment_ ... ]
```

More information about environment variables in Kubernetes are described
in [🔗 Define Environment Variables for a Container](https://kubernetes.io/docs/tasks/inject-data-application/define-environment-variable-container/)

With the information about the secret attached to the namespace and bind to the environment variable the application can
validate and decode the token.

> Do not track the user on information inside the tokens profile, use the `token.subject` instead. The Subject is an
> unique identifier for your user across all systems. The subject inside a token is set by
> the [User Login Provider](/providers/userloginprovider). You can find any information on the page about them.

How to validate and decoding a JWT depends on your server programming language, here is a code
for [nodejs](https://nodejs.org/en/) using the [jsonwebtoken](https://github.com/auth0/node-jsonwebtoken) library from
[auth0](https://auth0.com).

```javascript
const jwt = require('jsonwebtoken');

// Verify the token using jwt.verify method
const decode = jwt.verify(token, 'secret');

const subject = decode.sub;
const profile = decode.profile;

// show the full decoded token
console.log(JSON.stringify(decode, null, 4));
```

The result should look something like this:

```json
{
  "tenant": "my-resources/my-tenant",
  "profile": {
    "name": "John Doe"
  },
  "sub": "188920",
  "role": "user",
  "user": "john@example.com",
  "exp": 1671740462.505093
}
```

In the result above a numeric id is chosen by the User Backend Provider to identify the concrete user.

## Metrics

Metrics about succeeded and failed calls are metered by these Prometheus keys:

- uitsmijter_interceptor_failure
- uitsmijter_interceptor_success
- uitsmijter_login_attempts
- uitsmijter_login_failure
- uitsmijter_login_success

## Technical details

Whether the user is logged in or not is persisted by a restricted cookie with the content of the JWT. Uitsmijter does
not track any sessions for the middleware requests.

## Further readings

- In the [interceptor example](/interceptor/examples) section the `demopage` is described and explained in detail.
