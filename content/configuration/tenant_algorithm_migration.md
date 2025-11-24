---
title: 'Migrating to Per-Tenant JWT Algorithms'
weight: 7
---

# Migrating to Per-Tenant JWT Algorithms

This guide helps you migrate from global JWT algorithm configuration to per-tenant configuration.

## Overview

Uitsmijter supports per-tenant JWT algorithm selection, allowing different tenants to use HS256 or RS256 independently. This enables:

- **Zero-downtime migration**: Migrate tenants from HS256 to RS256 one at a time
- **Mixed deployments**: Run HS256 and RS256 tenants in the same instance
- **Gradual rollout**: Test RS256 with pilot tenants before full deployment

## Before You Start

**Compatibility**: Per-tenant algorithm selection is available in Uitsmijter CE 0.10.1 and later.

**Current behavior** (0.10.1+):
- Each tenant specifies `jwt_algorithm` in its configuration
- Tenants without `jwt_algorithm` default to HS256
- No global `JWT_ALGORITHM` environment variable

**Previous behavior** (0.10.0 and earlier):
- All tenants used the same algorithm (from `JWT_ALGORITHM` environment variable)
- Default: HS256

## Backward Compatibility

Existing tenant configurations **continue to work without changes**:

**Version 0.10.0 and earlier:**
```yaml
# Environment variable controlled global algorithm
JWT_ALGORITHM: HS256

# Tenant (no algorithm specified, used global setting)
apiVersion: "uitsmijter.io/v1"
kind: Tenant
metadata:
  name: my-tenant
spec:
  hosts:
    - example.com
```

**Version 0.10.1+ (current):**
```yaml
# No JWT_ALGORITHM environment variable needed

# Tenant (no algorithm specified → defaults to HS256)
apiVersion: "uitsmijter.io/v1"
kind: Tenant
metadata:
  name: my-tenant
spec:
  hosts:
    - example.com
  # jwt_algorithm: HS256  # Optional, defaults to HS256
```

**Migration from 0.10.0 to 0.10.1+:**
- Remove `JWT_ALGORITHM` environment variable from deployment
- Tenants without `jwt_algorithm` will default to HS256 (same as before)
- **No tenant configuration changes required** if staying with default HS256

## Migration Scenarios

### Scenario 1: Migrate all tenants to RS256

**Goal**: Move all tenants from HS256 to RS256 at once (simple deployments)

**Steps**:

