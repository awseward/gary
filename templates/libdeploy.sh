#!/usr/bin/env bash

tarball_url() {
  local -r owner="$1"
  local -r repo="$2"
  local -r revision="$3"

  echo "https://github.com/${owner}/${repo}/tarball/${revision}"
}

# Keep the newest entries around; prune everything older than that.
#   $1: $prune_dir  -- path to the directory whose contents are to be pruned
#   $2: $prune_keep -- how many to keep
prune() {
  local -r prune_dir="${1:?}"
  local -r prune_keep="${2:-3}"
  local -r prune_start_offset=$(( prune_keep + 1 ))

  (
    cd "${prune_dir}" || exit 1
    pwd
    # shellcheck disable=SC2010
    #   see: https://github.com/koalaman/shellcheck/issues/1086
    ls -1 -a -t | grep -v '^[.]\{1,2\}$' \
      | tail -n +${prune_start_offset} \
      | xargs rm -rf
  )
}

