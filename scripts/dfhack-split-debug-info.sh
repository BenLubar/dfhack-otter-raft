#!/bin/bash -e

split_debug_info()
{
    dbg_src="$1"
    build_id="`readelf -n "$dbg_src" | grep 'Build ID: .*' | grep -o '[0-9a-f]\{40\}'`"
    dbg_dest="$2/.build-id/${build_id:0:2}/${build_id:2}.debug"
    echo "Splitting $dbg_src (build ID $build_id)"
    mkdir -p "`dirname "$dbg_dest"`"
    objcopy --only-keep-debug "$dbg_src" "$dbg_dest"
    strip -g "$dbg_src"
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
find "$tmp_dir" -name '*.so' -print0 | while read -d $'\0' lib_name; do
    split_debug_info "$lib_name" "$dbg_dir"
done
echo "Re-packaging $pkg_file"
tar cf "$pkg_file" -C "$tmp_dir" .
