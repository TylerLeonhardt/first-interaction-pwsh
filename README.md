# First Interaction (`pwsh` edition!)

An action for responding to the first issue and PR that a user opens.

# Usage

See [action.yml](action.yml)

```yaml
steps:
- uses: TylerLeonhardt/first-interaction-pwsh@master
  with:
    repo-token: ${{ secrets.GITHUB_TOKEN }}
    issue-message: "# Message with markdown.\nThis is the message that will be displayed on users' first issue."
    pr-message: "Message that will be displayed on users' first pr. Look, a `code block` for markdown."
```

This repo is using this Action so if you'd like to see a full example, checkout [the test.yml file](.github/workflows/test.yml).

# License

The scripts and documentation in this project are released under the [MIT License](LICENSE)
