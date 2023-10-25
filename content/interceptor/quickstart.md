---
title: 'Walkthrough guide'
weight: 1
---

# Walkthrough guide for securing static webserver resources

**The Project Setup** In the [quick start guide](/general/quickstart) chapter we have designed a new application with
two portals, four services and one user store. The [quick start guide](/general/quickstart) shows how to set up
Uitsmijter as a multi-tenant, multi-client authorisation server.

For this additional walkthrough documentation we assume that a last-minute change request for the business hits the
development team. The requirement is, that the company's Design-Cookbook should be accessible for all partners. The
Design-Cookbook is a bunch of existing html files sitting in a NGINX on the clusters' namespace "cookbooks".

## Read the general quickstart first

You have to read the [quick start guide](/general/quickstart) first. Many of the examples on this page
refers to the examples at the quickstart chapter.

> Consider using a OAuth-Flow for new projects. It is far more elegant and gives you more possibilities for your setup.
> Yes, the initial amount of work to implement an oauth client is a bit higher (you have to understand the client
> libraries to use), but the fine granular options will help your project to grow later.
>
> **Nevertheless, the interceptor mode offers a number of advantages that allow you to implement two scenarios on very
> short time**:
> - Protecting static web servers and resources (spoiler: it is a one-liner to your ingress definition)
> - Migrating monolith projects with an own user store to a kubernetes service without rewriting the entire application
    logic first. (You may want to start with Interceptor Mode first, run it in parallel and then migrating step by step
    to oauth. We discuss this scenario in detail in the [migrating monolith](/interceptor/migrating_monolith) section.)

## Scenario

We assume that the cookbook has already been packed into an NGINX container and successfully deployed to the cluster.
Maybe it is open to the world or currently behind a basic auth. We need to secure this site with Uitsmijter and only let
partners to access the pages.

## How to achieve the requirements

The scenario is brilliant to demonstrate why Uitsmijter is the best choose for new projects. It is easy to attach new
requirements to the system within minutes.

Because the NGINX does not have any frontend application, like an SPA or an BFF we can not implement a known OAuth-Flow.
Because the users are stored in a private service, we can not easily attach some nginx authentication to it (Well, only
with lots of custom code, a bunch of lua scripts, a non default docker image, ect...).
Here fits the [Interceptor-Mode](/interceptor/interceptor) extremely well, because it allows you to first attach an
authorisation
header to every request, and second protect every resource with a secure login page if the authorisation header is
missing or invalid.

As Uitsmijter uses the same internal login mechanism for the Interceptor-Mode than for the OAuth-Login, the
same [backend providers](/providers/providers) can be used.

### Tenants and Clients

Under other circumstances we would **switch on the tenants configuration flag `interceptor.enabled` and we are done!**
But the requirements said, that only "partners" should have access to the cookbook. A `UserLoginProvider`
(see [User Login Provider](/providers/userloginprovider)) do have one script for all logins only and does not have
any access to the login method of a user.

> It is important to understand the concept of tenants and their clients (
> see [tenant and client configuration](/configuration/tenant_client_config) for more details).
> **Remember that BackendProviders are defined at tenant level.**

In the example of this demo project, we have to use the same user store but have to react on the "role" of the user. The
nature of a Interceptor-Mode is a boolean state: allowed to access, or denied to access a resource. Unlike an OAuth
application that may react on roles and scopes, a resource behind an interceptor protected ingress can be accessed when
the user is logged in, regardless of the role. Scopes are not implemented in Interceptor-Mode, because the resource
covered behind the login can not interpret this information. _Disclaimer_: a monolith application (e.g. an php server)
could - and should - extract this information from the authorisation header, but static webservers with plain html files
can't.

Even the cookbook service is for the same "Company", the best way to fulfill the requirements is to add a new tenant.

> Remember: The Interceptor-Mode ist tenant based, not client based! Luckily the [providers](/providers/providers) are,
> too.

Add this new tenant to the `cookbooks` namespace:

```yaml
---
apiVersion: "uitsmijter.io/v1"
kind: Tenant
metadata:
  name: cookbook
spec:
  hosts:
    - cookbooks.example.com
  interceptor:
    enabled: true
    domain: login.example.com
    cookie: .example.com
  providers:
    - |
      class UserLoginProvider {
        isLoggedIn = false;
        profile = {};
        role = null;
        constructor(credentials) {
          fetch(`http://checkcredentials.checkcredentials.svc.cluster.local/validate-login`, {
            method: "post",
            body: { username: credentials.username, passwordHash: sha256(credentials.password) }
          }).then((result) => {
            var subject = {};
            profile = JSON.parse(result.body);
            if (result.code === 200 && profile.role.indexOf('partner') > -1) {
              this.isLoggedIn = true;
              this.role = profile.role;
              subject = {subject: profile.userId};
            }
            commit(result.code, subject);
          }); 
        }
        get canLogin() { return this.isLoggedIn; }
        get userProfile() { return this.profile; }
        get role() { return this.role; }
      }
    - |
      class UserValidationProvider {
        isValid = false;
        constructor(args) {
          fetch(`http://checkcredentials.checkcredentials.svc.cluster.local/validate-user`, {
            method: "post",
            body: { username: args.username }
          }).then((result) => {
            response = JSON.parse(result.body);
            if (result.code === 200 && response.isDeleted === false) {
              this.isValid = true;
            }
            commit(this.isValid);
          }); 
        }
        get isValid() { return this.isValid; }
      }
```

Two changes are made. First `interceptor.enabled` is set to `true`. This allows a request to pass the middleware if the
label is set to the ingress. Secondly, we only allow users with a partner role to get access on this
tenant. That is made by a change in the provider script:  `profile.role.indexOf('partner') > -1`.

Save the file as `cookbook-tenant.yaml` and apply it to the `cookbooks` namespace:

```shell
kubectl apply -n cookbooks -f cookbook-tenant.yaml 
```

> Because the Interceptor-Mode enabler **and** the UserLoginProvider is set at tenant level, we do not need to declare
> a client.

### Ingress

Since the `interceptor` is marked with `enabled: true`, we only have to connect the ingress with Uitsmijter.
Open the ingress file for the cookbook service and add one line.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress

metadata:
  name: design-cookbook
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: websecure
    traefik.ingress.kubernetes.io/router.tls: "true"
    traefik.ingress.kubernetes.io/router.middlewares: uitsmijter-forward-auth@kubernetescrd

spec:
  tls:
    - secretName: example.com
  rules:
    - host: cookbooks.example.com
      http:
        paths:
          - path: "/"
            pathType: Prefix
            backend:
              service:
                name: cookbook-webserver
                port:
                  number: 80
```

Important is the line: `traefik.ingress.kubernetes.io/router.middlewares: uitsmijter-forward-auth@kubernetescrd`.
This connects the ingress with Uitsmijter and only logged-in users are allowed to access the page. If a user is not
logged in, then the users' client (browser) will be redirected to login.example.com and back after credentials are
checked successfully.

## Further readings

- Learn more about the [Interceptor-Mode on this dedicated page](/interceptor/interceptor)
- See [examples for the Interceptor-Mode](/interceptor/examples)
- Learn about [🔗 router.middlewares](https://doc.traefik.io/traefik/middlewares) in Traefik
