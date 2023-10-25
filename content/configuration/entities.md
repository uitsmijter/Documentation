---
title: 'Entities'
weight: 2
---

# Entities

This document describes the different entities Uitsmijter uses internally.
They are mentioned throughout the rest of the documentation.
For a complete list of used terminology, see [Terminology](/general/terminology).

## Tenant

A tenant is the highest order entity in the system. Every tenant is isolated in its functions and can not share
resources.  
Every Tenant does have its own set of settings, providers and clients. Let's have a look what this means in practice.

Examples for `tenants` are

- Different companies sharing the same Kubernetes cluster
- Separated products that do not have anything in common
- Different publications from a publishing house
- Different sets of underlying user data used for authentication (e.g. internal vs. external users)

> Note: If you just have one set of resources to protect with the same underlying user data(base), you will typically
> have just one tenant.

Tenants have a `name` which is a human-readable string that will be displayed whenever the tenant
comes in play. In kubernetes we prepend the namespace to make it cluster unique.
Each tenant has a list of hosts that are assigned to it. A tenant must have at least one host, and it can have
as many as needed.
A host **can not be shared** between two tenants in the system! That is, because the tenant will
be selected by the requested host only and a request thereby can not resolve into two tenants.

Let's imagine two tenants are set up in the following way:

- Tenant 1 ("Cheese Corp")
    - cheese.example.com
    - toast.example.org
- Tenant 2 ("Ham Publishing Group")
    - ham.test

1) If the request is addressed to `cheese.example.com` or `toast.example.org`, the first tenant will match and their settings will be
   processed.
2) If the request is addressed to `ham.test`, the second tenant will match and their settings will be processed.
3) If a request goes to `egg.example` or any other host not specified in any tenant's config,
   the request will be denied, because none of the tenants match the request.

The authentication server itself **does not have** its own user database. Instead, each tenant must provide a set
of `providers`
that are responsible for validating the users with a backend system. Providers are written in JavaScript and do apply to
all
clients (see [Providers](/providers/providers)).


> It is possible to share the same backend providers by copying the provider scripts,
> but this is not recommended and should be considered to solve problems where this idea seams to be a good solution
> otherwise.

## Client

A client is an external application that is allowed to use a grant and access protected resources on behalf of the
resource owner (i.e. user). The client could be hosted on a server, desktop, mobile or other device.

Each tenant can have multiple clients on different device classes such as:

- One or multiple websites
- Mobile Apps (e.g. iOS or Android native apps)
- Multiple Microservices and APIs to access them

It is advised to not mix or share clients between device classes. Instead, give every platform its own client for the
following reasons:

1) Security: If a token is leaked on one platform, the others are not involved.
2) Flexibility: Sooner or later different devices will have different settings.

A single sign on works between all clients. And because the [providers](/providers/providers) are bound to tenants all
clients
will fetch the same backend service to fetch the users.

## Further readings

- [Tenant and client configuration](/configuration/tenant_client_config)
- [Terminology overview](/general/terminology)

