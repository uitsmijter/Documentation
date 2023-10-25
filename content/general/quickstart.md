---
title: 'Quick Start Guide'
weight: 5
---

# Quick Start Guide for Kubernetes

This guide covers all you need to get up and running with Uitsmijter. The documentation is based on a fictive Project
for better understanding when and why to set some configurations.

## Meet the requirements

This quick start guide assumes that the requirements are given. See [this list of requirements](/general/requirements)
that
cover
the following criteria:

- Kubernetes is up and running
- Traefik is up and running
- Your cluster is able to get valid certificates for ingresses, e.g. with cert-manager

## Needed privileges to deploy onto your cluster

To deploy a working instance of Uitsmijter you need to have privileges on the kubernetes cluster that allow you to
deploy the following resource kinds:

**A service account with a cluster role** is needed to allow Uitsmijter to read its `CustomResources`

- ClusterRole
- ClusterRoleBinding
- ServiceAccount

**CustomResources definitions** are needed to declare Tenants and Clients:

- CustomResourceDefinition

**Kubernetes Resources will be installed** during the installation:

- Namespace
- ConfigMap
- Secret
- Service
- Deployment
- StatefulSet
- Ingress
- HorizontalPodAutoscaler

**The Interceptor-Mode is relying on Traefik Middlewares** that will be set up during the installation:

- Middleware

**CustomResources, declared by `CustomResourceDefinition` should be allowed to create, list and edit** by your account
in your namespaces:

- Client
- Tenant

Make sure that you have these rights on your cluster (an admin certainly will have all of these). If not, please ask
your system administrator for help.

## Prepare the installation

