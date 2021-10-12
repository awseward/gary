#!/usr/bin/env bash

set -euo pipefail

# NOTE: This expects to be called from the root of the repo, so consider the
# working directory should be that.

./mk_tar.sh './hosts/vultr-obsd.dhall' 'test.tar.gz'

echo '==='

# shellcheck disable=SC2038
find . -type f -name '*sh' -not -path './_/*' | xargs -t shellcheck -o all --

echo '==='

echo 'Starting BATS tests (https://github.com/bats-core/bats-core)…'
bats -r -T test/
