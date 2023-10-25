---
title: 'Grant Types'
weight: 2
---

# Grant Types

In OAuth 2.0, the term “grant type” refers to the way an application gets an access token.
Uitsmijter supports several grant types.

## Configuration

Grant types can be set at `Client` level.

```yaml
  grant_types:
    - authorization_code
    - refresh_token
    - password
```

If none of any grant type is specified, that `authorization_code` and `refresh_token` are enabled by default.

## Authorization Code

The authorization code flow is a way to grant access to a protected resource, such as an API, by an external client.
This flow involves multiple steps, which can be summarized as follows:

1. The client makes a request to the authorization server, asking for permission to access the resource on behalf of the
   resource owner (e.g. user). This request typically includes information about the client, such as its name and the
   scope of access being requested.
2. If the authorization server determines that the request is valid, it will redirect the user's browser to the client's
   redirect URI, along with an authorization code. This code is a temporary, one-time-use token that is meant to be
   exchanged for an access token.
3. The user's browser follows the redirect and sends the authorization code to the client.
4. The client sends a request to the authorization server, asking to exchange the authorization code for an access
   token. This request includes the authorization code and other information, such as the client's credentials and the
   redirect URI.
5. If the authorization server determines that the request is valid, it will issue an access token to the client. The
   access token is a long-lived token that can be used to make authenticated requests to the protected resource.

In summary, the authorization code flow is a way for a client to obtain an access token by redirecting the user to the
authorization server and obtaining an authorization code, which is then exchanged for an access token. This flow is
commonly used by web applications, as it allows the client to access resources on behalf of the user without having to
handle the user's credentials directly.

The following values must be set in the request for an access token:

| Property      | Value                | Description                                                                                                                    |
|---------------|----------------------|--------------------------------------------------------------------------------------------------------------------------------|
| grant_type    | authorization_code   | This tells the server we’re using the authorization_code grant type                                                            |
| client_id     | _UUID of the client_ | The public identifier of the application that the developer obtained during registration                                       |
| client_secret | (optional)           | Must be set if the client request an secret. Reed more on [tenant and client config](/configuration/tenant_client_config) page |
| scope         | (optional)           | If the application is requesting a token with limited scope, it should provide the requested scopes here                       |
| code          | _authorization code_ | The previous requested authorisation code. See [endpoints](/oauth/endpoints) and [OAuth flow](/oauth/flow)                     |

### Example

```shell
curl -v \
  -X POST \
  -H 'Content-Type: application/json' \
  -d '
  {
    "grant_type": "authorization_code",
    "client_id": "D742D5BF-0402-4C04-9FF8-94C1D2DA5BE2",
    "scope": "read learn",
    "code": "fuc6Ohah3ail"
  }
  ' \
  "https://login.example.com/token" 
```

The server replies with an access token and a refresh token:

```json
{
  "access_token": "aoth5bie8eiy2iPhaeghai6aijahvaeshungae8phieva6tiebeequ6tushei3ei",
  "refresh_token": "DOO5AHD6SAi9PA1OOKIAZoOSHOHgO1TO",
  "token_type": "bearer",
  "expires_in": 7200,
  "scope": "read learn"
}
```

You can use that `access_token` to make request to API backends by setting the value to the authorisation header:

```shell
curl -v \
  -H 'Content-Type: application/json' \
  -H 'Authorisation: Bearer aoth5bie8eiy2iPhaeghai6aijahvaeshungae8phieva6tiebeequ6tushei3ei' \
  "https://api.example.com/resource" 
```

## Refresh Token

A refresh token flow is a way to obtain a new access token by using a refresh token, which is a special kind of token
that is issued along with the access token. Refresh tokens are intended to be long-lived, and can be used to obtain a
new access token when the original access token expires or becomes invalid. This flow involves the following steps:

1. The client makes a request to the authorization server, asking to exchange the refresh token for a new access token.
   This request typically includes the refresh token and other information, such as the client's credentials.
2. If the authorization server determines that the request is valid, it will issue a new access token to the client.
   The new access token will have a new expiration time, and can be used to make authenticated requests to the protected
   resource just like the original access token.

This flow allows the client to continue accessing the protected resource even after the original access token has
expired, without requiring the user to go through the authorization process again.

The following values must be set in the request for an access token:

| Property      | Value                | Description                                                                                                                    |
|---------------|----------------------|--------------------------------------------------------------------------------------------------------------------------------|
| grant_type    | refresh_token        | This tells the server we’re using the refresh token grant type                                                                 |
| client_id     | _UUID of the client_ | The public identifier of the application that the developer obtained during registration                                       |
| client_secret | (optional)           | Must be set if the client request an secret. Reed more on [tenant and client config](/configuration/tenant_client_config) page |
| scope         | (optional)           | If the application is requesting a token with limited scope, it should provide the requested scopes here                       |
| refresh_token | _token_              | The previous requested refresh token that came with the last access token.                                                     |