Uitsmijter offers a [🔗 Helm](https://helm.sh) installation routine. Download the Values.yaml first and change the
values for your needs. The following example describes the sections on a fictive project. You have to change the values
accordingly.

**The Project Setup**:
We are planning a new customer portal for the domain `example.com`. The portal should be available for customers to
send small notes to a selected group of recipients. However, we are planning to create different Microservices behind
a Single-Page-Application (SPA).

The SPA shows general available content and offers a login button. Various functions are available only if a user is
logged in. Without a valid login the user sees marketing project information provided by a cms. After login the user has
access to its own profile, address book and incoming messages and also allowed to write a new message to all
participants of the address book.

The business requirements say that certain users with the `partner` role should have an extra functionality that is
available as a link to a portal that is made by another team. If the user is logged in to example.com then the user
should also be logged in to the other portal located at partner.example.com.

So far so good. The architecture of the new project is set and looks like this:

- portal.example.com (portal.example.com)
- partner.example.com (partner.example.com)
- CMS (cms.example.com)
- Profile backend (profile.srv.example.com)
- Address book backend (contacts.srv.example.com)
- Inbox backend (inbox.srv.example.com)
- Send messages backend (send.srv.example.com)

> As you can see we do make the services public available! We will secure them later on with a JWT. To make it
> accessible from within the SPA it should be publicly available, otherwise we would need
> a [🔗 BFF](https://blog.bitsrc.io/bff-pattern-backend-for-frontend-an-introduction-e4fa965128bf).

**Create a User Backend**:
> Somewhere user data must be stored. **Uitsmijter does not store any account data, profiles or passwords**. To create a
> store for the users credentials either a service must be created or selected from the existing once. In our example
> the `Profile backend` would fit, but this we want to make public available and the user store should only be
> accessible
> within the cluster. So we could do an extra route that is only available from a private service but for the sake of
> security and the luck of a new project we create a service that is just there to store user credentials.

This new `Credentials service` got one route named: "POST: /validate-login" and fires a query against a database:

```sql
SELECT `id`, `role`, `profile`
FROM accounts
WHERE `username` = ?
  AND `passwordhash` = ?;
```

_In our example passwords are stored as a sha256-Hash. You can choose between sha256, md5 and plain text._

Some other applications will fill in the users after registration. This is out of scope for now. Important is that
the `/validate-login` takes two parameters: `username` and `passwordHash` and returns a status 200 with a user profile
object or some unauthorised error if the credentials do not match.

In case the credentials match, return the user profile object:

```http request
HTTP/1.1 200
Content-Type: application/json; charset=UTF-8

{
    "id": "${result.id}",
    "role": "${result.role}",
    "profile": "${result.profile}",
}
```

We host this little service in the `usertrunk` namespace with a service that points to the deployment:

```yaml
---
kind: Service
apiVersion: v1
metadata:
  namespace: usertrunk
  name: checkcredentials
spec:
  selector:
    app: userdb
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
```

**It's time to install Uitsmijter!**:
At this point in time, we need some service that handles the authorisation for our project. We do not want to log in
multiple times to different portals, and we do not want to authenticate the user in all backends. Backends should be
denied the access if a user request with an invalid token, and access data on the users behalf if the token is correct.

That implies that we expect some criteria:

- The user must login to get a valid token
- The token must encode a unique `subject` to identify the user across all the backends
- The SPA must retrieve the token securely
- To allow other Portals (like partner.example.com) to join the SSO, authorisation must be outside the main portal

**Edit the Uitsmijter Values.yaml**:
In this section we go through all the available settings and describe them in detail with recommended settings for the
demo project described above.

### Namespace

```yaml
namespaceOverride: ""
```

This value specifies the namespace in which Uitsmijter should be installed. We recommend to install into the default
namespace: `uitsmijter`. If you are planning installation into another namespace, you have to adjust Middleware paths
later on. That is very easy if you know what you are doing, but can be confusing if you are new to Kubernetes or
[🔗 Ingress middleware with Traefik](https://doc.traefik.io/traefik/middlewares/overview/). If you want to start without
hassle and without debugging it is highly recommended to install Uitsmijter in the desired namespace first.

### Repository, Images and Tags

```yaml
image:
  repository: docker.ausdertechnik.de/uitsmijter/uitsmijter
  # Overrides the image tag whose default is the chart appVersion.
  tag: ""
```

If you downloaded the newest version from the public repository the settings are just fine and work out of the box.
Only if you host Docker images at a private repository you need to change the `image.repository` path to locate to your
private copy of the image. For example: `docker.example.com/sso/uitsmijter`.

> We **do not recommend** to host a single private copy of Uitsmijter in your own repository, because we are updating
> the images to fix bugs and improve features frequently. To get informed about updates and pull from the latest version
> you may want to clone a mirror of the whole repository instead. If you do not know how to do this,
> please [ask for assistance](mailto:sales@uitsmijter.io).

The Version `tag` is set automatically according to the Application version of the Helm chart. Please be sure that you
have downloaded the latest version.
Only if you are doing an upgrade, you have to set the version by hand. For example upgrading from version `1.0.0` to
version `1.0.1` you have to set the tag:

```yaml
  tag: "1.0.1"
```

### Repository secrets

```yaml
imagePullSecrets:
```

Default is blank, because Uitsmijter is public available. But if you are cloning the repository into your private one,
it may be secured by a imagePullSecret. You can define the name of the secret here.

> Beware that the secret must be present in the namespace of Uitsmijter!

Example:

```yaml
imagePullSecrets:
  - name: my-repository-pull-secret
```

### Global settings

```yaml
jwtSecret: "vosai0za6iex8AelahGemaeBooph6pah6Saezae0oojahfa7Re6leibeeshiu8ie"
redisPassword: "Shohmaz1"
storageClassName: default-ext4
installCRD: true
installSA: true
```

You **have to** change the values of the passwords in `jwtSecret` and `redisPassword`!

The `jwtSecret` is a global passphrase with which all JWTs are signed. Applications dealing with the JWT must know
this shared secret. The `jwtSecret` should be set while installation and kept on the server only. We highly
recommend to use [🔗 config-syncer](https://github.com/kubeops/config-syncer) to share the secret into other namespaces.

From the example above we decided that the `Profile backend`, `Address book backend`, `Inbox backend`
and `Send messages backend` will get their own namespaces to collect the backend and the databases, as well as services
and ingresses all together in the domain of the service:

- profile
- address
- inbox
- sender

The `jwtSecret` will be created as a secret in the `uitsmijter` namespace (_if not changed with `namespaceOverride`_).
All the backends need to know about the secret to validate the incoming JWT. Rather than creating handwritten
secrets in all the four namespaces that can run out of sync can run out of sync while rolling the secret (_that you
should do from time to
time_), we recommend to **sync** the secret from the `uitsmijter` namespace into the `profile`, `address`, `inbox`
and `sender`namespace.

To sync the secret into namespaces add a label to the namespace the secret has to sync in:

```yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: profiles
  labels:
    jwt-secret/sync: "true"
```

`jwt-secret/sync: "true"` takes a look for the secret and syncs it into the namespace `profiles`. For more information
please take a look at
the [🔗 config-syncer documentation](https://appscode.com/products/kubed/v0.12.0/guides/config-syncer/intra-cluster/).

The Uitsmijter installation will set up a [🔗 Redis database](https://redis.io) to store refresh tokens.
The `redisPassword` will only be used inside the `uitsmijter` namespace, and you **have to** replace the value while
installing.

> Attention: after changing the redis password you have to roll out redis again and restart the services. We recommend
> to generate a random password at the first installation and keep it secret for the implementation. To roll the
> secret you may want to come back later and [🔗 read this article](https://redis.io/docs/management/security/acl/).

The `storageClassName` highly depends on your Kubernetes installation.
You can list all available storage classes with kubectl:

```shell
kubectl get sc
```

Make sure that you choose a storage class that is available on all of your nodes. For more information read the
documentation that
[🔗 describes the concept of a StorageClass](https://kubernetes.io/docs/concepts/storage/storage-classes/) in
Kubernetes.

### Config section

```yaml
config:
  # Log format options: console|ndjson
  logFormat: "console"
  # Log level options: trace|info|error|critical
  logLevel: "info"
  cookieExpirationInDays: 7
  tokenExpirationInHours: 2
  tokenRefreshExpirationInHours: 720
```

**logFormat**:
The log format can be switched between `console` and `ndjson`. console will print out each log entry on a single line
with the level and the server time:

```text
[NOTICE]   Wed, 21 Dec 2022 10:48:24 GMT: Server starting on http://127.0.0.1:8080 
```

If you are using a log aggregator it is more familiar to log in [🔗 ndjson](http://ndjson.org):

```text
{"function":"start(address:)","level":"NOTICE","date":"2022-12-21T10:52:18Z","message":"Server starting on http:\/\/127.0.0.1:8080"}
```

**logLevel**:
The standard log level is `info` and provides a good overview of what Uitsmijter is doing. `info` also prints out
notices, errors and critical alerts as well.

In case you want to see more of the applications behavior you may want to switch on the development `trace` logs. And if
you just want to get alerts about things that do not go well, you can suppress most of the info and notices by setting
the log level to `error`.

> Everything about logging is [described in this separate section](/configuration/logging)

**cookieExpirationInDays**:
You can adjust the days a cookie is valid without refreshing its value. A valid cookie means that the user is logged in.
This is highly important for the Interceptor-Mode, because if you are deleting a user it can still use your service for
the period of the cookie time! A good value to start with is **1 day**. A deleted user is valid for the maximum of 24h
in [Interceptor-Mode](/interceptor/interceptor) and with maximum of `tokenExpirationInHours` for
each [OAuth-FLow](/oauth/flow).

> The cookie expiration time has to be always equal or greater than the token expiration.
> _In the example project we assume that a user pays in a monthly subscription, and we do not have external resources
> protected with interceptor yet. In this case 7 days is a very good starting point while development the services and
> will fit our needs later on, too._

**tokenExpirationInHours**:
In [OAuth-FLow](/oauth/flow) the user exchanges an authorization code (see [grant_types](/oauth/granttypes)) for an
access and refresh token.
If the access token expires, a new valid one can obtained with the refresh token.

As long as the access token is not expired, a user is logged in, even if the user has been deleted from the credentials
service.
In the example of `2 hours` the user can access our portal at least for a maximum of 2 hours before being kicked out.
This setting is regardless of the cookie lifetime.

> Special case **silent login**: If silent login is turned on, the login might happen automatically!
> You should only rely on the token expiration time when silent login is turned off (enabled by default).
> More information is provided in the [tenant and client configuration](/configuration/tenant_client_config) section.

**tokenRefreshExpirationInHours**:
For every code exchange and every refresh the authorisation server generates a pair of an access token and a refresh
token. The access token is a Bearer encoded JWT with the user profile encoded. The refresh token is a random key that
can be used to refresh the access token.
If an access token gets invalid, the user (mostly the library that is used) can get a new fresh valid access token with
the refresh token (see [grant_types](/oauth/granttypes)).

Uitsmijter stores the refresh tokens for a defined amount of time. If a user has a valid and known refresh token, an
access token can be requested.

Therefor the refresh expiration period **must be** longer than the access token.

> Do you know those mobile Apps where you are always logged in after initial registration? Those apps know you because
> they have a very long refresh token period (sometimes ~1 year). When opening the app the first thing is to exchange
> the
> access token, regardless of the period, with the very long-lived refresh token. This is the way you are always signed
> in. In our example after 30 days (720 hours) of inactivity the user must log in with credentials again.

Our recommendation for the first installation is set as defaults. You may want to adjust the settings later on to fit to
your business model. If you need any assistance please to not hesitate
to [contact our consultants](mailto:sales@uitsmijzter.io) or ask the community.

### Domains

Uitsmijter should run at least on one domain. At least, because Uitsmijter is multi tenant and multi client aware and
one instance _can_ run for more than one domain. For large installations with multiple different brands it may be a good
idea to run one clustered Uitsmijter and provide the login functionality to different domains, so that a login does not
change the main domain to ensure the trust level for your customers.

```yaml
domains:
  - domain: "login.ham.test"
    tlsSecretName: "ham.test"
  - domain: "id.example.com"
    tlsSecretName: "example.com"
```

In the example above, Uitsmijter is available at `login.ham.test` and also at `id.example.com`. Both domains
point to the same instance.

For both of our example portals we just need one domain:

```yaml
domains:
  - domain: "id.example.com"
    tlsSecretName: "example.com"
```

### Replicas

> Uitsmijter
> supports [🔗 Horizontal Pod Autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
> well. For more details please take a look at hpa.yaml inside the helm templates.

You can set the minimum and maximum amount of replicas in the hpa.yaml. The default is set to `minReplicas: 1`
and `maxReplicas: 3`.

Congratulations, the hard part is done. You have configured your Uitsmijter installation successfully. Most of the
values should be the same as given in defaults, that is ok, you can revisit and fine tune the server later on.

## Install Uitsmijter onto your cluster

To install Uitsmijter onto your cluster a Helm Chart is provided. If you have access to the cluster and check the
privileges mentioned above, the following steps install everything right in place.

```shell
helm install uitsmijter uitsmijter/uitsmijter
```

> After installation make sure that your user has the rights to edit `Clients` and `Tenants` at least in your
> namespaces.

## Create the first Tenant

In the project example we are setting up Uitsmijter for one domain and one company. Only one tenant is needed. Examples
for a multi-tenant setup is given in the [tenant and client configuration](/configuration/tenant_client_config) section.
Our one and only tenant is called `portal`. For the configuration of this tenant we first create a new namespace
to collect all overall settings there:

```shell
kubectl create ns portal
```

In that namespace we will add the tenant. Therefore, we have to define it first:

```yaml
---
apiVersion: "uitsmijter.io/v1"
kind: Tenant
metadata:
  name: portal
spec:
  hosts:
    - portal.example.com
    - partner.example.com
  interceptor:
    enabled: false
    domain: login.example.com
    cookie: .example.com
  providers:
    - |
      class UserLoginProvider {
        constructor(credentials) { commit(true); }
        get canLogin() { return true; }
        get userProfile() { return {message:"DO NOT USE THIS IN PRODUCTION"}; }
        get role() { return "development"; }
      }
    - |
      class UserValidationProvider {
        constructor(args) { commit(true); }
        isValid() { return true; }
      }
```

Save the file to `portal-tenant.yaml`.

Important for HPA: Change the `ident` with a new generated uuid and keep it consistent along the tenant name.
You can learn everything about tenants in [tenant and client configuration](/configuration/tenant_client_config)
section.

To get started quickly we have to care about the `providers` only. The script above is just a working example that
logs in **every user** with **every password**. That is not what we want. We have created a credentials service above
that checks the user credentials in a database and returns a profile if found. The service takes an `username` and
a `hashed password`input.

> You can learn everything about Providers on the [General provider information](/providers/providers) page and explicit
> about the **UserLoginProvider** on the [User Login Provider](/providers/userloginprovider) page.

- The described `Credentials service` provides a route "POST: /validate-login" and is accessible within the
  cluster only.
- We host the service `checkcredentials` in the namespace `usertrunk`. It is internally available
  at: `checkcredentials.usertrunk.svc.cluster.local`.
- The service expects a sha265 hashed password, because we do not send cleartext passwords to other services!

The provider scripts should look like this:

```js
class UserLoginProvider {
    isLoggedIn = false;
    profile = {};
    role = null;

    constructor(credentials) {
        fetch(`http://checkcredentials.usertrunk.svc.cluster.local/validate-login`, {
            method: "post",
            body: {
                username: credentials.username,
                passwordHash: sha256(credentials.password)
            }
        }).then((result) => {
                var subject = {};
                profile = JSON.parse(result.body);
                if (result.code == 200) {
                    this.isLoggedIn = true;
                    this.role = profile.role;
                    subject = {subject: profile.userId};
                }
                commit(result.code, subject);
            }
        );
    }

    get canLogin() {
        return this.isLoggedIn;
    }

    get userProfile() {
        return this.profile;
    }

    get role() {
        return this.role;
    }
}

class UserValidationProvider {
    isValid = false;

    constructor(args) {
        fetch(`http://checkcredentials.usertrunk.svc.cluster.local/validate-user`, {
            method: "post",
            body: {
                username: args.username,
            }
        }).then((result) => {
                var subject = {};
                profile = JSON.parse(result.body);
                if (result.code == 200) {
                    this.isValid = true;
                }
                commit(this.isValid);
            }
        );
    }

    get isValid() {
        return this.isValid;
    }
}
```

Update the script in `ll-tenant.yaml`.

The script will send the users username and a sha265 hashed password to
`checkcredentials.usertrunk.svc.cluster.local/validate-login` and if this endpoint responses successfully the
script prepares the class variables that are consumed by the auth server later in the auth process.

**That's it**. Your first secure tenant is set up and connected to your users service.

Apply the tenant to the namespace we have created above:

```shell
kubectl apply -n portal portal-tenant.yaml 
```

## Create a client

To connect an OAuth client with Uitsmijter we also have to define a client. A tenant can have multiple clients (e.g. for
an SPA and an App). The client defines what OAuth-Flows are allowed and what scopes a user can have if asked for.

Here is an example client for our SPA at `portal.portal.com`:

```yaml
---
apiVersion: "uitsmijter.io/v1"
kind: Client
metadata:
  name: example-portal
spec:
  ident: 540FF520-2BDF-4C6F-9D9F-DC88A9DB41F6
  tenantname: portal/portal
  redirect_urls:
    - https://portal.example.com/.*
  grant_types:
    - authorization_code
    - refresh_token
  scopes:
    - access
    - profile::read
    - profile::write
    - addressbook:read
    - addressbook:write
    - addressbook:delete
    - inbox:read
    - inbox:delete
    - sendmessages
  referrers:
    - https://.*.example.com/.*
  isPkceOnly: true
```

The `tenant` name must match and the uuid `ident` must be unique in the Uitsmijter universe on your cluster.
We only allow clients that are connected from the `referrers`: https://.*.example.com/.*, that includes all
subdomains of example.com and login can happen from any path of that domains.
This makes it possible to request a login even from a landing page like `specialoffers.example.com`, but the
redirect is allowed to `https://portal.example.com/.*` only. So after login the user will be redirected to our
portal.

This does not work for the partner portal. Either we create a new client for that, or we expand the `redirect_urls`
array

```yaml
  redirect_urls:
    - https://portal.example.com/.*
    - https://partner.example.com/.*
```

But because the partner portal is made by another team, we recommend to add a second client.
To learn all about the client settings please take a look at
the [tenant and client configuration](/configuration/tenant_client_config) section.

## Checking the Uitsmijter configuration

Uitsmijter automatically reloads changed tenants and clients.
Take a look at the logs to see if the tenant and client is loaded without errors:

```shell
kubectl logs -n uitsmijter -l app=uitsmijter -l component=authserver
```

You should see something similar to these lines:

```text
Fount 1 items in TenantList/uitsmijter.io/v1
Found tenant in crd: example-portal from namespace: portal
Load tenant from crd: example-portal successfully
Added new tenant 'example-portal' [EDB1B825-CFED-41F0-A844-682D7B695B72] with 1 hosts
```

and the client

```text
Fount 5 items in ClientList/uitsmijter.io/v1
Found client in crd: example-portal from namespace: portal
Load client from crd: example-portal
Added new client 'example-portal' [540FF520-2BDF-4C6F-9D9F-DC88A9DB41F6] for tenant 'portal'
```

**Congratulations!! All is set up, and you can build your portal with an OAuth login flow.**
If you aren't familiar with Single page OAuth flows, we have prepared a little demo application
at [spa.littleletter.de](https://spa.littleletter.de). The sourcecode is available.
Please [ask](mailto:sales@uitsmijter.io) for any assistance.

## Further readings

- [Walkthrough guide for securing static webserver resources](/interceptor/quickstart)
- [Migrating a monolith application into microservices with single sign on](/interceptor/migrating_monolith)