1. Update resource servers to support JWKS (see [JWT Algorithms - Migration](/configuration/jwt_algorithms#migrating-from-hs256-to-rs256))
2. Add `jwt_algorithm: RS256` to all tenant configurations
3. Apply tenant configurations (Kubernetes) or restart Uitsmijter (file-based)
4. Wait for old HS256 tokens to expire (2× token lifetime)

**Note**: You need to update each tenant configuration individually to specify RS256.

### Scenario 2: Gradual per-tenant migration

**Goal**: Migrate tenants one at a time (recommended for multi-tenant production)

**Steps**:

1. **Update resource servers** to support both HS256 and RS256:

```javascript
import jwt from 'jsonwebtoken';
import jwksClient from 'jwks-rsa';

const client = jwksClient({
  jwksUri: 'https://id.example.com/.well-known/jwks.json',
  cache: true
});

function getKey(header, callback) {
  if (header.alg === 'HS256') {
    callback(null, process.env.JWT_SECRET);
  } else {
    client.getSigningKey(header.kid, (err, key) => {
      const signingKey = key.getPublicKey();
      callback(null, signingKey);
    });
  }
}

jwt.verify(token, getKey, { algorithms: ['HS256', 'RS256'] }, (err, decoded) => {
  // Handles both HS256 and RS256 tokens
});
```

2. **Choose a pilot tenant** for initial RS256 rollout:
   ```yaml
   apiVersion: "uitsmijter.io/v1"
   kind: Tenant
   metadata:
     name: pilot-tenant
   spec:
     jwt_algorithm: RS256  # ← Tenant-specific override
     hosts:
       - pilot.example.com
   ```

3. **Apply the tenant update**:
   ```bash
   kubectl apply -f pilot-tenant.yaml
   # or for file-based:
   # Restart Uitsmijter to reload tenant config
   ```

4. **Monitor pilot tenant**:
   - Verify new tokens have `alg: RS256` in header
   - Check resource servers correctly verify tokens
   - Monitor for 2× token lifetime (4 hours default)

5. **Migrate remaining tenants** (one at a time or in batches):
   ```yaml
   spec:
     jwt_algorithm: RS256  # ← Add to each tenant
   ```

6. **Verify all tenants** are using RS256:
   ```bash
   # Check tenant configurations
   kubectl get tenants -o yaml | grep -A 5 jwt_algorithm
   ```

### Scenario 3: Mixed algorithm deployment

**Goal**: Keep some tenants on HS256, migrate others to RS256 (permanent mixed state)

**Use cases**:
- Legacy tenants require HS256 for compatibility
- Internal tools use HS256, customer-facing apps use RS256
- Different security tiers

**Configuration**:

```yaml
# Tenant A: Internal tools (uses default HS256)
apiVersion: "uitsmijter.io/v1"
kind: Tenant
metadata:
  name: internal-tools
spec:
  hosts:
    - internal.example.com
  # No jwt_algorithm → defaults to HS256

---
# Tenant B: Customer portal (uses RS256)
apiVersion: "uitsmijter.io/v1"
kind: Tenant
metadata:
  name: customer-portal
spec:
  jwt_algorithm: RS256  # Explicit RS256
  hosts:
    - portal.example.com

---
# Tenant C: Legacy app (explicitly uses HS256)
apiVersion: "uitsmijter.io/v1"
kind: Tenant
metadata:
  name: legacy-app
spec:
  jwt_algorithm: HS256  # Explicit HS256 (clearer than relying on default)
  hosts:
    - legacy.example.com
```

## Validation and Testing

### Verify tenant algorithm

**Kubernetes**:
```bash
kubectl get tenant my-tenant -o yaml | grep jwt_algorithm
```

**Expected output** (tenant-specific):
```yaml
jwt_algorithm: RS256
```

**Expected output** (inheriting global):
```yaml
# (no jwt_algorithm field)
```

### Check token algorithm

1. Obtain a token for the tenant
2. Decode the JWT header:
   ```bash
   echo "TOKEN_HERE" | cut -d'.' -f1 | base64 -d | jq
   ```
3. Check `alg` field:
   ```json
   {
     "alg": "RS256",
     "typ": "JWT",
     "kid": "2024-11-10"
   }
   ```

### Verify JWKS endpoint

```bash
curl https://id.example.com/.well-known/jwks.json | jq
```

**Expected output** (if any tenant uses RS256):
```json
{
  "keys": [
    {
      "kty": "RSA",
      "use": "sig",
      "kid": "2024-11-10",
      "n": "...",
      "e": "AQAB"
    }
  ]
}
```

**Expected output** (all tenants use HS256):
```json
{
  "keys": []
}
```

## Rollback

If issues occur, you can rollback individual tenants:

**Rollback single tenant to HS256**:
```yaml
spec:
  jwt_algorithm: HS256  # Revert to HS256
```

**Rollback all tenants**:
Remove `jwt_algorithm` from all tenants (will default to HS256).

**Important**: After rollback, RS256 tokens issued before rollback will fail verification.

## Troubleshooting

### Tenant tokens fail verification

**Symptoms**: 401 Unauthorized errors for specific tenant

**Diagnosis**:
1. Check tenant algorithm: `kubectl get tenant TENANT_NAME -o yaml | grep jwt_algorithm`
2. Check token header: Decode JWT, verify `alg` matches tenant configuration
3. Check resource server: Ensure it supports the algorithm (HS256 or RS256)

**Solution**: Ensure resource server configuration matches tenant algorithm.

---

### JWKS endpoint empty despite RS256 tenant

**Symptoms**: `{"keys": []}` even though tenant uses RS256

**Diagnosis**:
```bash
kubectl get tenants -o yaml | grep jwt_algorithm
```

**Solution**: Verify at least one tenant has `jwt_algorithm: RS256`. Restart Uitsmijter to regenerate keys.

---

### Mixed verification fails

**Symptoms**: Some tenants work, others fail with "invalid signature"

**Diagnosis**: Check resource server configuration

**Solution**: Ensure resource server supports both HS256 and RS256 (see example above).

## Best Practices

1. **Test in staging first**: Always test per-tenant algorithms in staging before production
2. **Monitor during migration**: Watch for verification errors during rollout
3. **Migrate gradually**: Start with 1-2 pilot tenants, then expand
4. **Document tenant algorithms**: Keep a list of which tenants use which algorithm
5. **Plan token expiration**: Wait 2× token lifetime after changes before cleanup
6. **Update resource servers first**: Always update resource servers before changing tenant algorithms

## Further Reading

- [JWT Algorithms](/configuration/jwt_algorithms) - Detailed algorithm comparison
- [Tenant Configuration](/configuration/tenant_client_config) - Full tenant configuration reference
- [JWKS Endpoint](/oauth/endpoints#well-knownjwksjson) - JWKS endpoint documentation
