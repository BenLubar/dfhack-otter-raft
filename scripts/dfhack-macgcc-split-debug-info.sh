#!/bin/bash -e

BaseWorkingDirectory="$1"
shift

split_debug_info()
{
    echo "Splitting debug info from $1"
    docker run --rm -i -v "$BaseWorkingDirectory:$BaseWorkingDirectory" -u $(id -u):$(id -g) -w "$(pwd)" proget.local.lubar.me/dfhack-docker/build-env dsymutil "$1"
    mkdir -p "$2"
    rm -rf "$2/$1.dSYM"
    mv "$1.dSYM" "$2/"
}

pkg_file="$1"
dbg_dir="$2"
tmp_dir="$3"

mkdir -p "$tmp_dir"
echo "Extracting $pkg_file"
tar xf "$pkg_file" -C "$tmp_dir"
echo "Splitting debug info..."
split_debug_info "$tmp_dir/hack/dfhack-run" "$dbg_dir"
split_debug_info "$tmp_dir/hack/binpatch" "$dbg_dir"
find "$tmp_dir" -name '*.dylib' -print0 | while read -d $'\0' lib_name; do
    split_debug_info "$lib_name" "$dbg_dir"
done
echo "Re-packaging $pkg_file"
tar cf "$pkg_file" -C "$tmp_dir" .
