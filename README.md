# Container Action GitHub Ops

To get started,
click the
`Use this template`
button on this repository
[which will create a new repository based on this template](https://github.blog/2019-06-06-generate-new-repositories-with-repository-templates/).

Then modify the code after the
`# Put custom code after here`
comment in
`entrypoint.ps1`.

> NOTE: Don't forget to change the README as well with your specific info

## Depending on this Action in your workflows

Add this step to your GitHub Actions workflow yaml steps:

```yaml
- uses: TylerLeonhardt/container-action-github-ops@master
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

> NOTE: Since this is a container-based action, it can only run on linux. Make sure that your job that runs this step only has something like:
> ```yaml
> runs-on: ubuntu-latest
> ```

A very basic YAML might look like this:

```yaml
name: CI

on:
  pull_request:

jobs:
  lint:
    name: Do the thing
    runs-on: ubuntu-latest

    steps:
    - uses: TylerLeonhardt/container-action-github-ops@master
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Contents

* [PowerShellForGitHub](https://github.com/Microsoft/PowerShellForGitHub) module
  * Already authenticated using the `GITHUB_TOKEN` environment variable
  * Default `OwnerName` and Default `Repository` configuration already set
