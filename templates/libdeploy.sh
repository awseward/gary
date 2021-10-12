#!/usr/bin/env bash

# Format a tarball URL for downloading a repository's source (via GitHub)
#   $1: owner    -- name of the GitHub account which owns the repository
#   $2: repo     -- name of the repository
#   $3: revision -- git refspec to download a tarball of (branchname | SHA)
tarball_url() {
  local -r owner="$1"
  local -r repo="$2"
  local -r revision="$3"

  echo "https://github.com/${owner}/${repo}/tarball/${revision}"
}

# DISCLAIMER: This is probably not super duper robust, and could use work
# Keep the newest entries around; prune everything older than that.
#   $1: prune_dir  -- path to the directory whose contents are to be pruned
#   $2: prune_keep -- how many to keep
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
      | tail -n "+${prune_start_offset}" \
      | xargs rm -rf
  )
}

# DISCLAIMER: This is probably not super duper robust, and could use work
# Ensure that a file has no permissions set for any user other than the owner.
#   $1: fpath -- path of the file to check
_check_fmode() {
  fpath="${1:?}"
  fmode="$(stat -L "${fpath}" | awk '{ print $3 }')"

  [ "${fmode: -6}" = '------' ] || return 1
}

check_fmode() {
  fpath="${1:?}"

  _check_fmode "${fpath}" || (
    echo "File mode on '${fpath}' must be _00! (i.e. not accessible by group or other)"
    exit 1
  )
}
