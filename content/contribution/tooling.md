---
title: 'Toolchain'
weight: 2
---

# Commandline Tool To Build Uitsmijter - Tooling.sh

A build tool is a set of tools that automate the process of testing, compiling, assembling, and packaging source
code into executable software. Build tools are an essential part of the software development lifecycle, helping
developers manage the complexity of building, testing, and deploying software.

For Uitsmijter we build a toolchain that help developers to set up the environment to work easily with the code. As easy
it is to use Uitsmijter, it should also be easy for developers to work with the source code. We automate many repetitive
and error-prone tasks and describe those in maintainable bash scripts.

`Tooling` collects a set of functions that `build`, `lint`, `test`, `e2e` test and `run` the project in a docker compose
environment and in a local test cluster provided by [🔗 kind](https://kind.sigs.k8s.io/). The setup uses fast
incremental builds and supports the developers to create a consistent workflow where questions can be clarified quickly
among each other.

> Please use builds with the tooling setup only to request support.
> This tool ensures that errors can be traced and makes it easier for everyone to understand the request.

`Tooling` help to maintain consistency in the development and build process. Regardless of the developer's machine or
the development environment, the build tool ensures that the software can be built and tested in a predictable manner.

## Interface

```text
$ ./tooling.sh
Uitsmijter Tooling
============================================================
Choose one or more commands: 

        -b    | --build           | build         Build the project
        -l    | --lint            | lint          Check code quality
        -t    | --test            | test          Run all UnitTests
        -e    | --e2e             | e2e           Run end-to-end tests
        -r/-c | --run[-cluster]   | run[-cluster] Run Uitsmijter in docker or in a local kind-cluster
        -s    | --release         | release       Build a release version, can have an optional added image 
                                                  name (with optional tag)
        -p    | --helm            | helm          Build the helm package
        -h    | --help            | help          Show this help message

Additional Parameters: 

        --rebuild                     Force rebuild images
        --debug                       Enable debug output
        --dirty                       Use incremental temporary runtime for the local cluster

Example:
        ./tooling build run
        ./tooling -b -r
```

_**Whohoo** that are a lot of options!_ Don't panic! We'll discuss each command in a second. But first let's see how to
use the options.

Every option can be chained. Instead of build first and test then, like:

```shell
$ ./tooling.sh build
[...]
$ ./tooling.sh test
[...]
```

You may want to chain them together:

```shell
$ ./tooling.sh build test
```

You can add double hyphens or omit them `./tooling.sh --build` is the same as `./tooling.sh build`. Commands have a
long-hyphens and a short-hyphens form: `./tooling.sh --build` is the same as `./tooling.sh -b`. Depending on your taste
you can choose between: `build`, `--build` or `-b` which is all the same. In general, we recommend to use the _command_-
style (like: `build`) to call the build, but for scripting the automation tool it can be handy to have the other options
as well. In this documentation only _command-style_ (without hyphens) will be used.

## Commands

### build

Setup and build the project in a linux container for the current platform.

```shell
./tooling.sh build
```

After completion of the build, a `Uitsmijter` binary can be found in `./Deployment/Release/Linux/Uitsmijter`. On macOS
this file is not very usable on the local machine, because it is made to run inside a docker-runtime.
The `run` command uses the `build` command to build a binaray that can be run in your local docker environment. The
tests compile the code with debug flags and the `release` command ensure that everything is build from scripts. To work
with tests or to run code changes on your local machine, `build` as a standalone command is not needed. Nevertheless,
`build` is a useful command that is often used while developing, because `build` builds the source code incremental and
it is the fastest way to check if the code can compile.

> Before you try anything else, run build to see if the code is ready and can compile.

The first build will take a long time. After the first build is will take seconds, only.

### lint

Run [🔗 swiftlint](https://github.com/realm/SwiftLint) on the project.

```shell
./tooling.sh lint
```

The Uitsmijter community strictly enforces code styles. All rules are defined in `./.swiftlint.yml`. Code that violates
the rules can not be committed! To check if the code is clean to commit, run `tooling.sh lint`. In the case of errors
and warnings, there is a list of violations against the ruleset along the file and the line.

> Before you commit a feature, run `lint` to see that the commit would be accepted technically.

### test

Uitsmijter source code have a lot of [🔗 UnitTests](https://en.wikipedia.org/wiki/Unit_testing) that covers a lot of
internal functions and ensure the functionality of them. New features that introduces new functions to the codebase
should also deliver new UnitTests. To run the test, `swift test` compiles the code incrementally and test all
test suites. After the test a coverage reports is generated.

```shell
./tooling.sh test
```

### e2e

Besides the bespoken UnitTests, `e2e` runs end-to-end tests which can be found as shell scripts in `/Tests/e2e/`.
A local [🔗 kind](https://kind.sigs.k8s.io/) k8s test cluster is started to run a production release of Uitsmijter along
a set of tenant and client test-configurations.  
The test cluster runs the latest [release build](#release) which can be reached via https://uitsmijter.localhost if no
other option is set. `./tooling.sh e2e` is the same as `./tooling.sh release e2e`.

```shell
./tooling.sh e2e
```

Building a full release from scratch, starting a cluster and run all e2e-tests takes a long time but is essential to
ensure that the release really works. Every developer should run at least one final `e2e` test on a fresh release. For
developing this can be annoying when a release-build takes up to 10 - 20 minutes (depending on the power of the
machine). The fact that e2e-tests should run on a fresh production release only (at least in the ci) is the reason that
this is the default for the `e2e` command. **This can be lead in a very unproductive and frustrating day, obviously**.
When working **on** the e2e-tests that is not a problem, becuase `run-cluster` starts Uitsmijter in a local cluster and
the e2e-tests can be executed locally while development. But if a developer need to check multiple times if **a code**
change fixes a test-assertion-error then building a full release every time is not going to work. Therefore, it is
possible to test on a _dirty_ incremental build as well. Internally, instead of using a `release` for running the e2e
tests a `build` is used. This only takes seconds instead of multiple minutes. To use the incremental builds attach the
option `--dirty` to the command.

```shell
./tooling.sh e2e --dirty
```

> Do never ever use a --dirty flag in a CI! The safety of a fresh (non cached) release is always more important than
> saving CI-hours. Use `--dirty` in your own workflow only.

### run

Start the Uitsmijter server localy for testing in a docker environment. It can be reached at http://localhost:8080. The
`run` command executes a incremental `build` first, so `run`is the same as `build run`.

```shell
./tooling.sh run
```

The `run` command is usefully to check implementations that do not need further environments fast. It will run a
single docker container at the local machine and bind port `8080` to it. Run loads the default tenant and the default
client only. You may want to add more testing tenants at runtime to `./Resources/Configuration`. The `run` command
binds this directory and auto-refreshes the configuration without a restart (hot reload).

### run-cluster

To run a more sophisticated environment and to check the kubernetes features, a local cluster with a lot of preinstalled
applications (tenants and clients) can run on the local machine as well. The tool chain
uses [🔗 kind](https://kind.sigs.k8s.io/) to set up a local k8s test cluster.

With the generated `KUBECONFIG` (located in `./.build/kubeconfig`) kubectl can be used to operate the cluster.
The test cluster runs the latest [release build](#release) which can be reached via https://uitsmijter.localhost. Again,
a `release` ensures that the production release is build from scratch first. This takes a lot of time. Because this is
not productive when developing features a `--dirty` option can be passed.

```shell
./tooling.sh run-cluster 
```

is the equivalent for `release run-cluster`.

or

```shell
./tooling.sh run-cluster --dirty  
```

is the equivalent for `build run-cluster`.

### release

Build the release image which contains the Uitsmijter server without development tooling. Release build an official
image and generates helm chats for that.

```shell
./tooling.sh release
```

> It is not possible to run a `release` command with the `--dirty`option! A release is always a production artifact and
> ensures that is made from a non cached version.

### help

The `help` command show a list of available **commands** and **options**.

```shell
./tooling.sh help
```

## Additional Parameters

### force rebuild

Docker compose scripts rely on images, especially for incremental builds and e2e testing. If the images already exist,
they are not rebuilt unless `--rebuild` is provided.
Rebuilding the images is highly recommended on continuous integration build servers, otherwise changes in the scripts
of the supported containers such as the `e2e.Dockerfile` will be ignored if an older
image is still present on the system where the build runner exists.

```shell
./tooling.sh e2e --rebuild
```

### use dirty build

To speed up the local development it is not nessasarry to build a compleate `release` every time. In this case
a `--diry` option can be passed to `e2e` and `run-cluster` to use the incremental development build as a runtime images
for the cluster.

```shell
./tooling.sh e2e --dirty
```

### debug output

To see what the build tool is doing, pass `--debug` to the command. Debug outputs shows every command that the
automation scripts are doing onto the terminal output.

```shell
./tooling.sh build --debug
```

## Used Dockerfile

The `tooling.sh` script uses dockerfiles located in `Deployment/` and
the [🔗 docker-compose](https://docs.docker.com/get-started/08_using_compose/) file at: `Deployment/docker-compose.yml`

## Run through tooling and get familiar with the tool cahin

We discussed every option of `./tooling.sh` in this section but the best way to understand it and get familiar with the
functions is to use it. Follow this steps to see what it is doing by your own.

After checking out the code lets see the options first:

```shell
$ ./tooling.sh 
Uitsmijter Tooling
••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~ Branch: main | Version: 1.0.0                                       
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Choose one or more commands: 

        -b    | --build           | build         Build the project
        -l    | --lint            | lint          Check code quality
        -t    | --test            | test          Run all UnitTests
        -e    | --e2e             | e2e           Run end-to-end tests
        -r/-c | --run[-cluster]   | run[-cluster] Run Uitsmijter in docker or in a local kind-cluster
        -s    | --release         | release       Build a release version, can have an optional added image 
                                                  name (with optional tag)
        -p    | --helm            | helm          Build the helm package
        -h    | --help            | help          Show this help message

Additional Parameters: 

        --rebuild                     Force rebuild images
        --debug                       Enable debug output
        --dirty                       Use incremental temporary runtime for the local cluster

Example:
        ./tooling build run
        ./tooling -b -r

--------------------------------------------------------------------------------------------------------------
Documentation can be found at https://docs.uitsmijter.io


••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
• done.                                                                                                       
••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
```

Do a build first to check if it compiles:

```shell
./tooling build
[...]
```

This took a hugh amount of time.... On an Apple M1 Max, 64 GB it took round about 5 Minutes. Let's do it again:

```shell
./tooling build
[...]
```

Ok, that was much faster! It only took 13 Seconds. You understand the benefits of incremental builds, now.

Let's see how to use the other commands. Is the code tidy?

```shell
$ ./tooling lint
Check code style
==========================================================================================================
[
  {
    "check_name" : "Trailing Comma",
    "description" : "Collection literals should not have trailing commas.",
    "engine_name" : "SwiftLint",
    "fingerprint" : "2ab8228b061728b140fa84ed524708f0a79a8e1cc9b25f1b0c50ef7b097a9f8c",
    "location" : {
      "lines" : {
        "begin" : 19,
        "end" : 19
      },
      "path" : "Tests/ServerTests/Login/LoginControllerTests+Profile.swift"
    },
    "severity" : "MINOR",
    "type" : "issue"
  }
]
Done linting! Found 1 violations, 0 serious in 153 files.
```

Oups, what do we have here? There is one violation in a UnitTest file.
A `Collection literals should not have trailing commas.`. We can fix this
in `Tests/ServerTests/Login/LoginControllerTests+Profile.swift` at line `19`.

But first let's go on and run all UnitTests:

```shell
$ ./tooling lint
deployment-test-1  | Uitsmijter
deployment-test-1  | ------------------------------------------------------------
deployment-test-1  | Build info:
deployment-test-1  | 0|12|9|3
deployment-test-1  | Running tests with 8 workers.
[...]
eployment-test-1  | INFO: The optimized code generation is disabled
deployment-test-1  | Warning: LLVM version has changed. Parsing may fail.
deployment-test-1  | Checking Project Requirements...
deployment-test-1  | Tests: OK
```

There are a few things to mention:

- It compiles the code with development features embedded. This will take some time, because switching from `build`
  to `test` recompiles development features in. Running `test` twice in a row do only recompile changes in
  code or tests. Of course this is way faster.
- switching from `build` to `test` changes the development features and should be avoided. DO NOT
  RUN `./tooling.sh build test`.
- The line: `Build info: 0|12|9|3` is important. The last number `3` is the incremental run on the build. It will
  increase every time a test is run (`0|12|9|4`, `0|12|9|5`, ...). If this number is high and test results are
  questionable, try to force rebuild the code.

If a test fails, the reason will be printed out.

Let's run Uitsmijter in development:

```shell
$ ./tooling.sh run 
[...]
Run incremental build in a docker environment
================================================================================
[+] Running 3/3
✔ redis
[...]
Attaching to deployment-run-1
deployment-run-1  | Uitsmijter
deployment-run-1  | ------------------------------------------------------------
deployment-run-1  | +------+------------------+
deployment-run-1  | | GET  | /                |
deployment-run-1  | +------+------------------+
deployment-run-1  | | GET  | /health          |
deployment-run-1  | +------+------------------+
deployment-run-1  | | GET  | /versions        |
deployment-run-1  | +------+------------------+
deployment-run-1  | | GET  | /metrics         |
deployment-run-1  | +------+------------------+
deployment-run-1  | | GET  | /login           |
deployment-run-1  | +------+------------------+
deployment-run-1  | | POST | /login           |
deployment-run-1  | +------+------------------+
deployment-run-1  | | GET  | /logout          |
deployment-run-1  | +------+------------------+
deployment-run-1  | | POST | /logout          |
deployment-run-1  | +------+------------------+
deployment-run-1  | | GET  | /logout/finalize |
deployment-run-1  | +------+------------------+
deployment-run-1  | | GET  | /interceptor     |
deployment-run-1  | +------+------------------+
deployment-run-1  | | GET  | /authorize       |
deployment-run-1  | +------+------------------+
deployment-run-1  | | POST | /token           |
deployment-run-1  | +------+------------------+
deployment-run-1  | | GET  | /token/info      |
deployment-run-1  | +------+------------------+
deployment-run-1  | Starting Uitsmijter...
deployment-run-1  | 2023-09-24T12:06:42+0000 error codes.vapor.application : [Vapor] Application.shutdown() was not called before Application deinitialized.
deployment-run-1  | [INFO]     Sun, 24 Sep 2023 12:06:42 GMT: Current Loglevel is [debug]
deployment-run-1  | [INFO]     Sun, 24 Sep 2023 12:06:42 GMT: Uitsmijter Version: dirty
deployment-run-1  | [INFO]     Sun, 24 Sep 2023 12:06:42 GMT: Boot redis
deployment-run-1  | [INFO]     Sun, 24 Sep 2023 12:06:42 GMT: Found 1 resources in /app/Resources/Configurations/Tenants
deployment-run-1  | [INFO]     Sun, 24 Sep 2023 12:06:42 GMT: Add new tenant 'Uitsmijter' with 3 hosts
deployment-run-1  | [INFO]     Sun, 24 Sep 2023 12:06:42 GMT: Found 2 resources in /app/Resources/Configurations/Clients
deployment-run-1  | [INFO]     Sun, 24 Sep 2023 12:06:42 GMT: Add new client 'secretclient' [B948FFA3-BEE5-4992-BEBE-B581308E6E1D] for tenant 'Uitsmijter'
deployment-run-1  | [INFO]     Sun, 24 Sep 2023 12:06:42 GMT: Add new client 'Localclient' [66CC4B67-7BED-48E8-AE2E-8A6DBE07B879] for tenant 'Uitsmijter'
deployment-run-1  | [NOTICE]   Sun, 24 Sep 2023 12:06:42 GMT: Server starting on http://0.0.0.0:8080 
```

It first starts a local [🔗 redis](https://redis.io) in docker and then builds the runtime, if not present on your
machine. The runtime will **link** the Uitsmijter binary from the `build` step as a volume into the container.

> Note that `run` uses the Uitsmijter from the project/Deployment/Release/Linux directory as a Link. The Runtime did not
> have a baked in copy of the binary. Therefore run implicit uses a `build` first.

Open your browser at https://localhost:8080/:

```shell
$ curl http://localhost:8080/versions
dirty
```

You see that you are not at a release and the version is _dirty_.

If you run Uitsmijter in a local cluster, the tooling scripts will build a `release` first. Let's take the time and do
it for demonstration purpose:

```shell
$ ./tooling.sh run-cluster
Run release in local KubernetesInDocker
================================================================================

Build a fresh production release
================================================================================
[+] Building ...                                                                                                                                                                                             
```

Ok, honestly... time for a coffee.

Because `run-cluster` needs a `release` version and a helm package that can be deployd onto the cluster, the
full `release` will be run first. That takes a lot of time, because it will generate a docker image from scratch without
any caches. That includes:

- updating the docker image os
- downloading packages
- compile everything for testing
- running UnitTests
- recompile for production
- build a standalone runtime
- copy artifacts from one image to the other

Regardless how often `release` or `run-cluster` or `e2e` is called, it will always take the time to rebuild everything
from scratch to ensure a full atomically build deliverable that can't be faked. If this works and an image is made
successfully, then it is ready to run on production servers.

The scripts are made with the ideas in mind, that it is possible to create a production release only with a valid
version of the source code. **There should be no way to accidentally release a broken version**.

Back to output of `run-cluster`:

```shell
[...]
Checking requirements
---------------------------------------------------------------------------------------
[...]
```

To run Kubernetes on your machine you need a few tools installed. The script checks for existence.

- kubectl
- helm
- gdate (on macOS only)

```shell
[...]
Setup cluster
---------------------------------------------------------------------------------------
[...]
Setting up environment
---------------------------------------------------------------------------------------
[...]
Setup Uitsmijter
---------------------------------------------------------------------------------------
[...]
```

Uitsmijter will be installed from your production image build locally via helm.
`run-cluster` will also install some demo application that are used in the `e2e` tests, too:

```shell
⬇ Install application BNBC
--------------------------
[...]

⬇ Install application Ham
-------------------------
[...]

⬇ Install application Cheese
----------------------------
```

You can find information about the test applications at `./Tests/e2e/readme.md`.

```shell
Cluster is running.
Add the following to your local /etc/hosts file.

127.0.0.1 api.example.com
127.0.0.1 [...] # and others

Press enter to stop the cluster
```

To use the test applications you have to add a lot of hosts to your local /etc/hosts file (or to your local DNS).

Ok, lets add them to /etc/hosts and fetch the version of Uitsmijter again:

```shell
$ curl -k https://uitsmijter.localhost/versions
0.9.2-135-g1dbcb33-dirty
```

As we write this documantation we are on Version 0.9.2 and we have some new or changed files in the git commit with the
hash `g1dbcb33`. Because the git status is not committed yet, a `-dirty` is attached to the version.

If we run `./tooling.sh` without any command we will see that info too:

```shell
$ ./tooling.sh
Uitsmijter Tooling
•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~ Branch: feature-UIT-422-improve-tooling | Version: 0.9.2-135-g1dbcb33                                                                                                                                              ~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
[...] 
```

You see, that I am working in a git branch named `feature/UIT-422-improve-tooling`. The last commited tag was `0.9.2`
and since then `135` commits are done. I am on revision `g1dbcb33`. This information is reflected in the version sting
returned by the `/version` route.

Now, because Uitsmijter is running iun Kubernetes, we kann use `kubectl` to control the deployment, the `Tenant`
and `Client` configuration, see, logs, test auto-scaling, and so on.

For example lets increase the running pods :

```shell
$ kubectl --kubeconfig=.build/kubeconfig get pods -n uitsmijter 
NAME                                     READY   STATUS    RESTARTS   AGE
redis-master-0                           1/1     Running   0          14m
redis-slave-0                            1/1     Running   0          14m
uitsmijter-authserver-6778757698-9b45w   1/1     Running   0          14m
```

we have one authserver up and running.

```shell

$ kubectl --kubeconfig=.build/kubeconfig scale --replicas=2 deployment/uitsmijter-authserver -n uitsmijter
deployment.apps/uitsmijter-authserver scaled

$ kubectl --kubeconfig=.build/kubeconfig get pods -n uitsmijter      
uitsmijter-authserver-6778757698-9b45w   1/1     Running   0          19m
uitsmijter-authserver-6778757698-gs9xc   0/1     Running   0          7s
```

You may want to add new namespaces and add your own application.

Ok, as cool as this is, running a cluster with `run-cluster` needs a fresh production images that takes a lot of time.
Doing this is recomended when working on another application that just needs Uitsmijter. It is super unproductive if we
are working on Uitsmijter itself. Changeing one line of code and building a compleate fresh release is a 1:300 ratio.
Therefore, it is possible to run a cluster with a incremental build `dirty` version, like it is with the `run` command:

```shell
$ ./tooling run-cluster --dirty

Run release in local KubernetesInDocker
======================================================================================================================================================================================================================

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 🟠 BUILD A RELEASE WITH A DIRTY VERSION!! USE THIS FOR LOCAL TESTING ONLY !
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

[...]
```

This compiles much faster after the first run. Lets see what the `/version` route is showing:

```shell
curl -k https://uitsmijter.localhost/versions
dirty
```

Which is exacltly what we've seen before in the `run` command. The only difference between `run`
and `run-cluster --dirty` is, that `run` starts uitsmijter in docker only, while `run-cluster --dirty` runs Uitsmijter
in a Kubernetes environment.

> The different in the images between `run` and `run-cluster` are, that the runtime for `run` does not include the
> binary itself. To deploy an application onto kubernetes with helm we need a runtime that has uitsmijter baked in. That
> is why we copy Uitsmijter only optional into the runtime in `./Deployment/Runtime.Dockerfile`.

The pricipals of the `--dirty` flag should be clear now. You can apply the same thing to run `e2e`-tests. `e2e` alone
will build a new release every time. `e2e --dirty` uses the incremental build and bake it into a runtime that is used.

```shell
$ ./tooling.sh e2e --dirty

Run all e2e tests
================================================================================

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 🟠 BUILD A RELEASE WITH A DIRTY VERSION!! USE THIS FOR LOCAL TESTING ONLY !
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

Build a binary incremental
================================================================================
[+] Running 1/0
 ✔ Container deployment-build-1  Created                                                                                                                                                                         0.0s 
Attaching to deployment-build-1
deployment-build-1  | Uitsmijter
deployment-build-1  | ------------------------------------------------------------
deployment-build-1  | Compiling plugin PackageBuildInfoPlugin...
deployment-build-1  | Building for production...
deployment-build-1  | Build complete! (0.33s)
deployment-build-1 exited with code 0
Aborting on container exit...
[+] Stopping 1/0
 ✔ Container deployment-build-1  Stopped                                                                                                                                                                         0.0s 
[...]
```

See, the build took only 33ms. For testing multible times, this is much better than 5 minutes.

In summary, the intention of the Tooling for Uitsmijter is to streamline the software development process by automating
various tasks, maintaining consistency, and providing developers with a user-friendly command-line interface for
efficiently building, testing, and managing the Uitsmijter project.
