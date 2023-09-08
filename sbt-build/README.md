# build-sbt

Builds an `sbt` project from the `source` folder and outputs the an artifact to
an `artifact` volume.

The version of the project is also output to the file `version/version`.

## Usage

```yaml
  - name: sbt-build-snapshot
    file: common-tasks-repo/sbt-build/latest/sbt-build.yml
    input_mapping:
      source: my-repo
    params:
      TASKS:        "clean test publish"

  - name: sbt-build-release
    file: common-tasks-repo/sbt-build/latest/sbt-build.yml
    input_mapping:
      source: my-repo
    params:
      TASKS:        "clean test package"
      IS_RELEASE:   true
```

This task requires access to the following Vault secrets:

- `((artifactory.username))`
- `((artifactory.password))`

## Contributing

1.  Create your feature branch: `git checkout -b feature/my-new-feature`
2.  Commit your changes: `git commit -am 'Add some feature'`
3.  Push to the branch: `git push origin my-new-feature`
4.  Submit a pull request :D

## License

> Copyright AdGear | Samsung Ads
