#!/usr/bin/env bash

set -euo pipefail

# NOTE: This expects to be called from the root of the repo, so consider the
# working directory should be that.

./example.sh

echo '==='

dhall to-directory-tree --output test/libdeploy/ <<< ./test/libdeploy/check_fmode.bats.dhall

bats -T -r test/
