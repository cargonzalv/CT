# common-tasks

This repository houses tasks that are common to multiple Concourse pipelines.
The versioning mechanism for these tasks may seem old-fashied, but it allows to
fullfill quite a few requirements. Read below.

## Consuming in Concourse

Declare a resource block in the following fashion:

```yaml
resources:
  - name: common-tasks-repo
    type: git
    source:
      uri: git@github.com:adgear/common-tasks.git
      private_key: ((adgear-concourse.ssh_private_key))
```

And use it in your job the following way:

```yaml
jobs:
  - aggregate:
    - get: common-tasks-repo
    - get: some-actually-relevant-things
      trigger: true
  - name: execute-a-common-task
    file: common-tasks-repo/task-name/latest/task-name.yml
  - name: execute-another-common-task
    file: common-tasks-repo/some-other-task/3.2/some-other-task.yml
```

The use of symlinks allows you to request a version according to [semantic
versioning](https://semver.org/), with flexible version pins. You can pin on a
major, or minor version. There is also the expectation that when using a loose
pin, you will never be provided with a release-candidate version.

Pinning on a fully qualified version will provide you with that version only.

## Design goals

This repository aims to provide the following :

- Allow one to subscribe to updates to common tasks
- Allow one to unsubscribe to updates to common tasks
- Semantic versioning at the task level
- Reduce the presence of repeated code and divergence in tasks
- Maintain common tasks in a monorepo

These objectives are tentative. If you'd like to approach the challenge of reusable tasks, you're welcome to dive into the [Concourse RFC for reusable tasks][1] and tackle this with the [#ci-cd-sig][2].

[1]: https://github.com/concourse/rfcs/issues/7
[2]: https://ads-ams25.slack.com/archives/C01M7CK9U3D 

## Contributing

Whenever you're creating or bumping a version, using the scripts at the root of
this directory will _(try to)_ ensure that all the loose versioning symlinks
point to the right thing.

### Updating an Existing Task

1.  Create your feature branch: `git checkout -b feature/my-new-feature`
2.  Prime a new version using `./new_version ${my_task} ${bump_type}`
3.  Commit your changes: `git commit -am 'Add some feature'`
4.  Push to the branch: `git push origin my-new-feature`
5.  Submit a pull request :D

### Creating a New Task

1.  Create your feature branch: `git checkout -b feature/my-new-feature`
2.  Create a new task with `./new_version ${my_task} ${any_bump_type}`
3.  Commit your changes: `git commit -am 'Add some feature'`
4.  Push to the branch: `git push origin my-new-feature`
5.  Submit a pull request :D

## License

> Copyright AdGear | Samsung Ads
