#!/usr/bin/env bash

set -euo pipefail

# NOTE: This expects to be called from the root of the repo, so consider the
# working directory should be that.

./example.sh

( # Test `prune` in `libdeploy.sh`

  set -euo pipefail

  # shellcheck disable=SC1091
  . templates/libdeploy.sh
  tmp_dir="$(mktemp -d)"; readonly tmp_dir
  cd "${tmp_dir}" || exit 1

  touch un deux trois quatre

  # echo "pre-prune" && ls -lah
  prune '.' 2
  # echo "post-prune" && ls -lah

  # shellcheck disable=SC2012
  # FIXME: Just use bats or something… (https://github.com/bats-core/bats-core)
  [ "$(ls -1 | sort -u)" = "$(echo -e "quatre\ntrois")" ] || (echo 'Zut alors…' && exit 1)
)
