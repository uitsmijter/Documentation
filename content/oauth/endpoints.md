---
title: 'Available Endpoints'
weight: 3
---

# Available Endpoints

An endpoint is a specific location that is capable of accepting incoming requests, and is usually a specific URL
(Uniform Resource Locator) that is provided by an API (Application Programming Interface). An API is a set of
programming instructions and standards for accessing a web-based software application or web tool. APIs allow different
software systems to communicate with each other, and enable functionality such as requesting data from a server, or
sending data to a server for storage.

OAuth (Open Authorization) is an open standard for authorization that provides a secure method for API authentication.
OAuth endpoints are specific URLs that are used in the OAuth authorization process to request and grant access tokens to
API resources. There are two main OAuth endpoints:

1. Authorization endpoint: This is the URL where the user is redirected to in order to grant authorization to the client
   application.
2. Token endpoint: This is the URL where the client application exchanges the authorization code for an access token.

In OAuth two additional endpoints should be mentioned:

3. Redirection endpoint: This is the URL where the user is redirected after they grant or deny authorization to the
   client application.
4. Resource endpoint: This is the URL of the API resource that the client application is trying to access.

Besides the authorisation endpoint and the token endpoint Uitsmijter do provide endpoints for monitoring and metrics as
well.

This page describes the technical details of the available endpoints and shows some basic examples how to use them. 
This information is importend if you are writing your own client library implementation, but you will not need to know all
the details when using an already existent client library
like [🔗 oidc-client-ts](https://github.com/authts/oidc-client-ts).

## OAuth endpoints

### /authorize

Authorize a client to use a resource.
The `/authorize` endpoint will redirect to a callback url with an authorization code if the user logs in successfully.

You can find an example setup in our [quick start guide](/general/quickstart#create-a-client)

> **Recommendation**:
>
> Use [PKCE](/oauth/pkce) to request an authorization code.

**Example**: Request an authorization code with PKCE SHA265 code

```text
    /authorize
        ?response_type=code
        &client_id=9095A4F2-35B2-48B1-A325-309CA324B97E
        &redirect_uri=https://example.com/
        &scope=read,learn
        &state=Za8uR
        &code_challenge=3VpzZL3DpqEwubIbIVsrOUbvB19kk4yGP7gGaxU/cyQ=
        &code_challenge_method=S256
```

**Parameter description**:

| Parameter             | Description                                                                                                                                                                                                                                                                                                  |
|-----------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| response_type         | Specifies the type of response that the authorization server should return. The value is `code`, which indicates that the authorization server should return an authorization code as the response is the only allowed option.                                                                               |
| client_id             | This is the unique identifier of the client application that is making the request. Read more information about [client configuration](/configuration/tenant_client_config).                                                                                                                                 |
| redirect_uri          | This is the URL that the user should be redirected to after the authorization server grant access to the client application.                                                                                                                                                                                 |
| scope                 | This specifies the scope of the authorization that is being requested. The value of scope is a comma-separated list of permissions that the client application is requesting access to. It have to be a subset of the allowed client-level scopes.                                                           |
| state                 | This is an optional parameter that can be used to pass along state information between the authorization request and the response. The `state`'s value will be returned by the authorisation server response.                                                                                                |
| code_challenge        | This is an optional parameter that is used as part of the OAuth 2.0 [Proof Key for Code Exchange (PKCE)](/oauth/pkce) extension. It represents a challenge value that is generated by the client application and sent to the authorization server as part of the authorization request.                      |
| code_challenge_method | Is an optional parameter that is used in conjunction with code_challenge and specifies the method that was used to generate the challenge value. In this case, the value is S256, which indicates that the challenge value was generated using the SHA-256 hash function. Possible values are: S256 or PLAIN |

In case the authorisation process succeeded the authorisation server responds with a redirect:

```http request
HTTP/1.1 302 Found
Location: https://example.com/?code=KJH876GFED&state=Za8uR
```

This response includes the following parameters:

- **code**: This is the authorization code that the client application can use to request an access token.
- **state**: This is the same state value that was included in the original authorization request. It is returned as
  part of the response so that the client application can verify that the response was generated in response to the
  correct request.

This response is a 302 Found status code, which indicates that the user is being redirected to the URL specified in the
Location header. In this case, the user is being redirected to the redirect_uri that was specified in the original
authorization request, along with the code and state parameters.

### /token

Access tokens are used for applications to perform API requests on behalf of a user. The access token
represents the authorization of a specific application to access specific parts of a user’s data.

Access tokens must be kept confidential in transit and in storage. The only parties that should ever see the access
token are the application itself, the authorization server and the resource server.

Uitsmijter implements different [grant types](/oauth/granttypes) that a [client](/entities#client) may support.
For example, the authorisation code grant can be requested with a proper call to the /token endpoint and a grant
type `authorisation_code`:

```json
{
  "grant_type": "authorization_code",
  "client_id": "9095A4F2-35B2-48B1-A325-309CA324B97E",
  "scope": "read write admin_list",
  "code": "KJH876GFED"
}
```

For **legacy applications** an [implicit grant flow](/oauth/flow) can be turned on in
the [client configuration](/configuration/tenant_client_config).

```json
{
  "grant_type": "password",
  "client_id": "9095A4F2-35B2-48B1-A325-309CA324B97E",
  "scope": "read write admin_list",
  "username": "Julia@example.com",
  "password": "eis6Ooth3oDa"
}
```

If the `client` needs to be authenticated, then a `client_secret` is mandatory.

> Even if the example for a `password` grant type is chosen, it is **NOT RECOMMENDED** to use this type of grant type.
> The ability to serve a `password` grant type must be enabled explicitly.

**Parameter description**:

| Parameter  | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
|------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| grant_type | Specifies the type of grant that is being requested. The grant type determines the flow that will be used to obtain the access token. The first example uses the authorization_code grant type, which means that the client application is requesting an access token by providing an authorization code that was previously obtained through the authorization flow. The second example uses the password grant type, which means that the client application is requesting an access token by providing the user's login credentials (username and password). |
| client_id  | Is the unique identifier of the client application that is making the request.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| scope      | This specifies the scope of the authorization that is being requested. The value of scope is a space-separated list of permissions that the client application is requesting access to.                                                                                                                                                                                                                                                                                                                                                                         |
| code       | This is the authorization code that the client application is using to request an access token. This parameter is only used in the first example (authorization_code grant type) and is not present in the second (password grant type) example.                                                                                                                                                                                                                                                                                                                |
| username   | This is the username of the user who is granting authorization to the client application.                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| password   | the password of the user who is granting authorization to the client application. This parameter is only used in the password grant type.                                                                                                                                                                                                                                                                                                                                                                                                                       |

A possible response from the authorization server for the first example:

```http request
HTTP/1.1 200 OK
Content-Type: application/json

{
  "access_token": "V7vZQbJNNY7zR8IWyV7vZQbJNNY7zR8IW",
  "token_type": "Bearer",
  "expires_in": 3600,
  "scope": "read write admin_list",
  "refresh_token": "E2yCQ4yJ0E2yCQ4yJ0"
}
```

This response includes the following parameters:

- **access_token**: The access token that the client application can use to access the API resources.
- **token_type**: Specifies the type of the access token. In this case, the value is Bearer, which means that the access
  token is a bearer token and can be used to access the API resources as long as it is presented to the API server.
- **expires_in**: specifies the number of seconds until the access token expires.
- **scope**: The scope of the authorization that was granted to the client application. It should match the scope
  value that was included in the original request. If a client does not support all the requested scopes, an allowed
  subset is returned.
- **refresh_token**: A refresh token that the client application can use to obtain a new access token after the current
  one expires. (In the response of an authorization_code grant type request only!)

The refresh_token parameter is only present in the authorization_code grant type request response, because it is only
used in certain grant types. The refresh_token is used to obtain a new access token after the current one expires,
without having to prompt the user for their login credentials again. That is strictly forbidden with the password grant
type.

## Discovery endpoints

Discovery endpoints allow OAuth/OpenID Connect clients to automatically discover the configuration and capabilities of Uitsmijter without manual configuration. This is especially useful for dynamic client registration, multi-tenant deployments, and maintaining compatibility across different versions.

### /.well-known/openid-configuration

The `/.well-known/openid-configuration` endpoint provides OpenID Connect Discovery metadata as specified in [OpenID Connect Discovery 1.0](https://openid.net/specs/openid-connect-discovery-1_0.html). This endpoint returns a JSON document containing all the information that OAuth/OIDC clients need to interact with Uitsmijter, including:

- **Endpoint URLs**: Authorization, token, userinfo, and JWKS endpoints
- **Supported features**: Grant types, response types, scopes, and authentication methods
- **Cryptographic capabilities**: Signing algorithms and PKCE methods
- **Multi-tenant configuration**: Each tenant has its own discovery document with tenant-specific settings

**Why use OpenID Connect Discovery?**

Instead of manually configuring every OAuth client with endpoint URLs and supported features, clients can automatically fetch this information from the discovery endpoint. This provides several benefits:

1. **Automatic configuration**: Modern OAuth libraries (like [oidc-client-ts](https://github.com/authts/oidc-client-ts)) can automatically configure themselves by reading the discovery document
2. **Multi-tenant support**: Different tenants can advertise different capabilities (scopes, grant types, policies)
3. **Version compatibility**: When Uitsmijter is upgraded with new features, clients automatically discover the new capabilities
4. **Reduced configuration errors**: No need to manually maintain endpoint URLs in multiple client configurations

**Example**: Fetching discovery metadata

```shell
curl --request GET \
  --url https://id.example.com/.well-known/openid-configuration \
  --header 'Accept: application/json'
```

This returns a JSON document with the OpenID Provider Metadata:

```json
{
  "issuer": "https://id.example.com",
  "authorization_endpoint": "https://id.example.com/authorize",
  "token_endpoint": "https://id.example.com/token",
  "userinfo_endpoint": "https://id.example.com/userinfo",
  "jwks_uri": "https://id.example.com/.well-known/jwks.json",
  "scopes_supported": ["openid", "profile", "email", "read", "write"],
  "response_types_supported": ["code"],
  "grant_types_supported": ["authorization_code", "refresh_token"],
  "subject_types_supported": ["public"],
  "id_token_signing_alg_values_supported": ["RS256"],
  "token_endpoint_auth_methods_supported": ["client_secret_post", "client_secret_basic", "none"],
  "code_challenge_methods_supported": ["S256", "plain"],
  "claims_supported": ["sub", "iss", "aud", "exp", "iat", "name", "email", "tenant"]
}
```

**Multi-tenant discovery**

Each tenant in Uitsmijter has its own discovery endpoint with tenant-specific configuration:

```shell
# Tenant A discovery
curl https://tenant-a.example.com/.well-known/openid-configuration

# Tenant B discovery
curl https://tenant-b.example.com/.well-known/openid-configuration
```

The discovery document automatically reflects:
- Tenant-specific issuer URLs
- Aggregated scopes from all clients in the tenant
- Aggregated grant types from all clients in the tenant
- Tenant privacy policy URLs (if configured)

**Using discovery with OAuth clients**

Most modern OAuth/OIDC libraries support automatic configuration via discovery. For example, with `oidc-client-ts`:

```typescript
import { UserManager } from 'oidc-client-ts';

const userManager = new UserManager({
  authority: 'https://id.example.com',  // Base URL - library fetches /.well-known/openid-configuration
  client_id: '9095A4F2-35B2-48B1-A325-309CA324B97E',
  redirect_uri: 'https://myapp.example.com/callback',
  // All endpoint URLs and capabilities are automatically discovered!
});
```

The library will automatically fetch the discovery document and configure itself with the correct endpoints, supported scopes, and authentication methods.

> **Note**: The discovery endpoint is publicly accessible and does not require authentication. This is by design, as clients need to discover the configuration before they can authenticate.

## Profile endpoints

Even the `/token/info` endpoint is not a standard endpoint in OAuth, it is widely used to provide information about
access tokens.

To use this endpoint, you will need to make a GET request to the `/token/info` endpoint and include the access token in
the request. For example, you can use the curl command to make a request like this:

```shell
curl --request GET \
  --url https://YOUR_AUTH0_DOMAIN/token/info \
  --header 'Authorization: Bearer YOUR_ACCESS_TOKEN'
```

This will return a JSON object containing information about the access token, such as its expiration time and the scope
of the authorization that it represents. For example:

```json
{
  "name": "John Doe"
}
```

> **Customise the profile**:
>
> The JSON object returned can be customised by the user backend provider. Everything that is returned from
> the `userProfile` getter is encoded in the JWT and will be decoded in the response of teh `/token/info` call.

## Monitoring endpoints

Monitoring endpoints are endpoints that are used to monitor the health and status of Uitsmijter. These endpoints
can be accessed via HTTP requests and return information about the current state of the system,
such as its uptime, performance metrics, and login amounts as well as error counts.

Monitoring endpoints are often used by monitoring tools to check the health of the system on a regular basis. This can
help to identify potential issues or outages before they become serious problems, and can also
be used to track the performance and reliability of the system over time.

Uitsmijter implements two endpoints that are ready to use for a cluster environment.

### /health

Kubernetes (and other orchestration tools) uses a number of different health check mechanisms to monitor the health of
various components and services. One common mechanism is to use a /health endpoint that can be accessed via an HTTP
request. This endpoint is used to check the health of the component by making a request to it and examining the
response.

Uitsmijter supports the `/health` endpoint.

Uitsmijter return a `200 OK` status code if the application is healthy, or it may return a
500-status code if there is a problem. In this case the logs will have detailed information about the problem.

Kubernetes for example uses the information returned by the /health endpoint to determine the health of the
authorisation server to take appropriate action if there is a problem. For example, if the /health endpoint indicates
that Uitsmijter is unhealthy, Kubernetes may restart it or take other measures to try to restore it to a healthy state.

### /metrics

The `/metrics` endpoint is an endpoint that exposes metrics data that can be collected and stored by
a [🔗 Prometheus](https://prometheus.io) server. This endpoint can be accessed via an HTTP request (the request must
include the `Accept: application/openmetrics-text` header) and returns a text-based format called the "Prometheus text
format"
that contains the metric data.

Prometheus is a popular open-source monitoring and alerting system that is designed to collect and store metric data
from various sources.

Uitsmijter provides several metrics about http request duration, error counts and logins to tenants and clients.
The installation precess has a Grafana dashboard attached, that can be used to see business metrics about each tenant as
well as about the overall system status over time.

| Field                            | Description                                                                             |
|----------------------------------|-----------------------------------------------------------------------------------------|
| `http_request_duration_seconds`  | Summary of all requested paths by method and status.                                    |
| `http_requests_total`            | Counters of total http requests by path, status and method.                             |
| `uitsmijter_login_attempts`      | Histogram of the number of total login attempts regardless of result (success/failure). |
| `uitsmijter_login_success`       | Counter of successful logins.                                                           |
| `uitsmijter_login_failure`       | Counter of failed logins (wrong credentials or technical failure).                      |
| `uitsmijter_logout`              | Counter of successful logout actions.                                                   |
| `uitsmijter_interceptor_success` | Counter of authorized accesses to pages using the interceptor middleware.               |
| `uitsmijter_interceptor_failure` | Counter of failures trying to access pages using the interceptor middleware.            |
| `uitsmijter_authorize_attempts`  | Histogram of OAuth authorization attempts regardless of result (success/failure).       |
| `uitsmijter_oauth_success`       | Counter of successful OAuth token authorizations (all grant types).                     |
| `uitsmijter_oauth_failure`       | Counter of failed OAuth token authorizations (all grant types).                         |
| `uitsmijter_token_stored`        | Histogram of valid refresh tokens over time.                                            |
| `uitsmijter_tenants_count`       | Gauge of the current number of managed tenants.                                         |
| `uitsmijter_clients_count`       | Gauge containing the current number of managed clients for all tenants.                 |

## Further readings

- Client side [JWT Decoding](/oauth/jwt_decoding)
- [Authorization Code Flow with Proof Key for Code Exchange](/oauth/pkce)
