# builder

A Concourse task to build Docker images.

This repository describes scripts which should be used to run a task similar
to `example.yml`.

### `image`

The task's alpine image could be any image with bash shell.

### `params`

* `$REPOSITORY`: the repository to name the image, e.g.
  `adgear-docker.jfrog.io/adgear/rtb-gateway`.

The following are optional:
* `BUILDKIT`      (default `0`): enable|disable buildkit

* `SSH_KEY_*`     (default empty) Params that start with `SSH_KEY_*` will be imported in ssh-agent

* `USERNAME`      (default empty) username for private repository

* `PASSWORD`      (default empty) password for private repository

* `DEBUG`         (default `false`) enable debug

* `PROGRESS`      (default `--progress plain`) enable container output during the build

* `$TAG`          (default `latest`): the tag to apply to the image.

* `$TAG_FILE`     (default empty): the tag should be a path to a file containing the name of the tag.

* `$CONTEXT`      (default `.`): the path to the directory to build. This should refer to one of the inputs.

* `$DOCKERFILE`   (default `$CONTEXT/Dockerfile`): the path to the `Dockerfile` to build.

* `$BUILD_ARG_*`  (default empty): Params that start with `BUILD_ARG_` will be
  translated to `--build-arg` options. For example `BUILD_ARG_foo=bar`, will become
  `--build-arg foo=bar`

* `$BUILD_ARGS_FILE` (default empty): path to a file containing Docker build-time variables.

  Example file contents:
  ```
  EMAIL=me@yopmail.com
  HOW_MANY_THINGS=1
  DO_THING=false
  ```

* `$TARGET` (default empty): the target build stage to build.

* `$TARGET_FILE` (default empty): the path to a file containing the name of the target build stage to build.

### `run`

Your task should execute the `build` script.


## example task

```sh
resources:
  - name: common-tasks-repo
    type: git
    source:
      private_key: ((adgear-concourse.ssh_private_key))
      uri: git@github.com:adgear/common-tasks.git
      branch: master

jobs:
  - name: build-release
    plan:
    - get: common-tasks-repo
    - task: build
      privileged: true
      params:
        BUILDKIT:   1
        SSH_KEY_0:  "((adgear-concourse.ssh_private_key))"
        REPOSITORY: adgear-docker.jfrog.io/adgear/rtb-gateway
        CONTEXT:    rtb-gateway-repo
        USERNAME:   ((artifactory.username))
        PASSWORD:   ((artifactory.password))
        TAG_FILE:   rtb-gateway-repo/.git/tag
      file: common-tasks-repo/build-task/latest/build-task.yaml


```