### Example

```shell
curl -v \
  -X POST \
  -H 'Content-Type: application/json' \
  -d '
  {
    "grant_type": "refresh_token",
    "client_id": "D742D5BF-0402-4C04-9FF8-94C1D2DA5BE2",
    "refresh_token": "DOO5AHD6SAi9PA1OOKIAZoOSHOHgO1TO"
  }
  ' \
  "https://login.example.com/token" 
```

The server replies with a fresh access token and a new refresh token:

```json
{
  "access_token": "ga2iqueikaathoiK8Aeghiew5oos5phohtaize3dimiev8ooDautha3mipei6dee",
  "refresh_token": "EINA6AITHODAHTHAHBAYAEXAUDAIQU6D",
  "token_type": "bearer",
  "expires_in": 7200,
  "scope": "read learn"
}
```

You can use that new `access_token` to make request to API backends by setting the value to the authorisation header:

```shell
curl -v \
  -H 'Content-Type: application/json' \
  -H 'Authorisation: Bearer ga2iqueikaathoiK8Aeghiew5oos5phohtaize3dimiev8ooDautha3mipei6dee' \
  "https://api.example.com/resource" 
```

## Password

Clients explicitly have to turn on the `password` grant type to support it!

The `password` grant type should be used **for testing purposes only**. In OAuth the `password` grant type is often
called `implicit grant flow`. The user directly sends the username and the **cleartext password** to
the `Authorization server` and receives a valid `access token` when the credentials match.

The returned token contains only a valid `access token` without a `refresh token`. Users with this kind of token pair
have to log in again after the valid token period expires.

If you ask yourself if you should implement a `password grant type` for your application, the answer is: No! Consider
to use a `authorization code grant type` instead.

> **ATTENTION**
> The implicit grant type causing the authorization server to issue access tokens in the authorization response. The
> tokens are vulnerable to access token leakage and access token replay.
>
> In order to avoid these issues, clients **SHOULD NOT** use the implicit grant and any other response type causing the
> authorization server to issue an access token in the authorization response.

So why this type is implemented? Besides testing purposes, some legacy clients require this grant type. Uitsmijter is
build from ground up to support migration projects. If you do have some kind of application in your tech-stack, you
may want to turn this grant type on for development. Please migrate your app to `authorization code grant type` before
going life.

The following values must be set in the request for an access token:

| Property      | Value                | Description                                                                                                                    |
|---------------|----------------------|--------------------------------------------------------------------------------------------------------------------------------|
| grant_type    | password             | This tells the server we’re using the password grant type                                                                      |
| client_id     | _UUID of the client_ | The public identifier of the application that the developer obtained during registration                                       |
| client_secret | (optional)           | Must be set if the client request an secret. Reed more on [tenant and client config](/configuration/tenant_client_config) page |
| scope         | (optional)           | If the application is requesting a token with limited scope, it should provide the requested scopes here                       |
| username      |                      | The user’s username that they entered into the application                                                                     |
| password      |                      | The user’s password that they entered into the application                                                                     |

### Example

```shell
curl -v \
  -X POST \
  -H 'Content-Type: application/json' \
  -d '
  {
    "grant_type": "password",
    "client_id": "e92b4a0b-d1d7-4d55-b2e3-dc570faca745",
    "client_secret":"luaTha1qu019ohc13qu3ze1yuo5MumEl0hQuoE9bon",
    "scope": "read learn",
    "username": "testuser@example.com",
    "password": "Tes1Pas5w0r1"
  }
  ' \
  "https://login.example.com/token" 
```

The server replies with an access token:

```json
{
  "access_token": "MTQ0NjOkZmQ5OTM5NDE9ZTZjNGZmZjI3",
  "token_type": "bearer",
  "expires_in": 7200,
  "scope": "read learn"
}
```

You can use that `access_token` to make request to API backends by setting the value to the authorisation header:

```shell
curl -v \
  -H 'Content-Type: application/json' \
  -H 'Authorisation: Bearer MTQ0NjOkZmQ5OTM5NDE9ZTZjNGZmZjI3' \
  "https://api.example.com/resource" 
```

## Further readings

- Available [Endpoints](/oauth/endpoints)
- Client side [JWT Decoding](/oauth/jwt_decoding)
- Authorization Code Flow with [Proof Key for Code Exchange](/oauth/pkce)
