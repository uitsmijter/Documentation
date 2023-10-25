---
title: 'User Login Provider'
geekdocHidden: false
weight: 2
---

# User Login Provider

A `User Login Provider` is responsible for resolving a **Username** and **Password** to a user profile if the user is
valid.

If the credentials do not match, the provider is responsible for interpreting the error message / code and tell
Uitsmijter that the user is invalid.

At login, Uitsmijter delegates the credentials the user provides via the login form to the user backend provider. The
provider must check these credentials against its user data store (e.g. kubernetes internal server, like described in
the [quick start guide](/general/quickstart)).

As all providers, the `User Login Provider` should be written in ECMA-Script. The user service it is requesting can be
anything that accepts a http request and sends a proper response with valid status codes:

- [🔗 200](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/200) for OK
- [🔗 401](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/401) for Unauthorized

## Parameters

| Parameter                 | Description                                                                               |
|---------------------------|-------------------------------------------------------------------------------------------|
| constructor(:credentials) | A Object with two properties: `username` and `password` is passed into the init function. |

## Methods

Those methods/getters must be implemented:

| Method                    | Description                                                                                                |
|---------------------------|------------------------------------------------------------------------------------------------------------|
| constructor(:credentials) | Initialisation method that gets the `username` and the `password` for the user in question.                |
| canLogin                  | Getter that should indicate if the current user in context can be logged in (has valid credentials) or not |
| userProfile               | Getter that should return the users profile.                                                               |
| role                      | Getter that should return the users role.                                                                  |

After the constructor called `commit(:obj)` the two getters `canLogin` and `userProfile` must have the correct values.
Before the constructor calls `commit(:obj)` the values to differentiate the login state have to be set for sure.
That means, that you should always finish the constructor script execution with a `commit(...)`.

Examples:

```javascript
isLoggedIn = false;
constructor(credentials)
{
    // set class variables first
    this.isLoggedIn = true;
    // than commit at the end
    commit(true);
}

get
canLogin()
{
    return this.isLoggedIn;
}
```

Full example that fetches a cluster internal user data store to validate the credentials. The user data store accepts
passwords as a sha265 hash:

```javascript
class UserLoginProvider {
    isLoggedIn = false;
    profile = {};
    role = null;

    constructor(credentials) {
        fetch(`http://checkcredentials.checkcredentials.svc.cluster.local/validate-login`, {
            method: "post",
            body: {username: credentials.username, passwordHash: sha256(credentials.password)}
        }).then((result) => {
            var subject = {};
            profile = JSON.parse(result.body);
            if (result.code == 200) {
                this.isLoggedIn = true;
                this.role = profile.role;
                subject = {subject: profile.userId};
            }
            commit(result.code, subject);
        });
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
```

## Optional committed subject

The `:obj` parameter in `commit(:obj)` is a variadic list of parameters and **may have** one object included that
contains an object with a `subject` property in it. The subject is taken to identify the user across all the systems
and must be unique for that users.

A common subject is the `userid` from your members' database, or another person identifier like an `uuid`, `username` or
the
users personal email` address. You have to take care that the subject is directly correlated to the user without any
doubt.
The subject reflects the "primary key" of the logged-in user.

If your user data source is in a SQL Database and you validate the login with a simple query like
`select id, username from login where username = '$user' and password ='$pass'` than return the `id` as a subject back
to Uitsmijter.

The object with the subject can be enriched with any other data. That data will be written to the log, but ignored for
further execution. It must contain a `subject` property, but can contain other properties.

**Examples for valid objects:**
Just an ID:

```json
{
  "subject": 1734034
}
```

ID with other data;

```json
{
  "name": "Lorene Ibsen",
  "subject": 1734034,
  "instrument": "Piano"
}
```

String subject:

```json
{
  "subject": "lorene.ibsen@example.com"
}
```

> **If no subject is specified**, the login name (`username` from the login section) is used as the subject!
> Since `username` must be unique from the start, this is a good default value, but you can override it with your
> your own value, e.g. an ID.

The position inside the variadic list is irrelevant. All other parameters will be ignored, but the first one with a
`subject` parameter will be evaluated and overwrite the `subject` of the JWT issued.

**Example of valid commitments:**

```js
commit({subject: "lorene.ibsen@example.com"})
```

```js
commit(true, {subject: "lorene.ibsen@example.com"})
```

```js
commit({message: "A good login"}, {"subject": "lorene.ibsen@example.com"}, {error: false})
```

```js
commit(response.status, {"subject": "lorene.ibsen@example.com"}, {error: false})
```

## Examples

**Simple Example**  
This example allows any user whose username is "frodo@example.com". Do not use this in production!

```js
class UserLoginProvider {
    isLoggedIn = false;

    constructor(credentials) {
        if (credentials.username == "frodo@example.com") { // Do not use this in production!
            this.isLoggedIn = true;
        }
        commit({subject: "frodo"});
    }

    // Getter
    get canLogin() {
        return this.isLoggedIn;
    }

    get userProfile() {
        return {
            name: "Frodo Baker",
            species: "Musician",
        };
    }

    get role() {
        return "user";
    }
}
```

**Fetch Backend Example**   
This example allows a user log in for in every user/password combination that is known in a backend system.

```js
class UserLoginProvider {
    isLoggedIn = false;
    profile = {};

    constructor(credentials) {
        fetch(`https://example.com/users/auth`, {
            method: "post",
            body: credentials
        }).then((result) => {
                var subject = {};
                profile = JSON.parse(result.body);
                if (result.code == 200) {
                    this.isLoggedIn = true;
                    subject = {subject: profile.userId};
                }
                commit(result.code, subject);
            }
        );
    }

    // Getter
    get canLogin() {
        return this.isLoggedIn;
    }

    get userProfile() {
        return profile;
    }

    get role() {
        return profile.role || "user";
    }
}
```

## Further readings

- [User Validation Provider](/providers/uservalidationprovider)
