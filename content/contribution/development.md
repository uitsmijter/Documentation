---
title: 'Project information'
weight: 1
---

# Project information

This project is written in [Swift 5.7](https://www.swift.org). With grate support from the [Vapor](https://vapor.codes)
framework and the [Swift Server Workgroup](https://www.swift.org/server/) community.

Please check out the [server side swift](https://www.serversideswift.info) conference if you are interested.

Uitsmijter chooses swift, because of:

- safety
    - Strongly Typed
    - encourages to write clean and consistent code
    - safeguards
    - Well-designed asynchronous programming interface
- performance
    - Small footprint
    - Quick startup time
    - Deterministic performance
- software design patterns

## Code structure

[Swift](https://www.swift.org)'s history and also [Vapor](https://vapor.codes)'s boilerplate's sort code into
folders according to their **technical role**. For example: all controllers, like login-routes, metrics-routes, etc. are
stored in the `Controllers` folder. All models are stored in `Models` etc. Often, you see projects with all
extensions in a `Extensions` folder, etc....

As much as we stick to common sense and best practices, we break this rule for multiple reasons:

- The type is already included in the filename, and if not, the type will reflect that. A `struct user` is always a
  User model and will never be a `/users` route, which would be called `UsersController`.
- The understandability of the application parts as a concept is more important than a known comfort zone when the
  application is first opened.
- This is especially true when an application has a strong impact on the security of third-party applications.
- Targeting function blocks, tracking changes, and checking closed folders is more comfortable than jumping around the
  entire application.

Initially, I (the first developer) tried to fit the code for this project into exactly this known ordering structure,
but I soon found it difficult to get an overview of what a business function needs and how the business units are
separated from each other and how to link them together in a way that any new developer would understand it directly.
Halfway through, I switched to a `domain driven design` and organized the source files according to their functionality.

This means:

- `Controllers` are distributed everywhere
- There is a `Login` folder, where all controllers, models, extensions, which are necessary and hardly bound to the
  login function, right next to a `ScriptingProvider` folder that contain all the source code for the provider
  javascript scripting functionality. Nevertheless, a `Monitor` folder contains all the controllers, models, etc. that
  need the `/health` and `/metrics` routes to operate.

The disadvantages:

- We will have some leftovers that do not fit in one area.
- Common code is between two functions and should be in both.

There will be mixed directories, that do not describe a clear domain. For example there is a `Entities` directory,
that does exactly what a `Models` folder should do, but we keep it clear from other models than pure entities that are
acting inside the system and are interchanging between the domains.

We are trying to minimize the downsides and hope that the brake on the rules will help maintaining a safe system.

## Getting it to work

For development, the Uitsmijter source provides a toolchain to **build**, **lint**, **test** and **run** the Project
locally inside a [Docker](https://www.docker.com) container. See [tooling](/contribution/tooling) for a detailed
description.

If you do not like to work inside docker, Uitsmijter should run on every system that supports the Swift language,
including Mac, Linux and Windows. [List of supported platforms](https://www.swift.org/download/).

Before editing, be sure that it builds correctly:

1. Check out the packages:

```shell
swift package resolve
```

2. Running tests:

```shell
swift test
```

3. Build the binary:

```shell
swift build
```

4. run Uitsmijter locally:

```shell
swift run
```

> We highly recommend to use the [toolchain](/contribution/tooling) and build Uitsmijter inside the container.

## Further readings

- Using the [toolchain](/contribution/tooling) for development at Uitsmijter.
- [Guidelines](/contribution/guidelines) for development.
- [Alternatives to Uitsmijter](/contribution/list-of-competitors) for development.
