---
title: 'OAuth Scopes and Scope Filtering'
weight: 6
---

# OAuth Scopes and Scope Filtering

OAuth 2.0 scopes are a mechanism to limit an application's access to a user's resources. Scopes define what permissions an application has and what data it can access on behalf of the user.

Uitsmijter implements a **two-tier scope filtering system** that provides fine-grained control over which scopes are granted to users:

1. **Client-requested scopes** - Scopes that the OAuth client application requests during authorization
2. **Provider-supplied scopes** - Scopes that JavaScript authentication providers dynamically add based on user context

Both types of scopes are independently filtered before being merged into the final JWT token, providing defense-in-depth security.

## Understanding Scopes

Scopes are strings that represent specific permissions or access levels. They are typically formatted as:

- **Simple scopes**: `read`, `write`, `profile`, `email`
- **Hierarchical scopes**: `user:read`, `user:write`, `admin:delete`, `org:manage`

The hierarchical format (using `:` as a separator) is recommended as it allows for wildcard pattern matching and better organization of permissions.

## Two-Tier Scope Filtering

### Tier 1: Client-Requested Scopes

When an OAuth client initiates an authorization request, it can request specific scopes:

```http
GET /authorize?response_type=code
  &client_id=550e8400-e29b-41d4-a716-446655440000
  &redirect_uri=https://app.example.com/callback
  &scope=openid+email+profile+admin:delete
```

These requested scopes are **filtered** against the client's `scopes` configuration field:

```yaml
apiVersion: "uitsmijter.io/v1"
kind: Client
metadata:
  name: my-app
spec:
  ident: 550e8400-e29b-41d4-a716-446655440000
  scopes:
    - openid
    - email
    - profile
    # admin:delete is NOT in the allowed list
```

**Result**: Only `openid`, `email`, and `profile` are allowed. The `admin:delete` scope is rejected.

### Tier 2: Provider-Supplied Scopes

JavaScript authentication providers can dynamically return scopes based on user context (roles, groups, permissions):

```javascript
class UserLoginProvider {
    get scopes() {
        // Return scopes based on user role
        if (this.profile.role === "admin") {
            return ["user:*", "admin:*", "org:*"];
        }
        return ["user:read", "user:list"];
    }
}
```

These provider-returned scopes are **filtered** against the client's `allowedProviderScopes` configuration field:

```yaml
apiVersion: "uitsmijter.io/v1"
kind: Client
metadata:
  name: my-app
spec:
  allowedProviderScopes:
    - user:*
    - can:*
    # admin:* is NOT in the allowed list
```

**Result**: Only scopes matching `user:*` and `can:*` patterns are allowed. The `admin:*` scopes are rejected.

### Final Scope Merging

After both filtering steps, the allowed scopes from both tiers are merged and deduplicated:

**Example Flow:**

1. **Client requests**: `openid`, `email`, `profile`, `admin:delete`
2. **After Tier 1 filtering** (by `scopes: [openid, email, profile]`): `openid`, `email`, `profile`
3. **Provider returns**: `user:list`, `user:add`, `admin:all`
4. **After Tier 2 filtering** (by `allowedProviderScopes: [user:*]`): `user:list`, `user:add`
5. **Final JWT scopes**: `openid`, `email`, `profile`, `user:list`, `user:add`

## Wildcard Pattern Matching

Both `scopes` and `allowedProviderScopes` support wildcard pattern matching using the `*` character:

### Pattern Matching Rules

| Pattern | Matches | Does Not Match |
|---------|---------|----------------|
| `user:*` | `user:read`, `user:write`, `user:list`, `user:delete` | `user`, `users:read`, `admin:read` |
| `admin:*` | `admin:read`, `admin:write`, `admin:delete` | `admin`, `user:admin` |
| `*:read` | Not supported (wildcard must be at the end) | - |
| `openid` | `openid` (exact match only) | `openid:profile` |

### Pattern Matching Examples

```yaml
spec:
  allowedProviderScopes:
    - user:*        # Matches user:read, user:write, user:list, etc.
    - org:read      # Exact match only
    - can:*         # Matches can:edit, can:delete, can:approve, etc.
    - openid        # Exact match only
```

**Provider returns:**
```javascript
["user:read", "user:write", "org:read", "org:write", "can:edit", "openid"]
```

**After filtering:**
```javascript
["user:read", "user:write", "org:read", "can:edit", "openid"]
// org:write is rejected (no match for org:*)
```

## Configuration

### Client Configuration

Clients define both types of scope filtering in their configuration:

```yaml
apiVersion: "uitsmijter.io/v1"
kind: Client
metadata:
  name: webapp-client
  namespace: production
spec:
  tenant: example-tenant
  client_id: 550e8400-e29b-41d4-a716-446655440000
  redirect_uris:
    - https://webapp.example.com/callback

  # Tier 1: Client-requested scopes
  scopes:
    - openid
    - email
    - profile

  # Tier 2: Provider-supplied scopes
  allowedProviderScopes:
    - user:*
    - org:read
    - can:*
```

