#!/bin/bash -e

dbg_src="$1"
build_id="`readelf -n "$dbg_src" | grep 'Build ID: .*' | grep -o '[0-9a-f]\{40\}'`"
dbg_dest="$2/.build-id/${build_id:0:2}/${build_id:2}.debug"
echo "Splitting $dbg_src (build ID $build_id)"
mkdir -p "`dirname "$dbg_dest"`"
objcopy --only-keep-debug "$dbg_src" "$dbg_dest"
strip -g "$dbg_src"
