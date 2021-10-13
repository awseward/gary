#!/usr/bin/env bash

set -euo pipefail

# USAGE:
#
# deploy.sh <revision>
#           some-branch # branch name
#           4d7ad62c29b # commit SHA
#

# shellcheck disable=SC1091
# # Tried this, but syntastic doesn't seem to like it:
# # shellcheck source=libdeploy.sh
. "/usr/local/lib/gary/libdeploy.sh"

check_fmode "${HOME}/app_env.sh"

# === BEGIN parameterization ===

revision="${1:?}"
# shellcheck disable=SC1091
. "${HOME}/deploy_vars.sh"

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