### File-Based Configuration

For file-based deployments (Docker, local development):

```yaml
name: webapp-client
config:
  ident: 550e8400-e29b-41d4-a716-446655440000
  tenantname: example-tenant
  redirect_urls:
    - https://webapp.example.com/callback

  scopes:
    - openid
    - email
    - profile

  allowedProviderScopes:
    - user:*
    - org:read
    - can:*
```

## JavaScript Provider Implementation

### Basic Implementation

```javascript
class UserLoginProvider {
    isLoggedIn = false;
    profile = {};
    userScopes = [];

    constructor(credentials) {
        fetch(`http://auth.example.com/validate`, {
            method: "post",
            body: credentials
        }).then((result) => {
            if (result.code == 200) {
                this.isLoggedIn = true;
                this.profile = JSON.parse(result.body);

                // Assign scopes based on user role
                this.userScopes = this.getScopesForRole(this.profile.role);

                commit(result.code, {subject: this.profile.userId});
            } else {
                commit(result.code);
            }
        });
    }

    getScopesForRole(role) {
        switch(role) {
            case "admin":
                return ["user:*", "org:*", "admin:*"];
            case "manager":
                return ["user:read", "user:list", "org:read"];
            case "user":
            default:
                return ["user:read"];
        }
    }

    get canLogin() {
        return this.isLoggedIn;
    }

    get userProfile() {
        return this.profile;
    }

    get role() {
        return this.profile.role || "user";
    }

    get scopes() {
        return this.userScopes;
    }
}
```

### Advanced Implementation with Group Membership

```javascript
class UserLoginProvider {
    isLoggedIn = false;
    profile = {};
    userScopes = [];

    constructor(credentials) {
        fetch(`http://ldap.example.com/authenticate`, {
            method: "post",
            body: credentials
        }).then((result) => {
            if (result.code == 200) {
                this.isLoggedIn = true;
                this.profile = JSON.parse(result.body);

                // Fetch user groups from LDAP
                this.userScopes = this.getScopesFromGroups(this.profile.groups);

                commit(result.code, {subject: this.profile.dn});
            } else {
                commit(result.code);
            }
        });
    }

    getScopesFromGroups(groups) {
        let scopes = ["user:read"]; // Base scope for all users

        if (groups.includes("cn=admins,ou=groups,dc=example,dc=com")) {
            scopes.push("admin:*", "user:*", "org:*");
        }

        if (groups.includes("cn=editors,ou=groups,dc=example,dc=com")) {
            scopes.push("content:edit", "content:publish");
        }

        if (groups.includes("cn=finance,ou=groups,dc=example,dc=com")) {
            scopes.push("invoice:*", "payment:read");
        }

        return scopes;
    }

    get canLogin() {
        return this.isLoggedIn;
    }

    get userProfile() {
        return this.profile;
    }

    get role() {
        return this.profile.role || "user";
    }

    get scopes() {
        return this.userScopes;
    }
}
```

## JWT Token Scope Claim

After filtering and merging, the final scopes are included in the JWT token as a `scope` claim:

```json
{
  "iss": "https://auth.example.com",
  "sub": "user@example.com",
  "aud": "550e8400-e29b-41d4-a716-446655440000",
  "exp": 1736649600,
  "iat": 1736563200,
  "tenant": "example-tenant",
  "role": "user",
  "scope": [
    "openid",
    "email",
    "profile",
    "user:read",
    "user:list"
  ],
  "profile": {
    "email": "user@example.com",
    "name": "John Doe"
  }
}
```

Downstream services can inspect the `scope` claim to make authorization decisions:

```javascript
// Example: Check if user has permission
const token = decodeJWT(request.headers.authorization);

if (token.scope.includes("user:write")) {
    // Allow user modification
} else {
    // Deny access
}

// Example: Check with wildcard pattern
const hasUserPermission = token.scope.some(s => s.startsWith("user:"));
```

## Security Considerations

### Secure by Default

Uitsmijter follows a **secure by default** approach:

- If `scopes` is not configured or is empty, **no client-requested scopes** are allowed
- If `allowedProviderScopes` is not configured or is empty, **no provider-supplied scopes** are allowed
- Both filters must explicitly allow scopes for them to appear in the JWT token

### Defense in Depth

The two-tier filtering system provides defense in depth:

1. **Compromised client application**: Cannot request excessive scopes (filtered by `scopes`)
2. **Compromised JavaScript provider**: Cannot grant excessive scopes (filtered by `allowedProviderScopes`)
3. **Both must be compromised** for unauthorized scopes to be granted

### Principle of Least Privilege

Configure scopes following the principle of least privilege:

**Good example:**
```yaml
scopes:
  - openid
  - email
  - profile
allowedProviderScopes:
  - user:read
  - user:list
```

**Bad example (too permissive):**
```yaml
scopes:
  - "*"  # Don't do this!
allowedProviderScopes:
  - "*"  # Don't do this!
