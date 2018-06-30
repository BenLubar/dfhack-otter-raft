#!/bin/bash -e

build_dir="$1"
dbg_dir="$2"

cd "$build_dir"
find . -name '*.pdb' -print0 | cpio -pmd0 "$dbg_dir"
