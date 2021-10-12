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

  touch foo
  touch bar
  touch baz

  prune '.' 2 && ls -lah
)
