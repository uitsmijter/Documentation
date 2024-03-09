---
title: 'Test Cluster Domains'
weight: 3
---

# Test Cluster Domains

When running `run-cluster` from the [Toolchain](/contribution/tooling) command, a bunch of test domains are set up in a local Kubernetes cluster. 
You can use these domains to test and evaluate Uitsmijter. 

## Cheese tenant example domains

### api.example.com
This domain does not have an endpoint. This domain is used for tests and return a `404` page not found when called.   

### cookbooks.example.com
In **cookbooks**, a page served by a nginx container, you will find delicious recipes. Login is restricted via [interceptor](/interceptor) mode. Every user
that ends on `@example.com` (like `me@example.com`) with **any password** will be granted.

The Cookbook is managed by the _cheese_ tenant. The login domain is: [login.example.com](#login.example.com)

### goat.example.com
The **goat** page is an addition the cookbooks page, and it is also part of the  _cheese_ tenant. The information about goat cheese on an Uitsmijter
is restricted via [interceptor](/interceptor) mode. Since cookbooks and goat shares the same interceptor cookie domain and the same login 
domain ([login.example.com](#login.example.com)), you are already loged on goat if you are login on cookbooks. 

Because the goat page is managed by the same tenant as the cookbooks, every user that ends on `@example.com` (like `me@example.com`) with 
**any password** will be granted, too.

### toast.example.com
Another static page, managed by the _cheese_ tenant and secured by [interceptor](/interceptor) mode.

Like goat and cookbooks, every user that ends on `@example.com` (like `me@example.com`) with
**any password** will be granted.

### spa.example.net
**spa** is the simplest form of a single page application login. It's for testing purpose only.

### id.example.com
**id**.example.com is the main domain for Uitsmijter for the _cheese_ tenant.   
 
If you are logged in to one oft the pages of the tenant (
[cookbooks.example.com](#cookbooks.example.com), 
[goat.example.com](#goat.example.com), or 
[toast.example.com](#toast.example.com) 
) 
You can see your payload when visiting https://id.example.com 
Similar to this output: 
```
Payload: [profile: "[name: "Test User"]", tenant: "cheese/cheese", user: "me@example.com", responsibility: "dbf0dea75e338e296e034be7b3d69aab4407771f", exp: "1710602009.281026", sub: "me@example.com", role: "user"]
```
If you are logged out, a login mask is presented. 

### login.example.com
This domain is used as a proxy domain for the interceptor mode of the cheese tenant. The configuration of a proxy page is 
described on the [interceptor mode documentation](/interceptor/interceptor/#configuration-and-examples) page.

When this page [https://login.example.com](https://login.example.com) is called up directly, an Uitsmijter error `ERRORS.NO_TENANT` is displayed,
because Uitsmijter does not know which page you are trying to login for. Proxy pages can only be accessed via a referrer registered in the tenant.

### missing-tenant.example.com
The **missing-tenant** domain is set as a secondary ingress to [login.example.com](#login.example.com), but not registered inside the tenant configuration.
Whenever you call this domain a `ERRORS.NO_TENANT` error should be presented.  

> So even if you pass a callee url to the missing-tenan domain, like https://missing-tenant.example.com/?for=https://goat.example.com/&mode=interceptor
> Uitsmijter have to deny the login!

## Ham tenant example domains

### page.ham.test
On this page of the _ham_ tenant you can read the story about Hank and Ellie. It is about an unexpected friendship.
The page is served by a nginx contaienr and secured via [interceptor](/interceptor) mode.

Because the _ham_ tenant turned the silen_login mode off, you are not logged in to **page** when you are logged in to [shop](#shop.ham.test).

Every user that ends on `@example.com` (like `me@example.com`) with **any password** will be granted.

### shop.ham.test
Like [page](#page.ham.test) **shop** is also a static webpage served by nginx and secured via [interceptor](/interceptor) mode.

Because the _ham_ tenant turned the [silent_login](/configuration/tenant_client_config/#tenants) mode off, you are not logged in 
to **page** when you are logged in to [shop](#shop.ham.test).
You can not switch back and forth page and shop without login again, because the domain is bound to the token when silent_login is 
disabled. 

Because this domain belongs to the same tenant as [page.ham.test](#page.ham.test), the same login credentials (every user that ends 
on `@example.com`, like `me@example.com` with any password) will be granted.   

### api1.ham.test 
This domain is only used in tests as a redirect url. 

### api2.ham.test
This domain is only used in tests as a redirect url.

### login.ham.test
**login**.ham.test is the main domain for Uitsmijter for the _ham_ tenant.
This domain is possible not used any longer and will be removed! 

### id.ham.test
**id**.ham.com is the interceptor proxy domain to log in via Uitsmijter. Proxy domains are necessary for interceptors and described
on [interceptor mode documentation](/interceptor/interceptor/#configuration-and-examples) page.

Ham does have customized templates, so the login page will look different from the default Uitsmijter login page of the _chease_ tenant. 

If you are logged in to one oft the pages of the tenant 
([page.ham.test](#page.ham.test) or [shop.ham.test](#shop.ham.test))

### *.s3.ham.test
Internal S3-Server to store customized templates 

Credentials:
- **access_key**: `admin` 
- **secret_key**: `adminSecretKey`

## BNBC tenant example domains

### blog.bnbc.example
This domain hosts the **blog** of the `Bread And Butter Company`. The blog is served by a nginx and secured 
via [interceptor](/interceptor) mode.

Every user that ends on `@example.com` (like `me@example.com`) with **any password** will be granted.

Because the _bnbc_ tenant turned the silen_login mode on, you are logged in to **blog** if you are logged in to [shop](#shop.bnbc.example).

### shop.bnbc.example
Maya and Liam (The owners of the Bread And Butter Company) does have a shop, too. The shop is served by a nginx and secured
via [interceptor](/interceptor) mode.

Because this domain belongs to the same tenant as [blog.bnbc.example](#blog.bnbc.example), the same login credentials (every user that ends
on `@example.com`, like `me@example.com` with any password) will be granted.

The _bnbc_ tenant turned the [silent_login](/configuration/tenant_client_config/#tenants) mode on, so you are logged in
to **shop** if you are already logged in to [blog](#blog.bnbc.example).

### login.bnbc.example
**login**.bnbc.example is the interceptor proxy domain to log in via Uitsmijter. Proxy domains are necessary for interceptors and described
on [interceptor mode documentation](/interceptor/interceptor/#configuration-and-examples) page.

You can see your payload when loged in via [https://login.bnbc.example/?for=https://shop.bnbc.example/&mode=interceptor](https://login.bnbc.example/?for=https://shop.bnbc.example/&mode=interceptor)

### api1.bnbc.example
This domain is only used in tests as a redirect url.

### api2.bnbc.example
This domain is only used in tests as a redirect url.

## Uitsmijter tenant
### uitsmijter.localhost
This domain is the base domain of the Uitsmijter deployment. It handles this domains: 
- test.localhost
- uitsmijter.localhost

All users are granted. 

 
