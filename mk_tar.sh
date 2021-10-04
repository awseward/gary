#!/usr/bin/env bash

set -euo pipefail

readonly dhall_filepath="${1:?}"
readonly tar_filename="${2:?}"

dhall to-directory-tree --output _ <<< "${dhall_filepath}"

cd _ && tar -cvf "../${tar_filename}" ./**/*
