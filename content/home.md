---
title: 'Uitsmijter'
geekdocHidden: true
---

# Uitsmijter Documentation

**A versatile OAuth2 authorization server and Traefik middleware for Kubernetes and Docker.
Uses your existing user-database to prevent vendor lock-in.**

![Uitsmijter](/resources/uitsmijter-horizontal-color.svg "Uitsmijter")

## About

Uitsmijter is a standalone OAuth2 authorization server with embedded middleware that provides login mechanisms to your
project without changing the existing user database.

The goal of this project is to bring trustworthy and easy-to-integrate security to your project, within a few hours
from installation, configuration and implementation to go-live.

Main goals of the project:

- Easy migration
    - Move from a single application login to a distributed OAuth 2 flow for many kinds of applications in just one day
- Fast implementation
- Reliability
- OAuth 2 compatibility
- Fast response times
- Low Memory and CPU consumption

[Read more about Uitsmijter](/general/about)

[Getting familiar with the terminology used in this documentation](/general/terminology)

### Naming

**Uitsmijter** is a popular breakfast, brunch and lunch dish in the Netherlands.
The [ingredients](/general/ingredients) are put on top of each other, finishing with a fried egg on top that covers the
ham and the cheese.

Legend goes that this dish used to be served late at night, just before the guests are kicked out at closing
time, which may explain why the Dutch name for this dish, "uitsmijter," means "**bouncer**" or "**doorman**" in english.

We found this is an excellent name for the product, because it is put on top of your existing products
(the ham and the cheese) and makes everything more delicious. The english translation **bouncer** makes perfect sense,
because the applications inside no longer have to worry about their security. The bouncer will keep uninvited guests
outside.

### Motivation

We have treated it as normal that migration projects take a long time and involve a lot of risk. Uitsmijter hits a
pretty
crowded market of authorisation servers, but fills the need that migrations from a monolith into a microservice
architecture should be nice and comfortable.

With Uitsmijter it is no longer a hurdle to implement secure and modern authentication methods. The product supports
the developers in every project phase. It is such a pleasure to work with Uitsmijter that it makes sense to build
new projects upon it, because the flexibility that is needed for smooth migrations are the successors of new ideas.

You may want to read the full [motivation page](/general/motivation) to get a deeper understanding of why we are
building
Uitsmijter from the ground up.

## Getting started

### Requirements

This application is meant to run on Kubernetes (K8s) and protects resources that run on Kubernetes clusters.
Uitsmijter is tested on Kubernetes version `1.22.0` and above.

