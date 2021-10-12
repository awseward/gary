#!/usr/bin/env bats

setup() {
  # shellcheck disable=SC1091
  . templates/libdeploy.sh
}

@test 'prune works correctly' {
  tmp_dir="$(mktemp -d)"; readonly tmp_dir
  cd "${tmp_dir}" || return 1

  touch un deux trois quatre

  echo "===> pre-prune" && tree
  prune '.' 2
  echo "===> post-prune" && tree

  # shellcheck disable=SC2012
  [ "$(ls -1 | sort -u)" = "$(echo -e "quatre\ntrois")" ]
}

@test 'check_fmode accepts 700' {
  tmp_dir="$(mktemp -d)"; readonly tmp_dir
  cd "${tmp_dir}" || return 1

  touch test_700 && chmod 700 test_700
  set +e # Hmmm… 🤔
  check_fmode test_700
  [ $? = 0 ]
}

@test 'check_fmode rejects 777' {
  tmp_dir="$(mktemp -d)"; readonly tmp_dir
  cd "${tmp_dir}" || return 1

  touch test_777 && chmod 777 test_777
  set +e # Hmmm… 🤔
  check_fmode test_777
  [ $? != 0 ]
}
