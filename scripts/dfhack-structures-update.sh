#!/bin/bash

exec 2>&1
set -ex

cd "$1"
shift

export RUBYLIB="$RUBYLIB:`pwd`/metasm"

git clone git@github.com:BenLubar/df-structures.git df-structures

cd df-structures

git remote add upstream https://github.com/DFHack/df-structures.git
git checkout master
git fetch upstream
git reset --hard upstream/master
git push -fu origin master

git branch -D auto-symbols-update
git checkout -b auto-symbols-update

ruby ../df_misc/dump_df_globals.rb "../win32/Dwarf Fortress.exe" > win32_globals.xml.tmp
ruby ../df_misc/dump_df_globals.rb "../win64/Dwarf Fortress.exe" > win64_globals.xml.tmp
ruby ../df_misc/dump_df_globals.rb "../linux32/libs/Dwarf_Fortress" > linux32_globals.xml.tmp
ruby ../df_misc/dump_df_globals.rb "../linux64/libs/Dwarf_Fortress" > linux64_globals.xml.tmp
ruby ../df_misc/dump_df_globals.rb "../osx32/dwarfort.exe" > osx32_globals.xml.tmp
ruby ../df_misc/dump_df_globals.rb "../osx64/dwarfort.exe" > osx64_globals.xml.tmp

ruby ../df_misc/scan_vtable.rb "../win32/Dwarf Fortress.exe" > win32_vtable.xml.tmp
ruby ../df_misc/scan_vtable.rb "../win64/Dwarf Fortress.exe" > win64_vtable.xml.tmp
ruby ../df_misc/scan_vtable.rb "../linux32/libs/Dwarf_Fortress" > linux32_vtable.xml.tmp
ruby ../df_misc/scan_vtable.rb "../linux64/libs/Dwarf_Fortress" > linux64_vtable.xml.tmp
ruby ../df_misc/scan_vtable.rb "../osx32/dwarfort.exe" > osx32_vtable.xml.tmp
ruby ../df_misc/scan_vtable.rb "../osx64/dwarfort.exe" > osx64_vtable.xml.tmp

ruby ../df_misc/scan_ctors.rb "../win32/Dwarf Fortress.exe" > win32_ctors.xml.tmp || true
ruby ../df_misc/scan_ctors.rb "../win64/Dwarf Fortress.exe" > win64_ctors.xml.tmp || true
ruby ../df_misc/scan_ctors.rb "../linux32/libs/Dwarf_Fortress" > linux32_ctors.xml.tmp || true
ruby ../df_misc/scan_ctors.rb "../linux64/libs/Dwarf_Fortress" > linux64_ctors.xml.tmp || true
ruby ../df_misc/scan_ctors_osx.rb "../osx32/dwarfort.exe" > osx32_ctors.xml.tmp || true
ruby ../df_misc/scan_ctors_osx.rb "../osx64/dwarfort.exe" > osx64_ctors.xml.tmp || true

ruby ../df_misc/scan_keydisplay.rb "../win32/Dwarf Fortress.exe" > win32_keydisplay.xml.tmp
ruby ../df_misc/scan_keydisplay.rb "../win64/Dwarf Fortress.exe" > win64_keydisplay.xml.tmp
ruby ../df_misc/scan_keydisplay.rb "../osx32/dwarfort.exe" > osx32_keydisplay.xml.tmp
ruby ../df_misc/scan_keydisplay.rb "../osx64/dwarfort.exe" > osx64_keydisplay.xml.tmp

perl codegen.pl

sizeunit_win32="`perl ../df_misc/get_sizeofunit.pl codegen/codegen.out.xml windows 32`"
sizeunit_win64="`perl ../df_misc/get_sizeofunit.pl codegen/codegen.out.xml windows 64`"
sizeunit_linux32="`perl ../df_misc/get_sizeofunit.pl codegen/codegen.out.xml linux 32`"
sizeunit_linux64="`perl ../df_misc/get_sizeofunit.pl codegen/codegen.out.xml linux 64`"

ruby ../df_misc/scan_startdwarfcount.rb "../win32/Dwarf Fortress.exe" "$sizeunit_win32" > win32_startdwarfcount.xml.tmp
ruby ../df_misc/scan_startdwarfcount.rb "../win64/Dwarf Fortress.exe" "$sizeunit_win64" > win64_startdwarfcount.xml.tmp
ruby ../df_misc/scan_startdwarfcount.rb "../linux32/libs/Dwarf_Fortress" "$sizeunit_linux32" > linux32_startdwarfcount.xml.tmp
ruby ../df_misc/scan_startdwarfcount.rb "../linux64/libs/Dwarf_Fortress" "$sizeunit_linux64" > linux64_startdwarfcount.xml.tmp
ruby ../df_misc/scan_startdwarfcount.rb "../osx32/dwarfort.exe" "$sizeunit_linux32" > osx32_startdwarfcount.xml.tmp
ruby ../df_misc/scan_startdwarfcount.rb "../osx64/dwarfort.exe" "$sizeunit_linux64" > osx64_startdwarfcount.xml.tmp

rm -rf codegen
