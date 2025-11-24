---
title: 'JWT Signing Algorithms'
weight: 6
---

# JWT Signing Algorithms

Uitsmijter supports two JWT signing algorithms for access tokens: **HS256** (HMAC with SHA-256) and **RS256** (RSA with SHA-256). This guide explains the differences between these algorithms and how to migrate from HS256 to RS256.

## Algorithm Comparison

| Feature | HS256 (Symmetric) | RS256 (Asymmetric) |
|---------|-------------------|-------------------|
| **Key Type** | Shared secret (single key) | RSA key pair (public + private) |
| **Security** | Good (if secret is protected) | **Better** (private key never shared) |
| **Key Distribution** | Secret must be shared securely | Public key can be distributed openly |
| **Token Verification** | Requires shared secret | Uses public key (via JWKS) |
| **Key Rotation** | Requires secret update everywhere | **Seamless** (JWKS supports multiple keys) |
| **Performance** | Faster (symmetric crypto) | Slightly slower (asymmetric crypto) |
| **Use Case** | Simple deployments, testing | **Production, microservices** |
| **JWKS Endpoint** | Not used | **Required** (`/.well-known/jwks.json`) |
| **Default** | Yes (backward compatibility) | Recommended for new deployments |

## HS256 (HMAC with SHA-256)

HS256 is a symmetric algorithm that uses a shared secret key to both sign and verify JWTs.

### How it works

1. Uitsmijter signs JWTs using a secret key (from `JWT_SECRET` environment variable)
2. Resource servers verify JWTs using the **same secret key**
3. The secret must be securely shared between Uitsmijter and all resource servers

### Configuration

HS256 is the default algorithm. Configure it in your tenant YAML:

```yaml
# Tenant configuration (optional, defaults to HS256 if omitted)
apiVersion: "uitsmijter.io/v1"
kind: Tenant
metadata:
  name: my-tenant
spec:
  hosts:
    - example.com
  jwt_algorithm: HS256  # Optional: defaults to HS256 if not specified

# Environment (HS256 requires JWT_SECRET)
JWT_SECRET: your-secret-key-at-least-256-bits
```

### When to use HS256

- **Development and testing**: Simple setup, no key management
- **Monolithic applications**: Single application verifies tokens
- **Legacy systems**: Already using HS256 and shared secrets
- **High-performance scenarios**: Marginally faster than RS256

### Security considerations

- **Secret management**: The `JWT_SECRET` must be kept confidential
- **Secret distribution**: Every service that verifies tokens needs the secret
- **Key rotation**: Rotating keys requires updating all services simultaneously
- **Compromise risk**: If one service is compromised, the secret is exposed

## RS256 (RSA with SHA-256)

RS256 is an asymmetric algorithm that uses an RSA key pair: a private key for signing and a public key for verification.

### How it works

1. Uitsmijter generates an RSA key pair (2048-bit)
2. Uitsmijter signs JWTs with the **private key** (kept secret)
3. Uitsmijter publishes the **public key** via the JWKS endpoint (`/.well-known/jwks.json`)
4. Resource servers fetch the public key from JWKS
5. Resource servers verify JWTs using the public key (no secrets needed)

### Configuration

Enable RS256 in your tenant configuration:

```yaml
# Tenant configuration
apiVersion: "uitsmijter.io/v1"
kind: Tenant
metadata:
  name: my-tenant
spec:
  hosts:
    - example.com
  jwt_algorithm: RS256  # Use RS256 for this tenant
```

That's it! Uitsmijter will automatically:
- Generate RSA key pairs on first use
- Publish public keys at `/.well-known/jwks.json`
- Include `kid` (Key ID) in JWT headers
- Support key rotation (every 90 days)

You do **not** need to manually generate or manage RSA keys.

### When to use RS256 (Recommended)

- **Production deployments**: Superior security and key management
- **Microservices architecture**: Each service can verify tokens independently
- **Multi-tenant systems**: Different tenants can have different keys
- **Compliance requirements**: Many standards require asymmetric signing
- **Key rotation**: Seamless rotation without service disruption

### Security advantages

- **Private key protection**: Private keys never leave Uitsmijter
- **Public key distribution**: Public keys can be shared openly (via JWKS)
- **No shared secrets**: Resource servers don't need confidential data
- **Key rotation**: Old keys remain in JWKS during grace period
- **Compromise mitigation**: Compromising a resource server doesn't expose signing keys

## Migrating from HS256 to RS256

### Zero-Downtime Migration Strategy

This migration strategy allows you to switch from HS256 to RS256 without invalidating existing tokens or causing downtime.

#### Step 1: Understand the impact

**What changes:**
- JWT signing algorithm changes from HS256 to RS256
- JWT header includes `kid` field for key identification
- Public keys become available at `/.well-known/jwks.json`
- Resource servers must fetch public keys from JWKS (instead of using shared secret)

