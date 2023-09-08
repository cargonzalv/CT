#!/usr/bin/env bash
set -o errexit \
    -o pipefail

if [[ -n ${DEBUG} ]]; then
  set -o xtrace \
      -o verbose
fi

cd 'source'

if [[ "${IS_RELEASE}" = 'true' ]]; then
  # We don't "DO_PUBLISH" for releases because we want Concourse
  # to track versions.
  DO_PUBLISH=""
  if grep -qiF 'snapshot' version.sbt; then
    # The commit should be release, but is a snapshot is detected.
    # This should not be permitted.
    echo "The artifact version you're trying to release is $(cat version.sbt)"
    echo 'You cannot tag a snapshot as a release.'
    echo 'Do the needful.'
    exit 1
  fi
else
  DO_PUBLISH="publish"
  if grep -qiF 'snapshot' version.sbt; then
    # The commit is not a release and is a valid snapshot version.
    # Everything's cool.
    true
  else
    # The commit is not a release, but bears a non-snapshot version.
    # This is not cool.
    echo "The artifact version you're trying to release is $(cat version.sbt)"
    echo 'Only snapshots are allowed on branch builds.'
    echo 'Do the needful.'
    exit 1
  fi
fi

TASKS="${${TASKS}:-clean compile test package}"
read -ra _TASKS <<< "${TASKS}"

sbt ${_TASKS[@]} "${DO_PUBLISH}" < /dev/null

if [[ "${IS_RELEASE}" = 'true' ]]; then
  printf "\n\n=== COPYING ARTIFACTS TO ARTIFACT VOLUME ===\n\n"
  FILES="$(find distribution/target -maxdepth 1 -type f | grep -E "(gz|jar|pom)$")"
  for ff in ${FILES}; do
    cp -v "${ff}" ../artifact/.
  done

  printf "\nDetected version: "
  sed '/.*\"\(.*\)\".*/ s//\1/g' < version.sbt | tee ../version/version
fi
