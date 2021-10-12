# Tests

Uses [git-test].

Set up local `.git/config` via `./test/_setup.sh`.

For usage info, see: [git-test].

### TODO

Formalize this "watch test" concept a little more:

```sh
worktree_relpath="../_test-$(pwd | xargs basename)"

# FIXME: This `|| true` is a bit questionable…
g worktree add --detach "${worktree_relpath}" HEAD || true
cd "${worktree_relpath}" || return 1

src_gitdir="$(
  cat .git | awk '{ print $2 }' | xargs dirname | xargs dirname
)"

while sleep 1
do
  ls "${src_gitdir}"/refs/heads/* | entr -n -d -s '
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
```


[git-test]: https://github.com/mhagger/git-test#git-test
