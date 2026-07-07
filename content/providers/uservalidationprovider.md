---
title: 'User Validation Provider'
geekdocHidden: false
weight: 3
---

# User Validation Provider

A user validation provider is responsible for checking if a **Username** is still valid to access the application. A
user could be invalid if the user is removed from the backend user store.

Everytime a user tries to refresh a token, the `User Validation Provider` will be asked if the user is still valid.
The Provider will not be called on a regular login!

At login, Uitsmijter delegates the credentials the [User Login Provider](/providers/userloginprovider) to the user
backend provider. The provider must check these credentials against its user data store (e.g. kubernetes internal
server, like described in the [quick start guide](/general/quickstart)). When a user is logged in successfully an access
and a refresh token will be sent to the user. If the user exchanges the refresh token into a new access token the
`User Validation Provider` will ask the user data store if the user is still allowed to log in.

As all providers, the `User Validation Provider` should be written in ECMA-Script. The user service it is requesting can
be anything that accepts a http request and sends a proper response with valid status codes:

- [🔗 200](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/200) for OK
- [🔗 401](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/401) for Unauthorized

## Parameters

| Parameter          | Description                                                                                                              |
|--------------------|------------------------------------------------------------------------------------------------------------------------|
| constructor(:args) | A Object with the properties `username` and `tenant` is passed into the init function. `tenant` carries `name` and `namespace`. |

## Methods

Those methods/getters must be implemented:

| Method             | Description                                                                      |
|--------------------|----------------------------------------------------------------------------------|
| constructor(:args) | Initialisation method that gets the `username` and the `tenant` (`name`, `namespace`) for the user in question. |
| isValid            | Getter that should indicate if the current user in context can sill be logged in |

After the constructor called `commit(:args)` the getter `isValid` must have the correct values.

Examples:

```javascript
isValid = false;
constructor(args)
{
    this.isValid = true;
    // than commit at the end
    commit(true);
}

get
canLogin()
{
    return this.isValid;
}
```

Full example that fetches a cluster internal user data store to validate the username:

```javascript
class UserValidationProvider {
    isValid = false;

    constructor(args) {
        fetch(`http://checkcredentials.checkcredentials.svc.cluster.local/validate-user`, {
            method: "post",
            body: {username: args.username}
        }).then((result) => {
            if (result.code == 200) {
                this.isValid = true;
            }
            commit(this.isValid);
        });
    }

    get isValif() {
        return this.isValid;
    }
}
```

## Tenant Context

In addition to `username`, the constructor argument carries the `tenant` the validation is performed for. This lets a
provider scope its request to the correct tenant, which is useful for multi-tenant user services that share a single
provider script.

The `tenant` object has the following shape:

```
tenant: { name: "<tenant name>", namespace: "<kubernetes namespace, or null for file-based tenants>" }
```

Read it via `args.tenant.name` and `args.tenant.namespace`:

```javascript
constructor(args) {
    fetch(`http://users.example.com/validate-user`, {
        method: "post",
        body: {
            tenant: args.tenant.name,
            namespace: args.tenant.namespace,
            username: args.username
        }
    }).then((result) => {
        if (result.code == 200) {
            this.isValid = true;
        }
        commit(this.isValid);
    });
}
```

This is additive and backward compatible — existing scripts that ignore `tenant` keep working.