The [Interceptor Mode](/interceptor/interceptor) is coupled to a preexisting [🔗 Traefik](https://traefik.io) instance
running on the cluster. Other ingress controllers are in planning, but still under development.

You can run Uitsmijter in a Docker environment with a [🔗 Traefik](https://traefik.io) Endpoint or standaloone,
but this is not covered in this documentation yet.

Read the [list of requirements](/general/requirements), including links to set up those on your server.

### Quick start guide

The description in the [Quick Start Guide](/general/quickstart) sets up Uitsmijter in a couple of minutes.
There is also a [walkthrough guide for the interceptor mode](/interceptor/quickstart), that explains how to protect
static websites.

## Architecture

Uitsmijter works on the basis of Tenants and Clients where **Tenants** are the top entity (for example internal users, users of a product etc.).
They implement the access to an existing authentification backend via an **authentication provider** implemenation.
Each Tenant has **Clients** (for example a Website, a mobile app and the web shop).
The Clients can connected using different methods to Uitsmijter, depending what they need.
Uitsmijter provides two main authentification mechanisms:  
The **Interceptor** mode which authenticates every request to a page (for example of a single page application)
and redirects the user to a login page when he is not logged in.  
An **OAuth 2 server** which allows an application to be easily integrated via the OAuth 2 standard,
normally used for bigger applications and mobile apps.

### Interceptor

When a resource is requested, the middleware checks if the current user is logged in. If not, the request is redirected
to the login page. If the user making the request is logged in, the middleware directs the request to the requested
resource with an authorization header.
The authorization header includes a Bearer token with an JWT encoded user profile.

The interceptor mode ist an excellent choose for:

- Protecting static websites
- Protecting landing pages
- Migrating legacy monolith applications

Read the [walkthrough guide for securing static webserver resources](/interceptor/quickstart) to see how to protect a
static resource server in a couple of minutes. More [example deployment](/interceptor/examples) may give you a complete
picture about the mode and how to configure it for your needs.
If you are migrating an existing project with its own user database to Uitsmijter, you may want to read a longer article
about the [migration a monolith application](/interceptor/migrating_monolith).

An in depth documentation can be found in the [Interceptor Mode](/interceptor/interceptor) section.

### OAuth 2 Server

OAuth 2 is a protocol that allows a user to authorize a third-party application or service to access their data or
perform actions on their behalf on another web service. It streamlines the process of granting this authorization,
making it more secure and convenient for users.

OAuth 2 is well-suited for authenticating a user on a single page application or mobile app.

If you are new to OAuth, this overview of the [OAuth flow](/oauth/flow) will help you to understand the basic concept.

Uitsmijter supports various [Grant types](/oauth/granttypes):

- Authorization Code
- Refresh Token
- Password

To set up the client library you find detailed information about the [available endpoints](/oauth/endpoints) on the
dedicated page. Uitsmijter uses the default endpoints described
in [🔗RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html) but some libraries does not play well with the
standards and needs information about the endpoint name. You can find all the necessary information on
the [available endpoints](/oauth/endpoints) page.

You can decode the JWT [on your own](/oauth/jwt_decoding) with a client library, or you may want to use
the [info-endpoint](/oauth/endpoints##Profile_endpoints) that uitsmijter supports.

The purpose of [Proof Key for Code Exchange](oauth/pkce) is to prevent attacks where an attacker might intercept the
authorization code and use it to obtain an access token. It does this by introducing a "code verifier" and a "code
challenge" that are sent to the authorization server during the authorization request. The authorization server uses the
code challenge to verify that the authorization code was issued to the same client that is making the token request.
This helps to prevent an attacker from being able to exchange the authorization code for an access token.

### Providers

Providers are glue code between Uitsmijter and external resources, like your own user data store. Providers are very
easy code written in plain ECMA-Script (Javascript). Even if you are not familiar with JavaScript, writing a
provider is easy and straight forward.

Read the [general provider information](/providers/providers) before digging into
the [User Login Provider](/providers/userloginprovider).

## Configuration

`Tenants` and `Clients` are described in the [entities](/configuration/entities) configuration section. For general
configuration about Uitsmijter, please take a look at the [quick start](/general/quickstart) guide. To give a better
overview the [helm configuration](/configuration/helm) page lists all available configuration parameters from the
installation process, again.

The relation between `tenants` and `clients` are described in
the [Tenant and client configuration](/configuration/tenant_client_config) along examples and best practises.

The available log levels and formats are explained on the [logging](/configuration/logging.md) page.

## Customisation

Easy customisation is one of the main benefits of Uitsmijter. The authorisation server uses **your** user database
through the ability of defining [provider](/providers/providers) scripts.
The [Tenant and client](/configuration/tenant_client_config) configuration give you a tool to describing your needs to
handle all logins to multiple projects with multiple devices with different access levels.

The customisation of [login templates](/customisation/template_login) is possible by using template files
or by defining an S3 bucket as a source.

## Contribution And Development

Uitsmijter is written in [Swift 5.7](https://www.swift.org). Please read
the [Development information](/contribution/development) and get familiar with the [toolchain](/contribution/tooling).

When you fix a bug, or add a new feature, you have to commit it back to the community. Please read
the [development Guidelines](/contribution/guidelines) first To make sure that you meet the requirements and that your
change can be transferred to an official release without any problems. The guidelines are there to motivate. We do not
want to disappoint any developer.

Our [Code Of Conduct](/contribution/codeofconduct) is a vital asset for working together. Please do not oversee it!

Finally, here is a list of [used 3rd party tools](/Wiki/contribution/3rdparty.md) that is used by uitsmijter. Thanks to
all of them for the
great work without Uitsmijter won't be alive.

## Licence

Uitsmijter is released under the [Apache Licence 2.0](/licence).
