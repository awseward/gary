# Tests

Uses [git-test].

Set up local `.git/config` via `./test/_setup.sh`.

For usage info, see: [git-test].

### TODO

Formalize this "watch test" concept a little more:

``sh
g worktree add --detach ../_test-gary HEAD
cd ../_test-gary

while sleep 1
do
  ls ../gary/.git/refs/heads/* | entr -n -p -d -s '
    echo "main..$(echo $0 | xargs basename)" | xargs -t git test run
  '
done
```


[git-test]: https://github.com/mhagger/git-test#git-test
