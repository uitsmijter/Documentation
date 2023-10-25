---
title: 'Tenant and client configuration'
weight: 3
---

# Tenant and client configuration

Uitsmijter's goal is to offer you a login solution that can be adapted to your needs in the best possible way without
prescribing the architecture of the user interface, and that can be implemented extremely elegantly and quickly.
In order to set up a new system with Uitsmijter or to integrate Uitsmijter into an existing system, settings are
necessary that describe the desired system landscape and the surrounding environment.

Regardless if you have a very small setup, e.g. a company with one website login, or you plan Uitsmijter
for a company with multiple brands, different websites, apps and third-party clients, the setup and configuration
should always be simple, easy to understand and versatile for your needs.

Configure one tenant with one client at least.

**Tenants** are seperated areas in one instance. Users, that are logged in with a client on one tenant are not logged in
to the other tenant. Tenants do have a separate user backend, can have different login masks and may support different
grant types.

> Imagine you are the Cheese Corp. You decide to launch different tools to
> support your customers. For the Toast Brand you are going to provide a barkeeper
> app with personalized recipes. Therefore, you are using a new user database. Users that are logged in to this "tenant"
> should not be mixed and matched with the already existing user base of the
> Bread & Butter Club members.
>
> Create an Uitsmijter instance and configure two tenants:
> - Bread & Butter Club
> - Toast
>
> Both can have different Login masks and different origins of user data.

**Clients** are physical or virtual device classes that can log a user on to a tenant. If a user request a Token with
one client, then this could also be used to authenticate the user with another client (called: handover). But clients
can have different settings and therefore different `scopes`. For example a web portal should allow a user to edit
(`write`) a profile, but does not allow that feature to an App that can only `read` the profile.
To request a valid authorisation token a client can define constraints and redirection rules: a website may need another
redirection target than an app, or a console application.

With the combination of a **tenant** with associated **clients** you can map the conditions of your company. Both
entities should be defined as YAML-Files. See [Deployment](deployment) to see how to provide the tenants and clients
while rollout your Uitsmijter instance.

## Tenants

Full example configuration (config file):

```yaml
name: bnbc
config:
  hosts:
    - bnbc.example
  interceptor:
    enabled: true
    domain: login.bnbc.example
    cookie: .bnbc.example
  templates:
    access_key_id: S3AccessKeyId
    secret_access_key: SecretS3AccessKey
    bucket: uitsmijter
    host: https://s3.bnbc.example
  providers:
    - |
      class UserLoginProvider {
        isLoggedIn = false;
        profile = {};
        constructor(credentials) {
          fetch("http://provider.user.srv.cluster.local/login", {
            method: "post",
            body: { user: credentials.username, password: md5(credentials.password) }
          }).then((result) => {
            console.log("User Login", credentials.username, r.code);
            if(result.status === 200){
              this.isLoggedIn = true;
              this.profile = result.body;
              return commit({subject: JSON.parse(result.body).userId});
            }
            commit(false);
          });
        }
        get canLogin() {
          return this.isLoggedIn;
        }
        get userProfile() {
          return this.profile;
        }
        get role() {
          return this.profile.role || "user"
        }
      }
    - |
      class UserValidationProvider {
        isValid = false;
        constructor(args) {
          fetch("http://provider.user.srv.cluster.local/is-known", {
            method: "post",
            body: { user: args.username }
          }).then((result) => {
            console.log("User Validation", args.username, r.code);
            if(result.status === 200){
              this.isValid = true;
              return commit(this.isValid);
            }
            commit(false);
          });
        }
        get isValid() {
          return this.isValid;
        }        
      }
```

The above example configuration is for using in a Docker-Environment and in local filesystem mode. In Kubernetes
change `config:` to `spec` and wrap `name` into `metadata`.

```yaml
metadata:
  name: bnbc
spec:
  hosts:
  # ...
```

> For local files (and docker) use `config:`, for Kubernetes use `spec:` and wrap the name into `metadata`. The rest is
> all the same.
>
> For this documentation we will use the Kubernetes version only.

There are helpers described in the [Deployment](deployment) section, that do construct the YAML files from separate
files located in your project folder. You may want to store your scripts in separate files and include them in the
tenant configuration.

A minimal (and most used) set of properties to describe a tenant would look like this:

```yaml
metadata:
  name: bnbc
spec:
  hosts:
    - bnbc.example
  providers:
    { { include ./provides/breadnbutter.js }
```

