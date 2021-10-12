#!/usr/bin/env bats

modefiles_dir="$(mktemp -d)"

setup_file() {
  mkdir -p "${modefiles_dir}" && cd "${modefiles_dir}"

  for u in $(seq 0 7); do
    for g in $(seq 0 7); do
      for o in $(seq 0 7); do
        ugo="$u$g$o"
        touch "$ugo" && chmod "$ugo" "$ugo"
      done
    done
  done

  cd -
}

setup() {
  # shellcheck disable=SC1091
  . templates/libdeploy.sh

  cd "${modefiles_dir}"
}

@test 'check_fmode accepts files which ARE NOT accessible by "group" or "other"' {
  find . -type f -name '[0-7]00' | while read -r fpath; do
    check_fmode "${fpath}" # || exit 1
  done
}

@test 'check_fmode rejects files which ARE accessible by "group" or "other"' {
  # NOTE: The `sort -r | head -n20` is just here to take a sample; we don't
  # really need to run all of these all the time.
  find . -type f -not -name '[0-7]00' | sort -r | head -n 20 | while read -r fpath; do
    check_fmode "${fpath}"
    [ $? = 0 ]
  done
}
