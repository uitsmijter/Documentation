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
