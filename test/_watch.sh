#!/usr/bin/env bash

set -euo pipefail

# NOTE: This assumes you're calling it from the repo root; weird things will
# probably happen if that's not the case.
#
# ---

worktree_relpath="../_test-$(pwd | xargs basename)"

# FIXME: This `|| true` is a bit questionable…
git worktree add --detach "${worktree_relpath}" HEAD || true

(
  cd "${worktree_relpath}" || exit 1

  get_src_workdir() {
    awk '{ print $2 }' | xargs dirname | xargs dirname
  }

  src_gitdir="$(get_src_workdir < .git)"

  while sleep 1
  do
    # shellcheck disable=SC2016
    find "${src_gitdir}"/refs/heads/* -type f | entr -n -d -s '
      set -euo pipefail

      default_branch="$(git symbolic-ref refs/remotes/origin/HEAD | xargs basename)"
      touched_ref="$(echo $0 | xargs basename)"

      if [ "${default_branch}" = "${touched_ref}" ]; then
        testspec="${touched_ref}"
      else
        testspec="${default_branch}..${touched_ref}"
      fi

      echo "${testspec}" | xargs -t git test run
    '
  done
)