**What stays the same:**
- JWT payload structure (claims remain unchanged)
- Token expiration times
- OAuth endpoints and flows
- Client applications (if using standard OAuth libraries)

#### Step 2: Update resource servers first

Before switching Uitsmijter to RS256, update all resource servers to support JWKS-based verification. Most JWT libraries support this with minimal changes.

**Example: Node.js with `jsonwebtoken` and `jwks-rsa`**

Before (HS256):
```javascript
import jwt from 'jsonwebtoken';

const secret = process.env.JWT_SECRET;

// Verify token
jwt.verify(token, secret, { algorithms: ['HS256'] }, (err, decoded) => {
  // ...
});
```

After (RS256 with JWKS):
```javascript
import jwt from 'jsonwebtoken';
import jwksClient from 'jwks-rsa';

const client = jwksClient({
  jwksUri: 'https://id.example.com/.well-known/jwks.json',
  cache: true,
  cacheMaxAge: 3600000 // 1 hour
});

function getKey(header, callback) {
  client.getSigningKey(header.kid, (err, key) => {
    const signingKey = key.getPublicKey();
    callback(null, signingKey);
  });
}

// Verify token (works with both HS256 and RS256)
jwt.verify(token, getKey, { algorithms: ['HS256', 'RS256'] }, (err, decoded) => {
  // ...
});
```

**Key points:**
- Keep `HS256` in the `algorithms` array temporarily (supports both algorithms)
- The JWKS client will automatically fetch and cache public keys
- Works with HS256 tokens (falls back to cached secret) and RS256 tokens (uses JWKS)

#### Step 3: Deploy updated resource servers

Deploy the updated resource servers that support JWKS. Verify that they can still validate existing HS256 tokens.

Test with a sample HS256 token:
```bash
curl -H "Authorization: Bearer YOUR_HS256_TOKEN" https://your-api.example.com/protected
```

The request should succeed, confirming backward compatibility.

#### Step 4: Update tenant configuration to RS256

Update your tenant configuration to use RS256:

**Kubernetes (CRD):**
```yaml
# tenant.yaml
apiVersion: "uitsmijter.io/v1"
kind: Tenant
metadata:
  name: my-tenant
spec:
  hosts:
    - example.com
  jwt_algorithm: RS256  # Add this line
```

**File-based configuration:**
```yaml
# tenants/my-tenant.yaml
name: my-tenant
config:
  hosts:
    - example.com
  jwt_algorithm: RS256  # Add this line
  providers:
    - my-provider.js
```

#### Step 5: Apply tenant configuration

Apply the updated tenant configuration:

```bash
# Kubernetes (CRD)
kubectl apply -f tenant.yaml

# File-based: Restart Uitsmijter to reload configuration
kubectl rollout restart deployment/uitsmijter
# or
docker-compose restart uitsmijter
```

Uitsmijter will:
1. Generate a new RSA key pair if none exists
2. Start signing new JWTs for this tenant with RS256
3. Publish the public key at `/.well-known/jwks.json`

#### Step 6: Verify RS256 tokens

Test that new tokens are signed with RS256:

1. Obtain a new access token:
```bash
# Use your OAuth flow to get a new token
curl -X POST https://id.example.com/token \
  -d grant_type=authorization_code \
  -d code=YOUR_CODE \
  -d client_id=YOUR_CLIENT_ID
```

2. Decode the JWT header (without verifying):
```bash
# Extract and decode the header
echo "YOUR_TOKEN" | cut -d'.' -f1 | base64 -d
```

Expected output:
```json
{
  "alg": "RS256",
  "typ": "JWT",
  "kid": "2024-11-08"
}
```

3. Verify the token works with your resource servers:
```bash
curl -H "Authorization: Bearer YOUR_RS256_TOKEN" https://your-api.example.com/protected
```

#### Step 7: Wait for HS256 tokens to expire

Old HS256 tokens remain valid until they expire (typically 2 hours by default). During this grace period:
- New tokens are signed with RS256
- Old HS256 tokens continue to work
- Resource servers support both algorithms

**Monitor token expiration:**
```bash
# Check when the last HS256 token will expire
# Default token lifetime is 2 hours
```

#### Step 8: Remove HS256 support (optional)

After all HS256 tokens have expired (wait at least `TOKEN_EXPIRATION_IN_HOURS` × 2), you can remove HS256 support from resource servers:

```javascript
// Remove 'HS256' from algorithms array
jwt.verify(token, getKey, { algorithms: ['RS256'] }, (err, decoded) => {
  // Now only accepts RS256 tokens
});
```

You can also remove the `JWT_SECRET` environment variable from resource servers (no longer needed).

### Rollback Strategy

