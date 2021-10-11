#!/usr/bin/env bash

set -euo pipefail

# USAGE:
#
# deploy.sh <revision>
#           some-branch # branch name
#           4d7ad62c29b # commit SHA
#

deploy_script_dir="$(readlink -f "$0" | xargs dirname)"; readonly deploy_script_dir

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

# === BEGIN parameterization ===

revision="${1:?}"
# shellcheck disable=SC1091
. "${deploy_script_dir}/deploy_vars.sh"

echo "owner:       ${owner:?}"
echo "repo:        ${repo:?}"
echo "revision:    ${revision:?}"
echo "app_name:    ${app_name:?}"
echo "daemon_name: ${daemon_name:?}"

# === END parameterization ===

deploy_name="${app_name}-$(date +'%Y%m%d%H%M%S')"

cache_basedir="${HOME}/.cache/deploy/${app_name}"
data_basedir="${HOME}/.local/share/deploy/${app_name}"
download_dir="${cache_basedir}/${deploy_name}"

mkdir -p "${download_dir}" "${data_basedir}"

cd "${download_dir}"
wget "$(tarball_url "${owner}" "${repo}" "${revision}")"
extracted_dir="$(tar -zxvf "${revision}" | head -n1)"

link_source_dirpath="${data_basedir}/${deploy_name}"
link_target_dirpath="${HOME}/${app_name}"

mv "${extracted_dir}" "${link_source_dirpath}"

cd "${link_source_dirpath}"
xargs -t rm -rvf < .slugignore

# === BEGIN app-specific setup ===
.gary/on_deploy
# === END app-specific setup ===

# I've found if you don't delete this first, it tends to start doing weird
# things. Maybe I'm just using `ln` wrong, but this works, so 🤷.
rm -rf "${link_target_dirpath}" || true
ln -f -s "${link_source_dirpath}" "${link_target_dirpath}"

doas rcctl restart "${daemon_name}"

prune "${cache_basedir}"
prune "${data_basedir}"
