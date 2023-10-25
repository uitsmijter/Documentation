---
title: 'Migrating a monolith'
weight: 4
---

# Migrating a monolith application into microservices with single sign on

Page navigation:

- [General Discussion](#general-discussion)
- [Facing the problems of an application migration path](#facing-the-problems-of-an-application-migration-path)
- [The Demo-Project used for this documentation](#the-demo-project-used-for-this-documentation)
- [Configuring Uitsmijter](#configuring-uitsmijter)
- [checkcredentials Proxy Service](#checkcredentials-proxy-service)
- [Changes that need to be made](#changes-that-need-to-be-made)
- [You have made it!](#you-have-made-it)

## General Discussion

### The Path to Microservices: A Journey of Innovation and Empowerment

In today's fast-paced tech landscape, companies are continually seeking innovative ways to stay competitive and meet
evolving customer demands. One of the most profound shifts capturing the attention of forward-thinking organizations is
the transition from monolithic applications to microservices architecture transformation that revolutionizes the very
core of software development, deployment, and maintenance, offering compelling reasons to embrace the future.

### Scaling to New Heights

A driving force behind the widespread adoption of microservices lies in the promise of enhanced scalability and
performance. Traditional monolithic architectures treat applications as unwieldy monoliths, making it challenging to
scale specific components independently. The inefficiency of this approach often results in over-provisioning and wasted
resources. Microservices, however, introduce a level of granularity that empowers organizations to scale individual
services in response to demand. It's akin to a finely tuned symphony, where each instrument plays its part precisely,
optimizing resource allocation and, consequently, enhancing overall performance. The outcome is that applications
gracefully handle increased workloads and unforeseen traffic surges while delivering a superior user experience.

### Unleashing Flexibility and Agility in Development

The shift towards microservices isn't solely about infrastructure enhancement. It's a complete reimagining of how
software is developed. Microservices foster flexibility and agility by breaking down applications into smaller,
decoupled services. This modular approach empowers development teams to work independently on various services,
significantly reducing the bottlenecks associated with monolithic development. The ability to work in parallel
accelerates development cycles, resulting in a quicker time-to-market for new features and updates. Moreover,
microservices remain technology-agnostic, allowing organizations to select the best tools for each service. This
newfound agility harmonizes perfectly with DevOps practices, facilitating seamless automation and nurturing a culture of
continuous integration and continuous deployment (CI/CD). The outcome is a more nimble and responsive development
process, ultimately enhancing innovation and adaptability to ever-evolving business requirements.

### The Transformation of Processes and Team Dynamics

Transitioning from a monolithic to a microservices architecture isn't just a technological evolution; it necessitates a
fundamental rethink of processes and team structures.

Microservices reorient development efforts. In this brave new world, individual teams take ownership of specific
services, overseeing everything from development and testing to deployment. This autonomy accelerates the development
cycle, enabling teams to operate independently and concurrently.

Cross-functional teams become the norm in a microservices-centric landscape. These teams, composed of developers,
testers, DevOps engineers, and even product managers, collaborate harmoniously to ensure the seamless operation of each
service. Communication takes center stage as teams define service boundaries, APIs, and standards. Emerging roles like
"Service Owners" emerge to oversee the health and performance of specific services, emphasizing a holistic approach.

However, this transformation isn't without its challenges—robust tools, processes, and cultural shifts are essential. As
organizations scale the number of services, managing growth while maintaining consistency becomes a delicate balancing
act. Nevertheless, for those prepared to embrace change and invest in the future, the rewards of agility, scalability,
and enhanced development processes are well within reach through the embrace of microservices architecture.

### The Rise of Data Mesh

Following the shift to microservices, the benefits became evident, and the reconfiguration of team structures into more
autonomous and self-reliant units became the new norm.

What microservices are to applications, Data Mesh is to data. It represents an innovative approach to managing and
scaling data within organizations, particularly within large-scale, complex data ecosystems. The Data Mesh concept
heralds a paradigm shift in data management, aiming to make data more accessible, reliable, and scalable across
different parts of an organization.

Data Mesh addresses the challenges organizations face when dealing with vast and intricate data environments. It seeks
to dismantle data silos, elevate data quality, and empower domain-specific teams to independently manage and harness
their data assets.

### The Role of Authorization

Returning to the concept of monolithic team structures, it's worth noting that in the past, many organizations employed
a centralized IT department responsible for managing all applications. This evolved into a more advanced DevOps team,
facilitating collaboration and communication between development (Dev) and operations (Ops) within the organization.
Their core objective: streamline the software delivery process, automate repetitive tasks, and cultivate a culture of
continuous integration and continuous delivery (CI/CD).

Yet, a fundamental perspective shift occurs when we consider the needs of individual teams taking ownership of specific
services. The traditional model, where a centralized DevOps team deploys software for the development team, may no
longer align with this new paradigm. The modern DevOps philosophy proposes a different approach: the DevOps team should
not be the entity responsible for deploying the software. Instead, their role should evolve into one that empowers other
teams by providing exceptional tools and robust support to enable autonomous software deployment.

Enter the Authorization Server a critical component in the realm of modern software applications, especially those
embracing microservices architecture. It assumes responsibility for managing and enforcing access controls, ensuring
that only authorized users or services access specific resources or data. In the context of DevOps and microservices,
the Authorization Server becomes an integral part of the security and access control framework.

By empowering individual teams to manage their deployments and access control policies, the DevOps team can collaborate
effectively with the Authorization Server team to ensure seamless integration of security and access control mechanisms.
This collaboration guarantees that as new services are independently deployed, they are also appropriately secured, and
access is managed consistently and reliably.

In essence, the Authorization Server, alongside the evolving DevOps philosophy, enables organizations to strike a
balance between agility and security. It ensures that the autonomy and empowerment of individual teams do not compromise
the integrity and confidentiality of sensitive data and resources. This progress advances an organization's journey
toward a more streamlined and efficient software delivery process.

This transition to greater autonomy is only feasible when service teams possess the ability to manage
application settings independently. This autonomy allows them to respond swiftly to changing requirements, configuring
clients and tenants to align with their specific use cases. This agility is pivotal for delivering features and updates
promptly, ensuring that security and access control remain robust and well-maintained.

As the tech landscape evolves, Uitsmijter steps in to fill the gap that modern, self-organized service teams
face—controlling the complete lifecycle of services and data while enforcing access management. Uitsmijter ensures that
users moving between different products developed by various service teams are controlled by the global ACLs that each
team commits to.

With Uitsmijter, teams gain the ability to deploy clients and/or tenants in their own namespace while enforcing global
security standards. This harmonious combination of autonomy and security empowers teams to take charge of their
development while maintaining the integrity and confidentiality of data and resources.

## Facing the problems of an application migration path

Monolithic applications with their own login have one or more of the following factors in common:

- own, per application different kinds, of user authentication
- user data is stored in the applications database
- users usually have an internal ID, generated by the database (auto-increment)
- With this ID further fields from other database tables are linked

This results in the problem that removing the user authentication would entail a complete redesign of the application.
Moreover, many authentication systems demand the migration of user data to their dedicated user repositories, complete
with their unique sets of rights, roles, and profiles. These can be substantially different from the existing database
structures. When transitioning from an internal login system to OAuth, not only does the user handle change, but it also
triggers alterations within the internal structures of the application and impacts all database connections. However,
with Uitsmijter, these challenges can be circumvented. We will now explore a straightforward method for achieving this.

To enable the conversion of monolithic applications, which originally have their own login systems, to process an SSO
handle from external sources, users typically need to be migrated to an external system for most procedures.
Traditionally, this migration process involved several test runs, often conducted during batch processing at night,
especially when the implementation was not yet complete. Subsequently, the old application had to be entirely replaced
by the new implementation in a single significant transition (Big Bang). Unfortunately, this approach frequently
resulted in errors and application failures. However, with Uitsmijter, the transition of an application can be achieved
progressively and while it's in operation, all without any downtime. We'll delve into how this works shortly.

Previously, when monolithic applications shifted from custom login systems to OAuth, they had to grapple with the
complexities of OAuth in its entirety. This conversion was—and still is—a monumental task that consumes considerable
time and resources. However, we're about to unveil how Uitsmijter can simplify this process dramatically, making it an
ideal fit for modern, Sprint-based development methodologies.

When all these issues are combined (and so far, we've only discussed user-related concerns), it leads to a prolonged,
perilous, and intricate migration process. Many companies hesitate to undertake this migration, thereby delaying their
transition to a microservices architecture—a change that could significantly boost productivity for the vast majority of
organizations. Uitsmijter offers a solution—a software and accompanying guides that make migration secure, well-planned,
agile, and, most importantly, enjoyable for developers and project owners. Its transparent and intelligent approach
makes it a standout choice for navigating the complexities of this transformation.

### Prepare an Interceptor first

The Interceptor mode of Uitsmijter is primarily designed to secure individual web pages behind a login. Many users
employ this mode to protect HTML pages (for instance, within an intranet or a closed client area) or to implement
metering and a paywall to monetize editorial content.

While the Interceptor mode is well-suited for these purposes, it possesses features that can significantly aid us in the
migration process and should not be underestimated in terms of its capabilities.

Internally, Uitsmijter employs the same mechanisms and externally presents two modes: OAuth and Interceptor. Internally,
it is essentially the same, and an application protected through an Interceptor can easily be secured with an OAuth
client. An application whose authentication is protected via the Interceptor mode can be enhanced by OAuth microservices
that also recognize the user (SSO). This is precisely what we aim to achieve during the migration process: initially, we
transition the monolith's login, allowing us to gradually extract individual parts of the application as microservices.

By following this approach, we can break down the entire migration into manageable units, modernizing the infrastructure
step by step. Moreover, with each iteration, we can continue to work on additional features. No Big Bang, no risks, no
downtime.

As described, the simple Interceptor mode is indeed the ideal initial step to authenticate users through Uitsmijter
before we proceed to externalize specific aspects.

## The Demo-Project used for this documentation

To keep things simple, we use an easy ToDo-App to explain what is needed to migrate from a monolith to a microservice
architecture with Uitsmijter.

The following simple database setup is given to demonstrate the migration:
things
![Monolith ToDo Application Database Diagram](/resources/todo-app/todo-app-db.png "Database Diagram")

| Table           | Description                                                                                                                                                                                   |
|-----------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| failed_jobs     | Internal from the [🔗Laravel framework](https://laravel.com/) this legacy application is build upon. Queues in Laravel stores failed asynchronous job into the table.                         |
| migrations      | [🔗 Laravel](https://laravel.com/) provides database agnostic support for creating and manipulating tables across all supported database systems. The table stores the state of the database. | 
| users           | All users are stored in this table along a encrypted password and the email address of the user.                                                                                              | 
| sessions        | This application is a legacy monolith with its own user login. The active logins are stored in server sessions and be tracked in this database. <sub>1</sub>                                  |
| password_resets | Laravel provides convenient services for sending password reset links and secure resetting passwords.                                                                                         |
| todos           | For demonstartion purpose the application handels todo actions that are stored in this table. A foreign key to the users table links the user who created the task.                           |

> 1: This tutorial assumes that your monolithic application runs already on [🔗 Kubernetes](https://kubernetes.io). To
> run multiple pods of the application be sure that sessions are stored in database or other shared storage and not on the filesystem.

The application itself is very basic and a straight forward. It is a Laravel application written in PHP. You can find
and download the ToDo App on this [GitHub Repository](https://github.com/uitsmijter/example-todo-php-application).

The application provides a simple login page. After a user successfully logs in, a list of tasks is displayed. Each task
has a description and the user who created this task is shown right beside the task. The authorised user can create new
tasks and mark others as completed.

**Admittedly, this is a very simple application, but it has an obvious problem that must be taken into account if the
logout is not going to be part of the application itself in the future: All tasks in the `todos` table are linked to the
users table. If the user table should be pulled out in the future, the link that is made with a foreign key must be
replaced by something else.**

**Another problem could be that when this todo-list should also be accessible via a mobile app, the session can't be
used
when it turns to a stateless server.**

Let's dive into the code and understand how the login is made:

`AuthenticatedSessionController.php` have three methods:

- **create**: This method is called by a GET request to /login. it displays the login page.

```php
    public function create() {
        return view('auth.login');
    }
```

- **store**:  Handle an incoming authentication request. by a POST request from the login form.

```php
    public function store(LoginRequest $request) {
        $request->authenticate();
        $request->session()->regenerate();
        return redirect()->intended(RouteServiceProvider::HOME);
    }
```

First the `authenticate()` method is called to authenticate the user. The `authenticate` method in `LoginRequest.php`
checks the `email` and the `password` against the database. If this does not match, an error is returned.

The user session will be generated and at the end the request is redirected to the `HOME`, the page that shows the task
list.

- **destroy**: Destroy an authenticated session when the user logout.

The `TodoController.php` is as simple as the login controller:
- **store**: Creates a new ToDo item
- **update**: Updates the provided ToDo task

## Configuring Uitsmijter

To migrate this ToDo-Application to be used with a Single-Sign-On with Uitsmijter the first step is to create
a [Tenant](/configuration/entities/#tenant) with enabled [interceptor](/interceptor/interceptor) mode.

Create a Tenant:

```yaml
---
apiVersion: "uitsmijter.io/v1"
kind: Tenant
metadata:
  name: Tasks
  namespace: todo-application
spec:
  hosts:
    - todo.example.com
  interceptor:
    enabled: true
    domain: todo.example.com
    cookie: .example.com
  providers:
    - |
      class UserLoginProvider {
        auth = false;
        constructor(credentials) { this.auth = false; commit(this.auth); }
        get canLogin() { return this.auth; }
        get userProfile() { return { name: "No User" }; }
        get role() { return "user"; }
      }
    - |
      class UserValidationProvider {
        valid = false;
        constructor(args) { this.valid = false; commit(this.valid); }
        get isValid() { return this.valid; }
      }
```

> All details for tenant configuration are bespoken
> in [Tenant and client configuration](/configuration/tenant_client_config). For now, we accept this basic
> configuration, because we do not need any further settings.

The most important section in the tenant-yaml is the `providers` section. In this first configuration `this.auth` is set
to false, because no user should be able to log in yet.

At first, we want to leave the user data in the application database. To connect the uitsmijter tenant with the database
we have to write the first microservice that acts as a proxy.

> Be sure that your database credentials of the ToDo-Application is stored in a configmap or a secret. If the
> application is already running on Kubernetes this is mostly the case.
> We will use the same configmap or secret to configure the proxy-service to the user database.

At this point there are two options how a user database could be configured:

- An Api-Route in the existing Application to verify user credentials
- **An extra proxy-service to the database table**

You should always consider using option two! This is because we want to be able to composite our services more and if we
build the route to our existing legacy application we will never be able to pull things out in the future.

The next chapter describes the proxy service in detail, but first lets configure a uitsmijter tenant.
We do not need a Client for the interceptor mode, yet.

The Tenant for the ToDo application:

```yaml
---
apiVersion: "uitsmijter.io/v1"
kind: Tenant
metadata:
  name: Tasks
  namespace: todo-application
spec:
  hosts:
    - todo.example.com
  interceptor:
    enabled: true
    domain: todo.example.com
    cookie: .example.com
  providers:
    - |
      class UserLoginProvider {
        isLoggedIn = false;
        profile = {};
        role = null;
        constructor(credentials) {
          fetch(`http://checkcredentials.todo-application.svc/validate-login`, {
            method: "post",
            body: { username: credentials.username, passwordHash: credentials.password }
          }).then((result) => {
            var subject = {};
            this.profile = JSON.parse(result.body);
            if (result.code == 200) {
              this.isLoggedIn = true;
              this.role = profile.role;
              subject = {subject: this.profile.userId};
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
          fetch(`checkcredentials.todo-application.svc/validate-user`, {
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

The little ECMA-Scripts in the tenant providers do the following:

- `http://checkcredentials.todo-application.svc/validate-login` is called with `username` and the
  user password. See hashing options on the [providers page](/providers/providers). this would than look like this:

  ```typescript
  fetch(`http://checkcredentials.todo-application.svc/validate-login`, {
      method: "post",
      body: { username: credentials.username, passwordHash: sha256(credentials.password) }
  })
  ```
- If the HTTP status code is `OK`, than the user is logged in.
- The returned object is treated as the users `profile` that includes a `role` and a `userId`.

The `userId` is important and have to be unique for all users. The `userId` is the main handle to identify the user. In
the case of this demo application it must be the user-id from the database! We do have the flexibility to extend this
later on, but for now the best use case is to stick to the primary key from the legacy database.

**There is a problem in `UserLoginProvider`**: the password is not hashed! This is because the ToDo application stores
the passwords in Bcrypt. There is no Bcrypt hashing available in uitsmijter yet (_Checkout the roadmap for further
information_). But even when Bcrypt is available, we can not hash the password here, because Bcrypt'ed passwords can not
be compared with each other like sha265-hashes. This is because Bcrypt uses a unique salt for each password hash, so
even if two users have the same password, their Bcrypt hashes will be different due to the different salts. This makes
it impossible to compare them directly. Bcrypt also incorporates a work factor, which is a parameter that determines how
computationally intensive the hashing process is. This work factor can be adjusted, and it's typically set high to make
it time-consuming and resource-intensive for attackers to compute hash values. As a result, hashing the same password
multiple times will yield different results because the salt and work factor are different.

The proxy service must receive the plaintext password and match it with the Bcrypt hash in the database.

> For security reasons, make sure that you never expose the proxy service to the outside world. Make sure you have
> encrypted internal connections in Kubernetes.

That's all Uitsmijter needs to work properly and provide a login mechanism for the ToDo application.

_But wait..._ A service called `checkcredentials` needs to be created to act between Uitsmijter and the Users table.

## checkcredentials Proxy Service

In this [GitHub-Repository](https://github.com/uitsmijter/example-checkcredentials-typescript-proxyservice/) is a very simple example written in TypeScript upon
the [Koa-Framework](https://koajs.com). Let's walk through the functions:

A Credentials interface accepts the request from the `fetch` method of the tenant provider.

```typescript
export interface Credentials {
    username: string;
    password?: string;
}
```

Two routes are used by provider scripts: `validate-login` to check the user credentials and `validate-user` to check
if the user is still valid.

```typescript
router.post('/validate-login', validateLoginController);
router.post('/validate-user', validateUserController);
```

`validate-user` is straight forward and just checks if the user is still present in the database:

```typescript
export const validateUserController: Middleware = async (ctx) => {
    const body: Credentials = ctx.request.body as Credentials;
    if (body.username === undefined || body.username.length <= 0) {
        ctx.throw(StatusCodes.NOT_ACCEPTABLE, 'missing username');
    }
    const user = await prisma.users.findFirst({
        where: {email: body.username},
    });

    if (user) {
        ctx.body = '';
        ctx.status = StatusCodes.OK;
        return;
    }

    ctx.status = StatusCodes.NOT_FOUND;
};
```

If the user is present the funttion returns a status code `200`, if not than a `404` is returned.

In the `validate-login` function the password must be compared with the received password:

```typescript
export const validateLoginController: Middleware = async (ctx) => {
    const body: Credentials = ctx.request.body as Credentials;
    if (body.username === undefined || body.username.length <= 0
        || body.password === undefined || body.password.length <= 0) {
        ctx.throw(StatusCodes.NOT_ACCEPTABLE, 'missing credentials');
    }
    const user = await prisma.users.findFirst({
        where: {email: body.username},
    });
    if (user) {
        const valid = await compare(body.password!, user.password);
        if (valid === true) {
            ctx.body = JSON.parse(
                JSON.stringify(
                    user,
                    (key, value) => (typeof value === 'bigint' ? value.toString() : value),
                ),
            );
            ctx.status = StatusCodes.OK;
            return;
        }
        ctx.status = StatusCodes.UNAUTHORIZED;
        return;
    }
    ctx.status = StatusCodes.NOT_FOUND;
};
```

`compare(body.password!, user.password);` comes from [Bcrypt library](https://www.npmjs.com/package/bcrypt).

Enough coding. To access the service inside Kubernetes a service must be applied:

```yaml
---
kind: Service
apiVersion: v1
metadata:
  name: checkcredentials
  namespace: todo-application
spec:
  selector:
    app: checkcredentials
  ports:
    - protocol: TCP
      port: 80
      targetPort: 3000
```

When this application is deployed to Kubernetes the service is accessible internally
via `http://<service>.<namespace>.svc` = `checkcredentials.todo-application.svc`.

> **Warning**
> Do not create an ingress to this service. This should be accessible privately inside the cluster, only!

This tutorial assumes that you are familiar
with [Kubernetes Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) and you are able to
deploy an application.
See [this repository](https://github.com/uitsmijter/example-todo-php-application/tree/uitsmijter-backend/deployment) to get an example you can use.

## Changes that need to be made

Back to the PHP ToDo application, the user authentication needs to be changed to parse and decode a JWT instead of
checking the user credentials against the database.

To make the migration easier, we will be using [`php-open-source-saver/jwt-auth`](https://github.com/PHP-Open-Source-Saver/jwt-auth)
to handle the JWT parsing.

First we have to extend the `web` middleware group in `app/Http/Kernel.php` to contain `'jwt.auth'`  so that the JWT will be interpretet on every request.

```php
protected $middlewareGroups = [
    'web' => [
        'jwt.auth',
        \App\Http\Middleware\EncryptCookies::class,
        // [...]
    ],
    // [...]
];
```

Then we need a `JWTAuthProvider` which handles the user management by loading the existing user when it exists.

```php
class JWTAuthProvider extends JWTAuthIlluminate
{
    /**
     * @param mixed $id
     * @return bool
     */
    public function byId($id)
    {
        /** @var  $user */
        $user = User::whereEmail($id)->first();
        if (!$user) {
            return false;
        }

        // Log in the user for the request
        $this->auth->setUser($user);

        // User is authorized
        return true;
    }
}
```

To further prepare the application for the time when the available users are managed by another micro service completely,
we can extend it to create users on the fly when they don't exist yet.
For that we extend the previously implemented user check to create a user in the application database
instead of returning false which would abort the request:

```php
if (!$user) {
    /** @var JWTAuth $auth */
    $auth = app('tymon.jwt.auth');

    // Load payload data
    $payload = $auth->getPayload();

    // Create user
    (new User([
        'email'    => $payload->get('sub'),
        'name'     => $payload->get('profile')['name'],
        'password' => ''
    ]))->save();

    // Load created users data
    $user = User::whereEmail($id)->first();
}
```

This auth provider can now be configured in `config/jwt.php` (which can be generated by running
`php artisan vendor:publish --provider="PHPOpenSourceSaver\JWTAuth\Providers\LaravelServiceProvider"`)
by overwriting the `providers.auth` setting:
```php
'providers' => [
    // [...]
    'auth' => App\Http\Helpers\JWTAuthProvider::class,
    // [...]
],
```
It needes the `JWT_SECRET` configured in the environment (which is Uitsmijters `jwtSecret` shared secret),
for example in the projects `.env` file.

To support logout, the `AuthenticatedSessionController::destroy` method must be extended to use the `jwt` auth guard
and redirect to the Uitsmijter servers `/logout` endpoint with the right `client_id`  to properly end the session there.

That guard has to be configured in `config/auth.php` by extending the `guards` list:
```php
'guards' => [
    // [...]
    'jwt' => [
        'driver' => 'jwt',
        'provider' => 'users',
    ],
],
```

To make the user data rertrieval a bit easier, we should also change the users primary key to its e-mail address
by setting `protected $primaryKey = 'email';` and implementing the `JWTSubject` interface which can be done by adding the following methods:
```php
public function getJWTIdentifier()
{
    return 'email';
}

public function getJWTCustomClaims()
{
    return [];
}
```

This has the side-effect that queries which previously implicitly detect the reference keys must be explicitly set to `users.id`.
In this case that can be done by updating the `Todo` models `user()` method:
```php
return $this->belongsTo(User::class, 'user_id', 'id');
```

Last, when the application is deployed using Kubernetes, its Ingress must be extended to manage the user authentication by adding the annotation
`traefik.ingress.kubernetes.io/router.middlewares: uitsmijter-forward-auth@kubernetescrd`
where `uitsmijter` is the namespace of Uitsmijter and `forward-auth` the middleware name to forward the authentication handling.

## You have made it
Congratulations! A monolithic application with its own login has been transformed into an OAuth application.
Now you can use the same OAuth sessions for other clients and start pulling out features or attaching new features as microservices.
