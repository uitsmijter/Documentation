---
title: 'Managing Tenants'
weight: 1
---

# Managing Tenants

Tenants are the highest-level entity in Uitsmijter, representing isolated organizations or domains with their own authentication configuration. This guide shows you how to work with tenants in a Kubernetes environment using `kubectl` commands.

## Understanding Tenants

A tenant represents an isolated authentication domain with:
- **Unique hosts**: Domain names that this tenant serves
- **JavaScript providers**: Custom authentication logic
- **Clients**: OAuth2 applications that can authenticate users
- **Configuration**: JWT algorithm, interceptor settings, and information URLs

For conceptual information about tenants, see [Entities](/configuration/entities). For detailed configuration options, see [Tenant and client configuration](/configuration/tenant_client_config).

## Listing Tenants

View all tenants across all namespaces:

```shell
kubectl get tenants -A
```

**Example output:**

```text
NAMESPACE   NAME              PHASE    CLIENTS   SESSIONS   AGE
cheese      cheese            Active   3         12         5d
cheese      cheese-rs256      Active   1         0          5d
ham         ham               Active   1         8          5d
uitsmijter  uitsmijter-tenant Active   1         0          5d
```

The output shows:
- **NAMESPACE**: Kubernetes namespace containing the tenant
- **NAME**: Tenant identifier
- **PHASE**: Current operational status (Active, Pending, Failed)
- **CLIENTS**: Number of configured OAuth2 clients
- **SESSIONS**: Active user sessions across all clients
- **AGE**: Time since tenant was created

List tenants in a specific namespace:

```shell
kubectl get tenants -n cheese
```

## Viewing Tenant Details

Get detailed information about a specific tenant:

```shell
kubectl describe tenant cheese -n cheese
```

**Example output:**

```yaml
Name:         cheese
Namespace:    cheese
Labels:       <none>
Annotations:  <none>
API Version:  uitsmijter.io/v1
Kind:         Tenant
Metadata:
  Creation Timestamp:  2025-11-22T10:30:45Z
  Generation:          1
  Resource Version:    12345
  UID:                 a1b2c3d4-e5f6-7890-1234-567890abcdef
Spec:
  Hosts:
    id.example.com
    api.example.com
    cookbooks.example.com
  Informations:
    Imprint URL:   https://example.com/imprint
    Privacy URL:   https://example.com/privacy
    Register URL:  https://example.com/register
  Interceptor:
    Cookie:   .example.com
    Domain:   login.example.com
    Enabled:  true
  JWT Algorithm:  HS256
  Providers:
    class UserLoginProvider {
      auth = false;
      constructor(credentials) {
        this.auth = credentials.username.endsWith("@example.com");
        commit(true);
      }
      get canLogin() { return this.auth; }
      get userProfile() { return { name: "Test User" }; }
      get role() { return "user"; }
    }
Status:
  Clients:
    Active Count:  3
    Client Names:
      cheese-web
      cheese-mobile
      cheese-api
  Phase:  Active
  Sessions:
    Active:  12
    Denied:  3
  Last Updated:  2025-11-27T08:15:30Z
Events:         <none>
```

The `kubectl describe` output provides:
- **Spec**: Complete tenant configuration including hosts, providers, and settings
- **Status**: Real-time operational metrics
  - **Phase**: Current status (Active when all clients are configured correctly)
  - **Clients**: List of associated OAuth2 clients and count
  - **Sessions**: Active user sessions and denied login attempts
  - **Last Updated**: Timestamp of most recent status update

## Creating a Tenant

Create a new tenant using a YAML manifest:

```yaml
# tenant-example.yaml
apiVersion: "uitsmijter.io/v1"
kind: Tenant
metadata:
  name: example-tenant
  namespace: production
spec:
  hosts:
    - auth.example.com
    - api.example.com
  informations:
    imprint_url: https://example.com/imprint
    privacy_url: https://example.com/privacy
    register_url: https://example.com/register
  interceptor:
    enabled: true
    domain: login.example.com
    cookie: .example.com
  jwt_algorithm: RS256
  providers:
    # User authentication provider
    - |
      class UserLoginProvider {
        auth = false;
        constructor(credentials) {
          // Connect to your user backend here
          this.auth = credentials.username.endsWith("@example.com");
          commit(true);
        }
        get canLogin() { return this.auth; }
        get userProfile() {
          return {
            name: "John Doe",
            email: credentials.username
          };
        }
        get role() { return "user"; }
      }
```

