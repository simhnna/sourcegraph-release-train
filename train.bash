#!/bin/bash

set -xe

cd "$(git rev-parse --show-toplevel)"

[ -n "$docker_username" ]
[ -n "$docker_password" ]

docker login --username "$docker_username" --password "$docker_password"

tag="$(cat .latest_version)"

# curl "https://hub.docker.com/v2/repositories/${docker_username}/${docker_repo}/tags" -o /tmp/docker_tags.json

# if jq -r '.results[] | .name' /tmp/docker_tags.json | grep -E "^${tag}$"; then
#   echo "======================================
# =  Tag '$tag' already in docker hub  =
# ======================================"
#   exit 0
# fi

export IMAGE="simhnna/sourcegraph"
export VERSION="$tag"

cd sourcegraph

git fetch origin refs/tags/v$tag:refs/tags/v$tag
git checkout "tags/v$tag" -b "$tag-release-branch-simhnna"

if [ 'Linux' == "$(uname -s)" ]; then
  sudo apt-get install musl-tools
fi
git apply ../patches/*

cd cmd/server
./pre-build.sh
./build.sh

docker tag "${IMAGE}:latest" "${IMAGE}:${tag}"

docker push "${IMAGE}:${tag}"

echo '===========
=  Done!  =
==========='
