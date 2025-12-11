---
title: 'Managing Clients'
weight: 2
---

# Managing Clients

Clients represent OAuth2 applications that authenticate users through Uitsmijter. Each client belongs to a tenant and has its own configuration, redirect URIs, and access credentials. 
This guide shows you how to work with clients using `kubectl` commands.

## Understanding Clients

A client is an OAuth2 application that can:
- **Authenticate users** via the tenant's authentication providers
- **Request authorization codes** and exchange them for access tokens
- **Access protected resources** on behalf of authenticated users
- **Track metrics** including active sessions and denied login attempts

Each client has:
- **Unique identifier**: UUID-based client_id
- **Optional secret**: For confidential clients (server-side applications)
- **Redirect URIs**: Allowed callback URLs after authentication
- **Grant types**: Supported OAuth2 flows (authorization_code, refresh_token, password)
- **Scopes**: Permissions the client can request

For conceptual information, see [Entities](/configuration/entities). For configuration details, see [Tenant and client configuration](/configuration/tenant_client_config).

## Listing Clients

View all clients across all namespaces:

```shell
kubectl get clients -A
```

**Example output:**

```text
NAMESPACE   NAME            CLIENT-ID                              SESSIONS   DENIED   AGE
cheese      cheese-web      9095A4F2-35B2-48B1-A325-309CA324B97E   8          2        5d
cheese      cheese-mobile   A1B2C3D4-E5F6-7890-ABCD-EF1234567890   4          0        5d
cheese      cheese-api      B2C3D4E5-F6A7-8901-BCDE-F12345678901   0          0        5d
ham         ham-app         C3D4E5F6-A7B8-9012-CDEF-123456789012   8          1        5d
uitsmijter  admin-client    D4E5F6A7-B8C9-0123-DEF1-234567890123   0          0        5d
```

