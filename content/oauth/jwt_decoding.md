---
title: 'JWT Decoding'
weight: 4
---

# JWT Decoding

OAuth does not have a specific standard "profile endpoint" for decoding the content of a JSON Web Token (JWT). OAuth is
a standard for authorization, which means that it is primarily concerned with granting and revoking access to resources,
rather than with providing information about the user who is accessing the resources.
But certain libraries (like `oidc-client-ts`) expecting it for decoding a profile content, so Uitsmijter supports
a decoding endpoint for valid and non expired tokens at `GET /token/info`. See more details at
the [endpoint documentation](/oauth/endpoints).

That being said, it is common for OAuth servers to include information about the user in the JWT that is issued as part
of the authorization process. This information is typically encoded in the "claims" of the JWT, and can include the
user's internal id, name, username, email address, and other details.

To decode the content of a JWT, you can use a library or tool that is capable of parsing and verifying JWTs. There are
many such libraries and tools available, and they typically provide functions or APIs that you can use to decode the JWT
and access the claims contained within it.

For example, in the Node.js runtime environment, you can use
the [🔗 jsonwebtoken library](https://github.com/auth0/node-jsonwebtoken) to decode a JWT and access its claims like
this:

```javascript
const jwt = require('jsonwebtoken');

const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c';

const decoded = jwt.verify(token, secret);
console.log(decoded);
```

This will decode the JWT and output the claims contained within it to the console. You can then access the individual
claims using the dot notation, like this:

```javascript
console.log(decoded.name); // "John Doe"
```

## Token Claims

A decoded token contains the standard claims (`iss`, `sub`, `aud`, `exp`, `iat`) alongside Uitsmijter specific claims
such as `tenant`, `profile`, `scope` and `role`:

```json
{
  "iss": "https://auth.example.com",
  "sub": "user@example.com",
  "aud": "550e8400-e29b-41d4-a716-446655440000",
  "exp": 1736649600,
  "iat": 1736563200,
  "tenant": "example-tenant",
  "role": "admin",
  "roles": [
    "admin",
    "editor",
    "user"
  ],
  "scope": [
    "openid",
    "email",
    "profile"
  ],
  "profile": {
    "email": "user@example.com",
    "name": "John Doe"
  }
}
```

| Claim   | Type            | Discussion                                                                                                                                                            |
|---------|-----------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| role    | string          | The primary role of the user, as returned by the provider's `role` getter.                                                                                            |
| roles   | array of string | Optional. Present when the provider exposes multiple roles. Contains all roles of the user; the single `role` claim mirrors the primary (first) entry of this list.   |
| scope   | array of string | The final list of scopes granted to the token after filtering and merging. See [Scopes](/oauth/scopes).                                                               |

The `roles` claim is **omitted for single-role providers**, so tokens issued by existing providers remain unchanged.
When it is present, the single `role` claim always mirrors the primary (first) role for backward compatibility.

## Further readings

- [Authorization Code Flow with Proof Key for Code Exchange](/oauth/pkce)

