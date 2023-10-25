---
title: 'OAuth flow'
weight: 1
---

# OAuth flow

OAuth 2.0 is an open standard for authorization that enables third-party applications to obtain limited access to a
user's resources without requiring the user to provide their login credentials.

There are several flows that can be used with OAuth 2.0, depending on the type of application and the
resources it needs to access. Here is a brief overview of the most common flows that ist supported by Uitsmijter:

1. **Authorization code flow**: This flow is used by web applications that need to access resources on behalf of a user.
   The flow consists of the following steps:

- The user is redirected to the authorization server, where they are asked to grant the application access to their
  resources.
- If the user grants access, the authorization server returns an authorization code to the application.
- The application exchanges the authorization code for an access token and a refresh token.
- The application can use the access token to make API requests on behalf of the user.
- If the access token expires, the application can use the refresh token to obtain a new one.

> Uitsmijter supports authorization code flow with [PKCE extension](/oauth/pkce) that is suited to use for
> single-page-applications as well.

2. **Implicit flow**: This flow is similar to the authorization code flow, **but it is deprecated**. The flow consists
   of the following steps:

- The user is redirected to the authorization server, where they are asked to grant the application access to their
  resources.
- If the user grants access, the authorization server returns an access token to the application.
- The application can use the access token to make API requests on behalf of the user.
- There is **no refresh token in this flow**, so the access token must be used immediately and **cannot** be refreshed.

> Uitsmijter supports the implicit flow when it is explicit turned on only! this flow should be treated as deprecated.

Implicit flow can be turned on in the client `grant_type` config:

```yaml
grant_types:
  - password
```

See [tenant and client config](/configuration/tenant_client_config) for more details.

3. **Refresh token flow** is a way to obtain a new access token using a refresh token, which is a token that is issued
   along with the access token and can be used to obtain a new access token when the original one expires. Here is an
   overview of the refresh token flow:

- The application uses the access token to make API requests on behalf of the user.
- When the access token expires, the application sends a request to the authorization server to exchange the refresh
  token for a new access token.
- The authorization server returns a new access token to the application.
- The application can use the new access token to make API requests on behalf of the user.

The refresh token flow is typically used in conjunction with the **authorization code flow**. It allows the application
to obtain a new access token without requiring the user to grant access again.
This is useful in cases where the user has granted the application long-term access to their resources, and the
application needs to be able to access those resources continuously without requiring the user to re-authorize it.

## General schematic of the authorization code flow

### Backend-For-Frontend

A backend for frontend (BFF) is a layer in an application architecture that sits between the frontend (client-side) and
the backend (server-side). The purpose of a BFF is to provide a specific set of APIs that are tailored to the needs of
the frontend, rather than exposing the full set of APIs from the backend.

In general, a BFF is useful when the frontend and backend of an application are developed and maintained by separate
teams, or when the frontend needs to access multiple backend services in a specific way. It provides a way to decouple
the frontend and backend and make it easier to manage the interactions between them.

Implementing a OAuth flow into a BFF-style application works like this schematic show:

![OAuth flow in BFF](/resources/oauthflow/bff.png "OAuth flow in a BFF-style application")

**First the good part**: you do not have to implement all the request response cycle by your own, there are several
libraries that handle all of this for you. However, we recommend that you understand the process in order to be able to
resolve any problems in your implementation.

**A typical OAuth flow for logins for a BFF**:  
The user makes the first request in a Browser to the backend server (1). When the user is unauthenticated the backend
server returns a redirect response (2) that the browser will follow to request an authorisation code (3). The
authorisation server prompts a login form, validated the credentials (4) and return a code response (5) within a
callback information. The Browser than takes the code and sends it to the backend server (6). The backend server takes
that code for an exchange (7). The authorisation server validates the code and if PKCE is active validates the proof
key, too (8). If everything is correct, the authorisation server responds the token (9). Only the backend server have
knowledge of the code and the frontend seen the code only! The backend server can talk to the resource server with the
valid token attached (10) for initial requests and for exchanging resources (11). The Browser gets responses from the
backend server only that have to keep the token for the user secure.

The BFF should send the token in an authorisation header to the resource server. The browser should never see the token
in a request response cycle.

### Single Page Application and mobile apps

A single-page application (SPA) is a type of web application that loads a single HTML page and dynamically updates the
page as the user interacts with the application.

In a traditional web application, the user clicks on a link or submits a form, and the server responds by sending a new
HTML page to the client. In an SPA, the user interacts with the application, and the application sends requests to the
server to retrieve data or perform actions. The server responds with data, rather than a new HTML page, and the
application updates the page dynamically to reflect the new data.

SPAs are designed to provide a more responsive and interactive user experience, as they do not require the page to be
reloaded each time the user performs an action. They can also reduce the amount of data transmitted between the client
and server, as the server only needs to send data, rather than a full HTML page, for each request.

**The architectural design of an SPA is similar to that of a mobile app** in that both types of applications are
designed to run client-side and provide a responsive, fluid user experience. In an SPA, the entire application is loaded
onto the client device, and subsequent interactions with the application are handled through JavaScript and APIs,
without the need to reload the page. This allows the application to respond to user actions quickly and seamlessly, much
like a native mobile app.

The **authorization code flow** is a bit different to that described in Backend-For-Frontend, because there is no
backend involved that keeps track of the user session.

> **Attention**:
>
> The authorization code flow with [PKCE](/oauth/pkce) (Proof Key for Code Exchange) extensions **should be used** when
> implementing authentication in single-page applications (SPAs) and mobile apps. PKCE is an additional security measure
> that helps to protect against certain types of attacks, such as code injection or man-in-the-middle attacks, by using
> a secret key that is verified at the time of the authorization request and again when the authorization code is
> exchanged for an access token. By using the authorization code flow with PKCE extensions, you can ensure that your SPA
> or mobile app is secure and that user data is protected.
>

Implementing a OAuth flow into a BFF-style application works like this schematic show:

![OAuth flow in SPA and mobile apps](/resources/oauthflow/spa.png "OAuth flow in a SPA-style application")

**Again the good part**: you do not have to implement all the request response cycle by your own, there are several
libraries that handle all of this for you. Nevertheless, we recommend understanding the process to better troubleshoot
potential implementation errors.

A typical OAuth flow for logins for a SPAs and mobile apps:
The browser or app (user) explicit request a login (1) at the authorisation server. The authorisation server send a
redirect link to the login page (2) back to the user. The users browser follows the redirect (3) to request an
authorisation code. If the user is not logged in the authorisation server prompt a login page (4) and validates the
credentials. If those are correct the authorisation server responds with a code (5). The browser/app takes that code and
request and access code (6). **be sure that a pkce challenge is send and
the [client have enabled](/configuration/tenant_client_config) the [PKCE-only](/oauth/pkce) flag.** Next, the
authorisation server validates the code and the pkce challenge and verifier (7) and respond with a valid token (8) back
to the browser/app. In every request from the user to the resource server (9) the token is set in the authorisation
header and the resource server can respond the requested resource (10) for valid users only by validating the JWTs.

Every aspect of this flow is covered in well known and good tested libraries.
The [demo application](https://spa.littleletter.de) uses [oidc-client-ts](https://github.com/authts/oidc-client-ts) for
example to do all the steps in the flow secure in the background.

## Further readings

- Available [Grant types](/oauth/granttypes) with examples