The output shows:
- **NAMESPACE**: Kubernetes namespace (matches the tenant's namespace)
- **NAME**: Client identifier
- **CLIENT-ID**: UUID used in OAuth2 flows
- **SESSIONS**: Number of active user sessions for this client
- **DENIED**: Number of failed login attempts
- **AGE**: Time since client was created

List clients in a specific namespace:

```shell
kubectl get clients -n cheese
```

## Viewing Client Details

Get detailed information about a specific client:

```shell
kubectl describe client cheese-web -n cheese
```

**Example output:**

```yaml
Name:         cheese-web
Namespace:    cheese
Labels:       <none>
Annotations:  <none>
API Version:  uitsmijter.io/v1
Kind:         Client
Metadata:
  Creation Timestamp:  2025-11-22T10:35:12Z
  Generation:          1
  Resource Version:    12456
  UID:                 b1c2d3e4-f5a6-7890-2345-678901bcdefg
Spec:
  Client ID:  9095A4F2-35B2-48B1-A325-309CA324B97E
  Grant Types:
    authorization_code
    refresh_token
  Redirect URIs:
    https://app.example.com/callback
    https://app.example.com/oauth/callback
  Scopes:
    read
    write
    profile
  Allowed Provider Scopes:
    user:*
    can:*
  Secret:  <set>
  Tenant:  cheese
Status:
  Active Sessions:  8
  Denied Attempts:  2
  Last Activity:    2025-11-27T08:45:22Z
  Last Denied:      2025-11-26T15:30:10Z
  Phase:            Active
Events:            <none>
```

The `kubectl describe` output provides:
- **Spec**: Complete client configuration
  - **Client ID**: UUID for OAuth2 authorization
  - **Grant Types**: Supported OAuth2 flows
  - **Redirect URIs**: Allowed callback URLs
  - **Scopes**: Available permissions
  - **Secret**: Whether a client secret is configured (value is not shown for security)
  - **Tenant**: Associated tenant name
- **Status**: Real-time metrics
  - **Active Sessions**: Current logged-in users
  - **Denied Attempts**: Failed login count
  - **Last Activity**: Timestamp of most recent successful authentication
  - **Last Denied**: Timestamp of most recent failed authentication
  - **Phase**: Operational status

## Creating a Client

Create a new client using a YAML manifest:

```yaml
# client-example.yaml
apiVersion: "uitsmijter.io/v1"
kind: Client
metadata:
  name: webapp-client
  namespace: production
spec:
  tenant: example-tenant
  client_id: F1E2D3C4-B5A6-7890-CDEF-123456789ABC
  secret: "your-secure-client-secret-here"
  redirect_uris:
    - https://webapp.example.com/oauth/callback
    - https://webapp.example.com/auth/callback
  grant_types:
    - authorization_code
    - refresh_token
  scopes:
    - read
    - write
    - profile
    - email
  allowedProviderScopes:
    - user:*
    - org:read
    - can:*
```

Apply the client configuration:

```shell
kubectl apply -f client-example.yaml
```

Verify the client was created:

```shell
kubectl get client webapp-client -n production
```

### Client Configuration Best Practices

**Client ID Generation:**
Generate a secure UUID for the client_id:

```shell
uuidgen | tr '[:lower:]' '[:upper:]'
```

**Client Secret (Confidential Clients):**
For server-side applications, generate a strong secret:

```shell
openssl rand -base64 32
```

**Public Clients:**
For browser-based or mobile apps, omit the `secret` field and use PKCE:

```yaml
spec:
  tenant: example-tenant
  client_id: G2F3E4D5-C6B7-8901-DEFG-234567890BCD
  # No secret for public clients
  redirect_uris:
    - https://spa.example.com/callback
  grant_types:
    - authorization_code
    - refresh_token
  scopes:
    - read
    - profile
  allowedProviderScopes:
    - user:read
    - user:list
  isPkceOnly: true
```

### Provider Scope Filtering

Clients can control which scopes JavaScript authentication providers can add to user profiles using the `allowedProviderScopes` field. This provides a second layer of security beyond client-requested scopes:

**Two-Tier Scope Control:**
- `scopes`: Controls what the OAuth client can request during authorization
- `allowedProviderScopes`: Controls what the JavaScript provider can dynamically add based on user context

**Wildcard Pattern Matching:**

The `allowedProviderScopes` field supports wildcard patterns for flexible configuration:

```yaml
spec:
  allowedProviderScopes:
    - user:*        # Matches user:read, user:write, user:list, etc.
    - org:read      # Exact match only
    - can:*         # Matches can:edit, can:delete, etc.
```

**Example Flow:**
1. Client requests scopes: `read`, `write`, `admin:delete`
2. Only `read` and `write` pass (filtered by `scopes: [read, write, profile]`)
3. JavaScript provider returns scopes: `user:list`, `user:add`, `admin:all`
4. Only `user:list` and `user:add` pass (filtered by `allowedProviderScopes: [user:*]`)
5. Final JWT token contains: `read`, `write`, `user:list`, `user:add`

**Secure by Default:**

If `allowedProviderScopes` is not configured or is empty, no provider-supplied scopes will be added to the JWT token. This ensures security by requiring explicit configuration.

For more information, see [JavaScript Providers](/providers/userloginprovider) and [Tenant and Client Configuration](/configuration/tenant_client_config).

## Updating a Client

Edit a client configuration:

```shell
kubectl edit client cheese-web -n cheese
```

Update redirect URIs or scopes and save to apply changes.

Alternatively, update the YAML file and reapply:

```shell
kubectl apply -f client-example.yaml
```

## Monitoring Client Status

Watch client status in real-time:

```shell
kubectl get clients -n cheese --watch
```

Check active session count for a specific client:

```shell
kubectl get client cheese-web -n cheese -o jsonpath='{.status.activeSessions}'
```

View denied login attempts:

```shell
kubectl get client cheese-web -n cheese -o jsonpath='{.status.deniedAttempts}'
```

Check last authentication activity:

```shell
kubectl get client cheese-web -n cheese -o jsonpath='{.status.lastActivity}'
```

## Client Metrics and Monitoring

View all clients sorted by active sessions:

```shell
kubectl get clients -A -o json | \
  jq '.items | sort_by(.status.activeSessions) | reverse |
      .[] | {name: .metadata.name, namespace: .metadata.namespace,
             sessions: .status.activeSessions}'
```

Find clients with failed login attempts:

```shell
kubectl get clients -A -o json | \
  jq '.items[] | select(.status.deniedAttempts > 0) |
      {name: .metadata.name, denied: .status.deniedAttempts}'
```

## Resetting Denied Attempts Counter

The denied attempts counter is tracked in memory and persists across pod restarts via Redis. To reset the counter, you can delete and recreate the client status (this does not affect active sessions):

```shell
# The counter will reset when new login attempts occur
kubectl annotate client cheese-web -n cheese \
  uitsmijter.io/reset-metrics="$(date +%s)" --overwrite
```

## Deleting a Client

Delete a client:

```shell
kubectl delete client cheese-web -n cheese
```

> **Warning**: Deleting a client invalidates all active sessions and refresh tokens for that client. Users will need to re-authenticate.

Verify deletion:

```shell
kubectl get client cheese-web -n cheese
```

Expected output:
```text
Error from server (NotFound): clients.uitsmijter.io "cheese-web" not found
```

## Client Status Phases

Clients can be in different phases:

| Phase      | Description                                                                   |
|------------|-------------------------------------------------------------------------------|
| `Active`   | Client is operational and can authenticate users                              |
| `Pending`  | Client is being initialized or tenant association is being established        |
| `Failed`   | Configuration error (invalid tenant, malformed redirect URIs, etc.)           |

Check client phase:

```shell
kubectl get client cheese-web -n cheese -o jsonpath='{.status.phase}'
```

## Troubleshooting

### Client shows "Pending" phase

Check if the associated tenant exists:

```shell
kubectl get tenant cheese -n cheese
```

Verify the tenant name matches the client's spec:

```shell
kubectl get client cheese-web -n cheese -o jsonpath='{.spec.tenant}'
```

### Client shows "Failed" phase

Check for configuration errors:

```shell
kubectl describe client cheese-web -n cheese
```

Common issues:
- **Invalid tenant reference**: Tenant does not exist in the same namespace
- **Malformed redirect URIs**: URIs must be absolute URLs with https:// scheme (http:// allowed for localhost)
- **Missing client_id**: Must be a valid UUID
- **Duplicate client_id**: Another client already uses this UUID

### Sessions not updating

Check if Uitsmijter pods are running:

```shell
kubectl get pods -n uitsmijter -l app=uitsmijter
```

Verify Redis session storage is healthy:

```shell
kubectl get pods -n uitsmijter -l app=uitsmijter-sessions
kubectl logs -n uitsmijter -l app=uitsmijter-sessions --tail=50
```

Check Uitsmijter logs for session-related errors:

```shell
kubectl logs -n uitsmijter -l app=uitsmijter --tail=100 | grep -i session
```

### High denied attempts count

This may indicate:
- **Brute force attack**: Monitor for patterns in authentication failures
- **Misconfigured application**: Application sending wrong credentials
- **User lockout issue**: Users repeatedly entering wrong passwords

Check Uitsmijter logs for denied login details:

```shell
kubectl logs -n uitsmijter -l app=uitsmijter --tail=200 | grep -i "login.*fail"
```

Review Prometheus metrics for detailed failure analysis:

```shell
kubectl port-forward -n uitsmijter svc/uitsmijter 8080:8080
curl http://localhost:8080/metrics | grep uitsmijter_login_failure
```

## OAuth2 Grant Types

Uitsmijter supports multiple OAuth2 grant types:

| Grant Type           | Use Case                                | Requires Secret | Supports Refresh |
|----------------------|-----------------------------------------|-----------------|------------------|
| `authorization_code` | Server-side web apps, SPAs with PKCE    | Optional        | Yes              |
| `refresh_token`      | Renew access tokens without re-login    | Same as client  | N/A              |
| `password`           | Legacy apps only (not recommended)      | Yes             | No               |

Configure grant types in the client spec:

```yaml
spec:
  grant_types:
    - authorization_code
    - refresh_token
```

> **Security Recommendation**: Use `authorization_code` with PKCE for all modern applications. The `password` grant type should only be enabled for legacy applications that cannot be updated.

## Advanced kubectl Operations

Get client as JSON:

```shell
kubectl get client cheese-web -n cheese -o json
```

Get client as YAML for backup:

```shell
kubectl get client cheese-web -n cheese -o yaml > client-backup.yaml
```

Extract client_id programmatically:

```shell
kubectl get client cheese-web -n cheese -o jsonpath='{.spec.client_id}'
```

List all clients for a specific tenant:

```shell
kubectl get clients -A -o json | \
  jq '.items[] | select(.spec.tenant=="cheese") |
      {name: .metadata.name, client_id: .spec.client_id}'
```

Find clients without active sessions:

```shell
kubectl get clients -A -o json | \
  jq '.items[] | select(.status.activeSessions == 0) | .metadata.name'
```

Compare client configurations:

```shell
diff <(kubectl get client cheese-web -n cheese -o yaml) \
     <(kubectl get client cheese-mobile -n cheese -o yaml)
```

## Security Considerations

### Storing Client Secrets

Client secrets are stored in Kubernetes as plaintext in the client CRD.

### Redirect URI Validation

Uitsmijter strictly validates redirect URIs to prevent authorization code interception:

- URIs must match one of the configured `redirect_uris`

### PKCE (Proof Key for Code Exchange)

For public clients (no secret), always use PKCE:

```text
/authorize?response_type=code
  &client_id=9095A4F2-35B2-48B1-A325-309CA324B97E
  &redirect_uri=https://app.example.com/callback
  &code_challenge=3VpzZL3DpqEwubIbIVsrOUbvB19kk4yGP7gGaxU/cyQ=
  &code_challenge_method=S256
```

See [PKCE Documentation](/oauth/pkce) for details.

## Further Reading

- [Entities](/configuration/entities) - Conceptual overview of clients
- [Tenant and client configuration](/configuration/tenant_client_config) - Detailed configuration reference
- [Managing Tenants](/working-with-uitsmijter/tenants) - Working with tenant resources
- [OAuth Flow](/oauth/flow) - Understanding OAuth2 authorization flows
- [Grant Types](/oauth/granttypes) - Supported OAuth2 grant types
- [PKCE](/oauth/pkce) - Authorization Code Flow with Proof Key for Code Exchange
- [Available Endpoints](/oauth/endpoints) - OAuth2 API endpoints
