# mvn-build

Build Java Maven projects.

```yaml
  - name: mvn-build-snapshot
    file: common-tasks-repo/mvn-build/latest/mvn-build.yml
    input_mapping:
      source: my-repo

  - name: mvn-build-release
    file: common-tasks-repo/mvn-build/latest/mvn-build.yml
    input_mapping:
      source: my-repo
    params:
      IS_RELEASE: true
```

## License

> Copyright AdGear | Samsung Ads