### As Kubernetes Resource

If Uitsmijter run in Kubernetes the configuration of tenants have to be provided as resources within the namespace of
the Uitsmijter authentication server.

```yaml
apiVersion: "uitsmijter.io/v1"
kind: Tenant
metadata:
  name: bnbd-tenant
spec:
  hosts:
    - bnbc.example
  interceptor:
    enabled: true
    domain: login.bnbc.example
    cookie: .bnbc.example
  informations:
    imprint_url: https://bnbc.example/imprint
    privacy_url: https://bnbc.example/privacy
    register_url: https://login.bnbc.example/register
  providers:
    - "class UserLoginProvider { [...] }"
    - "class UserValidationProvider { [...] }" 
  silent_login: true
```

### Properties

| Property          | Mandatory | Default | Example                               | Discussion                                                                                                                                                                                                                                           |
|-------------------|-----------|---------|---------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| name              | yes       | -       | `bbnc`                                | The name of the tenant depends to your architectural discussions. Consider creating tenants for different brands or companies or teams inside your company. Remember: tenants are seperated spaces inside one instance.                              |
| hosts             | yes       | -       | `["bnbc.example", "us.bnbc.example"]` | A concrete list of hosts for which the server serves the tenant. Overlapping hosts in different tenants are not allowed, they have to be unique. Be sure that the hosts are configured as ingress hosts too. |
| interceptor       | no        |         |                              | _see the full example above_ |
| interceptor.enabled | yes    |         |  | Can be set to `false` if the tenant should not support the [Interceptor-Mode](/interceptor/interceptor). |
| interceptor.domain | no      |         |  | The domain for which the interceptor should be active. |
| interceptor.cookie | no      |         |  | Cookie domain to be used in the auth cookie. |
| informations              | no | |                                 | Additional data about the tenant. |
| informations.imprint_url  | no | | `https://bnbc.example/imprint`  | URL to the imprint page. |
| informations.privacy_url  | no | | `https://bnbc.example/privacy`  | URL to the privacy policy. |
| informations.register_url | no | | `https://bnbc.example/register` | URL to the registration page. |
| templates                   | no  | not configured     |                           | S3 configuration to load templatest from |
| templates.access_key_id     | yes |                    | `[random name]`           | Access key ID |
| templates.secret_access_key | yes |                    | `[random secret key]`     | Secret access key / password |
| templates.host              | no  | `s3.amazonaws.com` | `https://s3.bnbc.example` | S3 storage server |
| templates.bucket            | yes |                    | `uitsmijter`              | S3 Bucket name |
| templates.path              | no  | -                  | `templates/business`      | Optional "path" inside the bucket |
| templates.region            | no  | `us-east-1`        | `eu-central-1`            | S3 region (if needed) |
| providers         | yes       | -       | _see the full example above_          | A list of [providers](/providers/providers). Providers are glue code only to request data from user backend systems. Consider using internal private cluster links.                                                                                  |
| silent_login      | no        | `true`  | `false`                               | When this option is enabled and a client has a valid auth cookie shared with the login page, its login information will be used to authenticate the user without asking for a username or password.                                                  |

## Clients

A client is an application that attempts to act on behalf of or access the user's resources. Before a client can access
a user's account, it must obtain permission. A client obtains permission by sending the user to the authorization server
and the authorization server redirects back to the client. A client can also assert permission directly with the
authorization server without interaction by the user, if a previously obtained `code` is present.

Defining the amount of different client depends on your needs. The list can give you a starting point:

- Do you deliver different application assets (SPA (web), App (AppStore), Shop (Web), landing page, Marketing camping,
  etc.) -> these are different Clients
- Do you deliver your applications to different operating systems (Android, iOS) -> these are different Clients
- Do you support different Versions of your applications with different features -> these are different Clients
- Are you allowing third parties to act with your authorisation server -> these are different Clients

Full example configuration for configuration files

```yaml
name: bnbc-ios-app
config:
  ident: 58392627-0121-4721-9DAC-D358BDD86CA6
  tenantname: bnbc-tenant
  redirect_urls:
    - https://www.bnbc.example/bnbc-club/.*
  grant_types:
    - password
    - authorization_code
    - refresh_token
  scopes:
    - list
    - read
    - write
  referrers:
    - https://www.bnbc.example/bnbc-club/login
  isPkceOnly: true
  secret: aejochiecaishee4ootooSh3ph
```