```

### Wildcard Scope Risks

While wildcards are convenient, use them carefully:

- `user:*` allows ALL user-related scopes (including `user:delete`)
- Consider enumerating specific scopes for sensitive operations
- Use wildcards for read-only scopes, enumerate for write/delete scopes

**Example:**
```yaml
allowedProviderScopes:
  - user:read
  - user:list
  # Explicitly allow dangerous operations
  - user:delete
  # Don't use user:* if you want to restrict delete
```

## Use Cases

### Role-Based Access Control (RBAC)

Different user roles receive different scopes:

```javascript
getScopesForRole(role) {
    switch(role) {
        case "admin":
            return ["user:*", "org:*", "admin:*", "audit:read"];
        case "manager":
            return ["user:read", "user:list", "org:read", "team:*"];
        case "developer":
            return ["user:read", "repo:*", "deploy:staging"];
        case "user":
        default:
            return ["user:read", "profile:write"];
    }
}
```

### Multi-Tenant Organizations

Assign organization-specific scopes:

```javascript
getScopesForOrganization(userId) {
    const orgs = this.getUserOrganizations(userId);
    let scopes = [];

    orgs.forEach(org => {
        scopes.push(`org:${org.id}:read`);

        if (org.role === "admin") {
            scopes.push(`org:${org.id}:*`);
        }
    });

    return scopes;
}
```

### Time-Based Access

Grant temporary scopes based on subscription:

```javascript
getScopesForUser(user) {
    let scopes = ["user:read"];

    if (user.subscription === "premium" && user.subscriptionExpires > Date.now()) {
        scopes.push("premium:*", "analytics:read", "export:*");
    } else if (user.trialExpires > Date.now()) {
        scopes.push("trial:*");
    }

    return scopes;
}
```

## Troubleshooting

### Scopes Not Appearing in JWT

**Issue**: Expected scopes are missing from the JWT token.

**Checklist:**

1. Check client `scopes` configuration allows the requested scopes
2. Check client `allowedProviderScopes` configuration allows provider-returned scopes
3. Verify JavaScript provider's `get scopes()` method returns the expected scopes
4. Check Uitsmijter logs for scope filtering messages

**Debug:**
```shell
kubectl logs -n uitsmijter -l app=uitsmijter | grep -i scope
```

### Provider Scopes Not Being Added

**Issue**: JavaScript provider returns scopes, but they don't appear in the JWT.

**Solution:**

Ensure `allowedProviderScopes` is configured:

```yaml
spec:
  allowedProviderScopes:
    - user:*
    # Empty or missing = no provider scopes allowed
```

### Wildcard Pattern Not Matching

**Issue**: Wildcard pattern `user:*` doesn't match `user:read`.

**Common Mistakes:**

- Wildcard must be at the **end** of the pattern: `user:*` ✓, `*:read` ✗
- Pattern is case-sensitive: `user:*` doesn't match `User:read`
- No match for partial patterns: `user:*` doesn't match `user` (missing `:`)

## Migration Guide

### Upgrading from Pre-0.10.3 Versions

Version 0.10.3 introduced `allowedProviderScopes`. Existing clients continue to work without changes:

**Before (0.10.2):**
```yaml
spec:
  scopes:
    - openid
    - email
```

**After (0.10.3+):**
```yaml
spec:
  scopes:
    - openid
    - email
  # allowedProviderScopes not set = no provider scopes (backward compatible)
```

### Adding Provider Scopes to Existing Deployments

1. **Update CRD** (if using Kubernetes):
   ```shell
   kubectl apply -f crd-clients.yaml
   ```

2. **Update client configuration**:
   ```yaml
   spec:
     allowedProviderScopes:
       - user:*
       - org:read
   ```

3. **Update JavaScript provider** (optional):
   ```javascript
   get scopes() {
       return ["user:read", "user:list"];
   }
   ```

4. **Test scope filtering**:
   - Request an OAuth token
   - Decode the JWT
   - Verify `scope` claim contains expected scopes

## Best Practices

1. **Use hierarchical scope naming**: `resource:action` format (e.g., `user:read`, `org:delete`)
2. **Follow principle of least privilege**: Grant minimum necessary scopes
3. **Use wildcards for read operations**: `user:*` for broad read access
4. **Enumerate sensitive operations**: Explicitly list `delete`, `admin`, etc.
5. **Document scope meanings**: Maintain documentation of what each scope grants
6. **Test scope filtering**: Verify scopes are correctly filtered in development
7. **Monitor scope grants**: Review audit logs for unexpected scope assignments
8. **Rotate scopes periodically**: Consider time-limited scopes for sensitive operations

## Further Reading

- [Client Configuration](/configuration/tenant_client_config) - Detailed client configuration reference
- [Managing Clients](/working-with-uitsmijter/clients) - Working with client resources via kubectl
- [JavaScript Providers](/providers/userloginprovider) - Implementing authentication providers
- [JWT Token Decoding](/oauth/jwt_decoding) - Understanding and validating JWT tokens
- [OAuth Flow](/oauth/flow) - Understanding OAuth2 authorization flows
- [Grant Types](/oauth/granttypes) - Supported OAuth2 grant types