Apply the tenant configuration:

```shell
kubectl apply -f tenant-example.yaml
```

Verify the tenant was created:

```shell
kubectl get tenant example-tenant -n production
```

## Updating a Tenant

Edit a tenant configuration:

```shell
kubectl edit tenant cheese -n cheese
```

This opens the tenant manifest in your default editor. Make changes and save to apply them. Uitsmijter automatically reloads the configuration.

Alternatively, update the YAML file and reapply:

```shell
kubectl apply -f tenant-example.yaml
```

## Monitoring Tenant Status

Watch tenant status in real-time:

```shell
kubectl get tenants -n cheese --watch
```

Check if a tenant is active and healthy:

```shell
kubectl get tenant cheese -n cheese -o jsonpath='{.status.phase}'
```

View active session count:

```shell
kubectl get tenant cheese -n cheese -o jsonpath='{.status.sessions.active}'
```

View denied login attempts:

```shell
kubectl get tenant cheese -n cheese -o jsonpath='{.status.sessions.denied}'
```

## Deleting a Tenant

Delete a tenant and all associated data:

```shell
kubectl delete tenant cheese -n cheese
```

> **Warning**: Deleting a tenant also removes all associated clients and active user sessions. Users will need to re-authenticate.

Verify deletion:

```shell
kubectl get tenant cheese -n cheese
```

Expected output:
```text
Error from server (NotFound): tenants.uitsmijter.io "cheese" not found
```

## Tenant Status Phases

Tenants can be in different phases:

| Phase      | Description                                                                 |
|------------|-----------------------------------------------------------------------------|
| `Active`   | Tenant is fully operational with at least one configured client             |
| `Pending`  | Tenant is being initialized or waiting for client configuration             |
| `Failed`   | Configuration error or provider validation failed (check logs for details)  |

Check tenant phase:

```shell
kubectl get tenant cheese -n cheese -o jsonpath='{.status.phase}'
```

## Troubleshooting

### Tenant shows "Pending" phase

The tenant may be waiting for client configuration. Check if clients exist:

```shell
kubectl get clients -n cheese
```

Check Uitsmijter logs for errors:

```shell
kubectl logs -n uitsmijter -l app=uitsmijter --tail=100
```

### Tenant shows "Failed" phase

Check the tenant events for error messages:

```shell
kubectl describe tenant cheese -n cheese
```

Common issues:
- **Invalid JavaScript provider**: Syntax error in provider code
- **Missing hosts**: At least one host must be configured
- **Duplicate hosts**: A host cannot be assigned to multiple tenants

### Session count not updating

Ensure Uitsmijter pods are running:

```shell
kubectl get pods -n uitsmijter -l app=uitsmijter
```

Check Redis session storage is healthy:

```shell
kubectl get pods -n uitsmijter -l app=uitsmijter-sessions
```

## Advanced kubectl Operations

Get tenant as JSON:

```shell
kubectl get tenant cheese -n cheese -o json
```

Get tenant as YAML:

```shell
kubectl get tenant cheese -n cheese -o yaml > tenant-backup.yaml
```

List tenants with custom columns:

```shell
kubectl get tenants -A -o custom-columns=\
NAME:.metadata.name,\
NAMESPACE:.metadata.namespace,\
PHASE:.status.phase,\
CLIENTS:.status.clients.activeCount,\
SESSIONS:.status.sessions.active
```

Filter tenants by phase:

```shell
kubectl get tenants -A -o json | \
  jq '.items[] | select(.status.phase=="Active") | .metadata.name'
```

## Further Reading

- [Entities](/configuration/entities) - Conceptual overview of tenants
- [Tenant and client configuration](/configuration/tenant_client_config) - Detailed configuration reference
- [Managing Clients](/working-with-uitsmijter/clients) - Working with OAuth2 clients
- [JWT Algorithms](/configuration/jwt_algorithms) - Choosing between HS256 and RS256
- [Providers](/providers/providers) - Writing custom authentication providers