> Remember. For Kubernetes warp name into `metadata` and rename `config` to `spec`:

```yaml
metadata:
  name: bnbc-ios-app
config:
  ident: 58392627-0121-4721-9DAC-D358BDD86CA6
  tenantname: bnbc-tenant
  # [...]
```

### As Kubernetes Resource

If Uitsmijter run in Kubernetes the configuration of clients have to be provided as resources within the namespace of
the Uitsmijter authentication server.

```yaml
apiVersion: "uitsmijter.io/v1"
kind: Client
metadata:
  name: bnbc-ios-app
spec:
  ident: 58392627-0121-4721-9DAC-D358BDD86CA6
  tenantname: "[tenant namespace]/bnbc-tenant"
  redirect_urls:
    - https://www.bnbc.example/bnbc-club/.*
  grant_types:
    - password
    - authorization_code
    - refresh_token
  scopes:
    - list
    - read
    - write
  referrers:
    - https://www.bnbc.example/bnbc-club/login
  isPkceOnly: true
  secret: aejochiecaishee4ootooSh3ph
```

### Properties

| Property      | Mandatory | Default                                 | Example                                                       | Discussion                                                                                                                                                                                                          |
|---------------|-----------|-----------------------------------------|---------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| ident         | yes       | A random UUID                           | `58392627-0121-4721-9DAC-D358BDD86CA6`                        | The ident is the internal primary key for that client.                                                                                                                                                              |
| name          | yes       | -                                       | `bnbc-ios-app`                                                | Give the client a unique and specific name. Client should be reelect the device classes that you do need to target with specific rights and get individual statistics from.                                         |
| tenantname    | yes       | -                                       | `bnbc-tenant`                                                 | The name of the tenant for which this client is for. On kubernetes this must contain the tenants namespace: `[tennant namespace]/bnbc-tenant`                                                                       |
| redirect_urls | yes       | -                                       | `["https://www.bnbc.(example&#124;example.com)/bnbc-club/*"]` | A client sends a redirect url to which the response will be redirected to. Specify the allowed urls for security reasons, otherwise it will be possible to hijack the token in the response. See information below. |
| grant_types   | no        | ["authorization_code", "refresh_token"] | `["password"]`                                                | A list of allowed grant types. If not set, a default set will be applied: `authorization_code`, `refresh_token`. If you need to support the “password" grant, you must specify it explicitly!                       |
| scopes        | no        | []                                      | `["recipes:read", "recipes:write", "timeline:post"]`          | A list of allowed scopes for this client. If a client requests scopes, these will be filtered by the one that are allowed.                                                                                          |
| referrers     | no        | []                                      | `[https://www.bnbc.example/bnbc-club/login]`                  | If set, only clients that come from these referers are allowed.                                                                                                                                                      |
| isPkceOnly    | no        | false                                   | `true`                                                        | If set to `true` this client does support [Proof Key for Code Exchange](/oauth/pkce) only.                                                                                                                          |
| secret        | no        | -                                       | `aejochiecaishee4ootooSh3ph`                                  | if set, the clients have to send this shared secret on requests.                                                                                                                                                  |

**Possible Grant Types**

- authorization_code
- refresh_token
- password

If you allow a `authorization_code`, you should also allow `refresh_token`, because to refresh a token you need to get
one via the `authorization_code` request.
The response from a `password` request does not return a refresh token!

Try to avoid the `password` grant in production! It is insecure and should be replaced by a pkce code request. Only
if you have to support older clients you may need to turn this option on.

**Redirect Urls**
If the requested `redirect_url` of an `AuthRequest` does not match any of these url patterns, the whole
authorization request will be denied.
Try to avoid a pattern like `.*`, because this is highly insecure. Try to describe the clients domains very precisely.
eg: `https://[^\.]+\.example\.com/login_(granted|denied)`

Regular expressions are allowed to formulate redirect_urls.

**Secrets**
**Confidential clients** are clients that are able to maintain client secrecy. In general, these clients are only
applications that run on a server controlled by developers and whose source code is not available to users.

**Public clients** cannot maintain a client_secret, so the secret is not used for these applications. Javascript
applications are considered public clients. Since anyone running a Javascript application can easily see the source
code of the application, a secret would be easily visible there.

Set a secret for server-side applications where the user does not have access to the source code. 