If you encounter issues during migration, you can rollback to HS256:

1. Update tenant configuration: change `jwt_algorithm` to `HS256` (or remove the field)
2. Apply the updated tenant configuration (Kubernetes) or restart Uitsmijter (file-based)
3. New tokens will be signed with HS256 again
4. RS256 tokens issued during the RS256 period will fail verification after rollback

**Important:** Plan the migration during a maintenance window or low-traffic period to minimize impact.

## Key Rotation (RS256 only)

With RS256, you can rotate signing keys without downtime:

### Manual key rotation

1. Generate a new key by restarting Uitsmijter
2. The new key gets a new `kid` (current date: `YYYY-MM-DD`)
3. New JWTs are signed with the new key
4. Old public keys remain in JWKS for verification
5. After grace period, old keys can be removed from JWKS

### Automatic key rotation

Uitsmijter doesn't currently implement automatic key rotation, but you can implement it using:

1. **Scheduled restarts**: Restart Uitsmijter monthly/quarterly (generates new key)
2. **External key management**: Use Kubernetes secrets rotation
3. **Manual rotation**: Generate new key via admin endpoint (future feature)

### Best practices for key rotation

- **Grace period**: Keep old keys in JWKS for at least 2× token lifetime
- **Monitoring**: Monitor JWT verification failures during rotation
- **Documentation**: Document which `kid` is active at any time
- **Testing**: Test rotation in staging before production

## Troubleshooting

### "Invalid signature" errors after switching to RS256

**Cause**: Resource servers are still trying to verify RS256 tokens with HS256 secret.

**Solution**: Ensure resource servers are updated to use JWKS (Step 2 of migration guide).

### JWKS endpoint returns empty `keys` array

**Cause**: No tenant is configured to use RS256.

**Solution**: Verify at least one tenant has `jwt_algorithm: RS256` in its configuration and restart Uitsmijter if using file-based configuration.

### "kid not found in JWKS" errors

**Cause**: Resource server's JWKS cache is stale, or key was rotated.

**Solution**:
- Clear JWKS cache (most libraries auto-refresh)
- Verify JWKS endpoint contains the `kid` from the JWT header
- Check that clocks are synchronized (NTP)

### Performance degradation after switching to RS256

**Cause**: RS256 is slightly slower than HS256 (asymmetric crypto overhead).

**Solution**:
- Enable JWKS caching in resource servers (default: 1 hour)
- Use CDN or caching proxy for JWKS endpoint
- Consider increasing token expiration time to reduce token issuance frequency

### Resource server can't reach JWKS endpoint

**Cause**: Network policy, firewall, or DNS issue.

**Solution**:
- Verify resource server can reach `https://id.example.com/.well-known/jwks.json`
- Check network policies allow outbound HTTPS
- Use internal DNS or service discovery if applicable

## Configuration Reference

### jwt_algorithm (Tenant Configuration)

Controls the JWT signing algorithm for a specific tenant.

**Location:** Tenant YAML configuration (`spec.jwt_algorithm`)

**Values:**
- `HS256` (default): HMAC with SHA-256 (symmetric)
- `RS256`: RSA with SHA-256 (asymmetric)

**Example:**
```yaml
apiVersion: "uitsmijter.io/v1"
kind: Tenant
metadata:
  name: my-tenant
spec:
  hosts:
    - example.com
  jwt_algorithm: RS256  # Tenant-specific algorithm
```

**Note:** If omitted, defaults to HS256 for backward compatibility.

### JWT_SECRET (Environment Variable)

(HS256 only) The shared secret used for HS256 signing.

**Requirements:**
- Minimum 256 bits (32 characters)
- Must be kept confidential
- Must match on all services verifying tokens

**Example:**
```yaml
JWT_SECRET: your-secret-key-at-least-32-characters-long
```

**Not used when tenant is configured with `jwt_algorithm: RS256`**.

### TOKEN_EXPIRATION_IN_HOURS (Environment Variable)

Controls JWT access token expiration time.

**Location:** Environment variable

**Default:** `2` (2 hours)

**Example:**
```yaml
# Environment configuration
TOKEN_EXPIRATION_IN_HOURS: 8
```

Affects:
- Access token lifetime
- Grace period for key rotation (should be 2× this value)
- Migration grace period for algorithm changes

## Further Reading

- [RFC 7517 - JSON Web Key (JWK)](https://www.rfc-editor.org/rfc/rfc7517)
- [RFC 7518 - JSON Web Algorithms (JWA)](https://www.rfc-editor.org/rfc/rfc7518)
- [OpenID Connect Discovery](https://openid.net/specs/openid-connect-discovery-1_0.html)
- [Available Endpoints](/oauth/endpoints)
- [JWT Decoding](/oauth/jwt_decoding)
