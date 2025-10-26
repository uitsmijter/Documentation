---
title: 'General provider information'
weight: 1
---

# General provider information

Because Uitsmijter does not store user authentication data, providers are written to verify if given credentials are valid. Each `tenant` has a set of providers to do certain tasks.
The [User Login Provider](/providers/userloginprovider) is responsible for the user backend which knows how to verify
user credentials. The [User Validation Provider](/providers/uservalidationprovider) is responsible to check if a
`username` still exists in the backend user store.

The design of the authorization server is built to work with different - especially already existing - backends. It is
one of the goals to easily be attachable to existing projects. Replacing an old in-app login form with an SSO should be
very simple and straight forward. Tasks like user migration is not necessary as user data stays in its existing
location.
Changing user backends means changing the provider code and not migrating user data.

## Language

Provides are written in [ECMA-Script](https://www.ecma-international.org) (better known
as [JavaScript](https://en.wikipedia.org/wiki/JavaScript)). The runtime is based
upon [Webkit](https://github.com/WebKit/webkit) and has a few additional convenience functions:

| Function      | Description                                               |
|---------------|-----------------------------------------------------------|
| console.log   | Logs to the `info` level                                  |
| console.error | Logs to the `error` level                                 |
| say           | A shorthand for `console.log`                             |
| fetch         | Method to fetch an external resource                      |
| commit        | Commit the provider's result and hand back to the process |
| md5           | Hashes a string into a md5 checksum                       |
| sha256        | Hashes a string into a sha256 checksum                    |

### Provider classes to implement

Each `tenant` has to implement a [User Login Provider](/providers/userloginprovider) code snippet and a
[User Validation Provider](/providers/uservalidationprovider) (both are called: provider)

Minimal example:

```yaml
  providers:
    - class UserLoginProvider {
      constructor(credentials) { commit(true); }
      get canLogin() { return true; }
      get userProfile() { return {message:"DO NOT USE THIS IN PRODUCTION"}; }
      get role() { return "development"; }
      }
    - class UserValidationProvider {
      constructor(args) { commit(true); }
      get isValid() { return true }
      }
```

The providers are responsible for verifying the user and retrieving the user profile for the authorization server.
Providers are only glue code and normally should not implement any business logic.
Typically, providers send a request to a service and commit the result back.

Example:

```yaml
  providers:
    - |
      class UserLoginProvider {
        isLoggedIn = false;
        profile = {};
        role = null;
        constructor(credentials) {
          fetch(`http://checkcredentials.checkcredentials.svc.cluster.local/validate-login`, {
            method: "post",
            body: { username: credentials.username, passwordHash: sha256(credentials.password) }
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
        get canLogin() { return this.isLoggedIn; }
        get userProfile() { return this.profile; }
        get role() { return this.role; }
      }
    - |
      class UserValidationProvider {
        isValid = false;
        constructor(args) {
          fetch(`http://checkcredentials.usertrunk.svc.cluster.local/validate-user`, {
            method: "post",
            body: {
              username: args.username,
            }
          }).then((result) => {
            response = JSON.parse(result.body);
            if (result.code == 200 && response.isDeleted === false) {
              this.isValid = true;
            }
            commit(this.isValid);
          });
        }
        get isValid() {
          return this.isValid;
        }
      }
```

For the `UserLoginProvider` you **have to** `commit` the results within the `constructor` method. You also **have to**
provide the three getters:

- canLogin
- userProfile
- role

For the `UserValidationProvider` you **have to** `commit` a status within the `constructor` method that indicates that
your operation is done. You also **have to** provide one getter:

- isValid

Provider execution time is limited. The advanced setting `SCRIPT_TIMEOUT` can modify this behavior.
The default timeout is **30 seconds**, which is recommended unless you need a shorter timeout. The provider must
complete all tasks within this time limit, including performing all necessary requests and returning the result.

## Further readings

- [User Login Provider](/providers/userloginprovider)
- [User Validation Provider](/providers/uservalidationprovider)