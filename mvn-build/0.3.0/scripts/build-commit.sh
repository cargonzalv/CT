#!/usr/bin/env bash
set -o errexit \
    -o pipefail

if [[ -n ${DEBUG} ]]; then
  set -o xtrace \
      -o verbose
fi

cd 'source'
VERSION="$(xpath -q -e '/project/version/text()' pom.xml)"

if [[ "${MVN_DEPLOY}" = "true" ]]; then
  DO_DEPLOY="deploy"
fi

if [[ "${IS_RELEASE}" = "true" && "${MVN_DEPLOY}" = "true" ]]; then
  # This catches builds meant to be snapshots, but bearing a release version.
  if grep -qiF 'snapshot' <<< "${VERSION}"; then
    echo "The artifact version you're trying to release is ${VERSION}"
    echo 'You cannot tag a snapshot as a release.'
    exit 1
  fi
elif [[ "${IS_RELEASE}" = "false" && "${MVN_DEPLOY}" = "true" ]]; then
  # This catches builds meant to be snapshots, but bearing a non-snapshot version.
  if ! grep -qiF 'snapshot' <<< "${VERSION}"; then
    echo "The artifact version you're trying to release is ${VERSION}"
    echo 'Only snapshots are allowed on branch builds.'
    exit 1
  fi
fi

read -ra _TASKS <<< "${TASKS}"

mvn ${_TASKS[@]} ${DO_DEPLOY} < /dev/null

if [[ "${EXPORT_VOLUMES}" = 'true' ]]; then
  printf "\n\n=== COPYING ARTIFACTS TO ARTIFACT VOLUME ===\n\n"
  FILES="$(find target -maxdepth 1 -type f | grep -E "(gz|jar|pom)$")"
  for ff in ${FILES}; do
    cp -v "${ff}" ../artifact/.
  done

  printf "\nDetected version: "
  echo "${VERSION}" | tee ../version/version
  if [[ ${VERSION_IN_ARTIFACT} = "true" ]]; then
    cp -v ../version/version ../artifact/.
  fi
fi
