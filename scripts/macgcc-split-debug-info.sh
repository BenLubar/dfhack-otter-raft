#!/bin/bash -e

BaseWorkingDirectory="$1"
shift

echo "Splitting debug info from $1"
docker run --rm -i -v "$BaseWorkingDirectory:$BaseWorkingDirectory" -u $(id -u):$(id -g) -w "$(pwd)" proget.local.lubar.me/dfhack-docker/build-env dsymutil "$1"
mkdir -p "$2"
rm -rf "$2/$1.dSYM"
mv "$1.dSYM" "$2/"
