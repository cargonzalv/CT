#!/bin/env bash
set -o errexit -o nounset -o pipefail

apk --no-cache add \
      nano \
      pigz \
      openssh-client >/dev/null 2>&1

apk --no-cache add docker --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community

function sanitize_cgroups() {
  mkdir -p /sys/fs/cgroup
  mountpoint -q /sys/fs/cgroup || \
    mount -t tmpfs -o uid=0,gid=0,mode=0755 cgroup /sys/fs/cgroup

  mount -o remount,rw none /sys/fs/cgroup

  sed -e 1d /proc/cgroups | while read sys hierarchy num enabled; do
    if [ "$enabled" != "1" ]; then
      # subsystem disabled; skip
      continue
    fi

    grouping="$(cat /proc/self/cgroup | cut -d: -f2 | grep "\\<$sys\\>")" || true
    if [ -z "$grouping" ]; then
      # subsystem not mounted anywhere; mount it on its own
      grouping="$sys"
    fi

    mountpoint="/sys/fs/cgroup/$grouping"

    mkdir -p "$mountpoint"

    # clear out existing mount to make sure new one is read-write
    if mountpoint -q "$mountpoint"; then
      umount "$mountpoint"
    fi

    mount -n -t cgroup -o "$grouping" cgroup "$mountpoint"

    if [ "$grouping" != "$sys" ]; then
      if [ -L "/sys/fs/cgroup/$sys" ]; then
        rm "/sys/fs/cgroup/$sys"
      fi

      ln -s "$mountpoint" "/sys/fs/cgroup/$sys"
    fi
  done

  if ! test -e /sys/fs/cgroup/systemd ; then
    mkdir /sys/fs/cgroup/systemd
    mount -t cgroup -o none,name=systemd none /sys/fs/cgroup/systemd
  fi
}

sanitize_cgroups

stty columns 80

: "${DEBUG:=false}"
if "$DEBUG"; then
  set -x
fi

: ${PROGRESS:="--progress plain"}
: ${LOG_FILE:="/tmp/docker.log"}
: ${BUILDKIT:="0"}
REGISTRY=$(echo $REPOSITORY | cut -d/ -f1)
: ${TAG:="latest"}
: ${TAG_FILE:=""}
: ${CONTEXT:="."}
: ${DOCKERFILE:="$CONTEXT/Dockerfile"}
: ${DOCKERDARGS:=""}
: ${TARGET:=""}
: ${TARGET_FILE:=""}
BUILD_ARGS_OPT=$(env | awk '/BUILD_ARG_/ {gsub(/BUILD_ARG_/, "--build-arg "); printf "%s ",$0}')
: ${BUILD_ARGS_FILE:=""}
: ${SAVE_ARTIFACT:=false}

: ${SQUASH:=false}
if "$SQUASH"; then
  SQUASH="--squash"
else
  SQUASH=""
fi

tag_name=""
if [ -n "$TAG_FILE" ]; then
  if [ ! -f "$TAG_FILE" ]; then
    echo "tag file '$TAG_FILE' does not exist"
    exit 1
  fi
  tag_name="$(cat $TAG_FILE)"
else
  tag_name="$TAG"
fi

target_arg=""
if [ -n "$TARGET_FILE" ]; then
  if [ ! -f "$TARGET_FILE" ]; then
    echo "target file '$TARGET_FILE' does not exist"
    exit 1
  fi
  target_arg="--target $(cat $TARGET_FILE)"
elif [ -n "$TARGET" ]; then
  target_arg="--target $TARGET"
fi

build_args=""
if [ -n "$BUILD_ARGS_FILE" ]; then
  if [ ! -f "$BUILD_ARGS_FILE" ]; then
    echo "build_args file '$BUILD_ARGS_FILE' does not exist"
    exit 1
  fi

  expanded_build_args=()
  while IFS= read -r line && [ -n "$line" ];
  do
    expanded_build_args+=("--build-arg" "$line")
  done < "$BUILD_ARGS_FILE"
  build_args="${expanded_build_args[@]}"
else
  build_args="$BUILD_ARGS_OPT"
fi

buildkit_arg=""
if [ "$BUILDKIT" = "1" ]; then
  buildkit_arg="--ssh default"
  eval "$(ssh-agent)"
  if (compgen -v | grep -qE 'SSH_KEY_'); then
    for key in $(compgen -v | grep 'SSH_KEY_'); do
      echo "Adding ssh key ${key}"
      eval "ssh-add - <<< \$$key"
    done
  fi
  ssh-add -L
  export DOCKER_BUILDKIT=1
fi


eval "dockerd --experimental --data-root /scratch/state $DOCKERDARGS > $LOG_FILE 2>&1 &"

if [ -n "$USERNAME" ] && [ -n "$PASSWORD" ]; then
  echo "$PASSWORD" | docker login -u "$USERNAME" --password-stdin "$REGISTRY"
fi

eval "docker build $SQUASH $PROGRESS -t $REPOSITORY:$tag_name $buildkit_arg -f $DOCKERFILE $target_arg $build_args $CONTEXT"

if "$SAVE_ARTIFACT"; then
  docker image save "$REPOSITORY:$tag_name" -o image/image.tar
fi

pkill -f dockerd || true
pkill -f ssh || true
