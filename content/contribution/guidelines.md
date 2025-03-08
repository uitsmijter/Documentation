---
title: 'Development guidelines'
weight: 4
---

# Development guidelines

## Pull requests are very much desired

Please open a new branch with the naming scheme `feature/<#Issue>-<#Description>` or `fix/<#Issue>-<#Description>`
regarding the type of the change. Do a descriptive pull request against the `main` branch. Prepare the pull request;
we prefer small requests, that are squashed into the main branch.

Pull request on an open issue have higher priorities, because every pull request should be inclusive and everyone in the
community should be enabled to talk about the changes. So it is highly recommend to open an issue first, before starting
development.

> Check the release with `./tooling.sh` [tooling.sh](/contribution/tooling) as it runs a pipeline-like check on
> your local environment.

## Linting

Use `swiftlint` (best in your IDE while saving) to lint the code before committing it.
[tooling.sh](/contribution/tooling) has a lint option that lists all errors end warnings that should have been fixed
before committing the pull request.

## Requirements

**Pipelines must succeed**  
The CI will test the project first for a list of requirements:

- A zero warning state is desirable
- All tests must pass
- A sufficient code coverage is required

**Find Friends**    
A pull request has to be approved by at least one other person.

**All threads must be resolved**    
Code comments are highly recommended. Be precise in your critique rather than polite. Both is most welcome.

### Leftovers and temporary code

Do not merge code that contains sources that are unused and leftovers.

### Use test secrets only

# Using Test Secrets for Development

When developing tests, that require authentication credentials, API keys, or other sensitive information, always 
use designated test secrets rather than random production credentials in your development environment. 

Test secrets are specially created credentials that are widely recognized within the development team and can be 
verified against established security policies that were specifically designed for development and testing environments.

Using production secrets in development environments creates significant security vulnerabilities, as these 
high-privilege credentials may be inadvertently exposed through code repositories, logs, or local environment files. 
Additionally, development operations using production credentials might accidentally modify or delete production data, 
causing service disruptions for end users. 

By maintaining strict separation between test and production secrets, you establish important security boundaries that 
protect your live systems, while still allowing developers to build and test functionality against realistic environments. 

We commit test secrets to source control system environments to provide consistent end-to-end tests. 

This is a list of used secret strings: check your production environment that these secrets are never used in production:

| Key           | Value                                                            |
|---------------|------------------------------------------------------------------|
| Client secret | luaTha1qu019ohc13qu3ze1yuo5MumEl0hQuoE9bon                       |
| Client secret | kei8vae6baeMeiNehaepoo2ha1lae3wa                                 |
| JWT secret    | vosai0za6iex8AelahGemaeBooph6pah6Saezae0oojahfa7Re6leibeeshiu8ie |
| Redis Secret  | Shohmaz1                                                         |


## Contributions

When contributing to this repository, please first discuss the change you wish to make via
an issue.

Please note we have a [code of conduct](/contribution/codeofconduct), please follow it in all your interactions with the
project.

You have to agree to the [Developer Certificate of Origin](/contribution/certificate_of_origin)!

## Trunk-based Development

We are using [Trunk-based Development](https://trunkbaseddevelopment.com). Do always a feature-branch for your
commit and open a [merge request](https://docs.gitlab.com/ee/user/project/merge_requests/) back into
the main branch when you are absolutely sure that it works. Ask another member of the team if you are not sure about it.

## Pull Request Process

1. Ensure any install or build dependencies that aren't covered by the [tooling.sh](/contribution/tooling) script are
   removed before committing the pull request.
2. Update the [CHANGELOG.md](/CHANGELOG.md) with details of changes to functionality and to all interfaces, this
   includes new environment variables, exposed ports, useful file locations and container parameters.
3. Let other people review your merge request and add suggestions made by the community into your code.

## Further readings

- Our [code of conduct](/contribution/codeofconduct)
