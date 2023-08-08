# OpenAPI schema for Podengo project

The OpenAPI schemas are used by the projects

* idmsvc-backend
* idmsvc-frontend
* ipa-hcc

## Integrating submodules with Podengo repos

Add submodule to a repository (replace `PATH`)

```sh
git submodule add https://github.com/podengo-project/idmsvc-api.git api
```

Update remote changes of a submodule

```sh
git submodule update --remote
```

then commit the changes. You can manually pull and checkout a revision
to update a submodule to a specific version.

Clone a repository with submodules

```sh
git clone --recurse-submodules
```

Initialize, fetch, and update submodules of an existing checkout

```sh
git submodule update --init
```

### Enable submodules in GitLab CI/CD pipeline

Set the environment variable `GIT_SUBMODULE_STRATEGY=normal`, e.g. in CI/CD
variables in the settings menu, see
[CI docs](https://docs.gitlab.com/ee/ci/git_submodules.html).
