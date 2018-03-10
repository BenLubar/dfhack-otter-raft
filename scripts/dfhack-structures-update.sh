#!/bin/bash -x

cd "$1"
shift
Version="$1"
shift

export RUBYLIB="$RUBYLIB:`pwd`/metasm"

cd df-structures

# XXX
if [[ "$Version" = "0.44.06" ]]; then
    git checkout ee36a1f380054cb4b485230f66bf5598c70fc5ea -- symbols.xml
fi

git remote add BenLubar git@github.com:BenLubar/df-structures.git
git push -f BenLubar master

git branch -D auto-symbols-update || true
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

if false; then
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
fi

perl ./codegen.pl

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

sed -e 's/^/        /' -i win32_globals.xml.tmp
sed -e 's/^/        /' -i win64_globals.xml.tmp
sed -e 's/^/        /' -i linux32_globals.xml.tmp
sed -e 's/^/        /' -i linux64_globals.xml.tmp
sed -e 's/^/        /' -i osx32_globals.xml.tmp
sed -e 's/^/        /' -i osx64_globals.xml.tmp

sed -e 's/^/        /' -i win32_startdwarfcount.xml.tmp
sed -e 's/^/        /' -i win64_startdwarfcount.xml.tmp
sed -e 's/^/        /' -i linux32_startdwarfcount.xml.tmp
sed -e 's/^/        /' -i linux64_startdwarfcount.xml.tmp
sed -e 's/^/        /' -i osx32_startdwarfcount.xml.tmp
sed -e 's/^/        /' -i osx64_startdwarfcount.xml.tmp

sed -e 's/^/        /' -i win32_vtable.xml.tmp
sed -e 's/^/        /' -i win64_vtable.xml.tmp
sed -e 's/^/        /' -i linux32_vtable.xml.tmp
sed -e 's/^/        /' -i linux64_vtable.xml.tmp
sed -e 's/^/        /' -i osx32_vtable.xml.tmp
sed -e 's/^/        /' -i osx64_vtable.xml.tmp

Win32Timestamp="0x`winedump-stable "../win32/Dwarf Fortress.exe" | grep TimeDateStamp | grep -o '[0-9A-F]\{8\}'`"
Win64Timestamp="0x`winedump-stable "../win64/Dwarf Fortress.exe" | grep TimeDateStamp | grep -o '[0-9A-F]\{8\}'`"
Linux32MD5="`md5sum -b "../linux32/libs/Dwarf_Fortress" | cut -d ' ' -f 1`"
Linux64MD5="`md5sum -b "../linux64/libs/Dwarf_Fortress" | cut -d ' ' -f 1`"
OSX32MD5="`md5sum -b "../osx32/dwarfort.exe" | cut -d ' ' -f 1`"
OSX64MD5="`md5sum -b "../osx64/dwarfort.exe" | cut -d ' ' -f 1`"

sed '/<!-- end windows -->/Q' symbols.xml > symbols.xml.tmp
echo >> symbols.xml.tmp
echo "    <symbol-table name='v$Version SDL win32' os-type='windows'>" >> symbols.xml.tmp
echo "        <binary-timestamp value='$Win32Timestamp'/>" >> symbols.xml.tmp
echo >> symbols.xml.tmp
cat win32_startdwarfcount.xml.tmp >> symbols.xml.tmp
cat win32_globals.xml.tmp >> symbols.xml.tmp
echo >> symbols.xml.tmp
cat win32_vtable.xml.tmp >> symbols.xml.tmp
echo >> symbols.xml.tmp
echo "    </symbol-table>" >> symbols.xml.tmp
echo >> symbols.xml.tmp
echo "    <symbol-table name='v$Version SDL win64' os-type='windows'>" >> symbols.xml.tmp
echo "        <binary-timestamp value='$Win64Timestamp'/>" >> symbols.xml.tmp
echo >> symbols.xml.tmp
cat win64_startdwarfcount.xml.tmp >> symbols.xml.tmp
cat win64_globals.xml.tmp >> symbols.xml.tmp
echo >> symbols.xml.tmp
cat win64_vtable.xml.tmp >> symbols.xml.tmp
echo >> symbols.xml.tmp
echo "    </symbol-table>" >> symbols.xml.tmp
echo >> symbols.xml.tmp

sed -n '/<!-- end windows -->/,/<!-- end linux -->/ p' symbols.xml | sed '$d' >> symbols.xml.tmp

echo >> symbols.xml.tmp
echo "    <symbol-table name='v$Version linux32' os-type='linux'>" >> symbols.xml.tmp
echo "        <md5-hash value='$Linux32MD5'/>" >> symbols.xml.tmp
echo >> symbols.xml.tmp
cat linux32_startdwarfcount.xml.tmp >> symbols.xml.tmp
cat linux32_globals.xml.tmp >> symbols.xml.tmp
echo >> symbols.xml.tmp
cat linux32_vtable.xml.tmp >> symbols.xml.tmp
echo >> symbols.xml.tmp
echo "    </symbol-table>" >> symbols.xml.tmp
echo >> symbols.xml.tmp
echo "    <symbol-table name='v$Version linux64' os-type='linux'>" >> symbols.xml.tmp
echo "        <md5-hash value='$Linux64MD5'/>" >> symbols.xml.tmp
echo >> symbols.xml.tmp
cat linux64_startdwarfcount.xml.tmp >> symbols.xml.tmp
cat linux64_globals.xml.tmp >> symbols.xml.tmp
echo >> symbols.xml.tmp
cat linux64_vtable.xml.tmp >> symbols.xml.tmp
echo >> symbols.xml.tmp
echo "    </symbol-table>" >> symbols.xml.tmp
echo >> symbols.xml.tmp

sed -n '/<!-- end linux -->/,/<!-- end osx -->/ p' symbols.xml | sed '$d' >> symbols.xml.tmp

echo >> symbols.xml.tmp
echo "    <symbol-table name='v$Version osx32' os-type='darwin'>" >> symbols.xml.tmp
echo "        <md5-hash value='$OSX32MD5'/>" >> symbols.xml.tmp
echo >> symbols.xml.tmp
cat osx32_startdwarfcount.xml.tmp >> symbols.xml.tmp
cat osx32_globals.xml.tmp >> symbols.xml.tmp
echo >> symbols.xml.tmp
cat osx32_vtable.xml.tmp >> symbols.xml.tmp
echo >> symbols.xml.tmp
echo "    </symbol-table>" >> symbols.xml.tmp
echo >> symbols.xml.tmp
echo "    <symbol-table name='v$Version osx64' os-type='darwin'>" >> symbols.xml.tmp
echo "        <md5-hash value='$OSX64MD5'/>" >> symbols.xml.tmp
echo >> symbols.xml.tmp
cat osx64_startdwarfcount.xml.tmp >> symbols.xml.tmp
cat osx64_globals.xml.tmp >> symbols.xml.tmp
echo >> symbols.xml.tmp
cat osx64_vtable.xml.tmp >> symbols.xml.tmp
echo >> symbols.xml.tmp
echo "    </symbol-table>" >> symbols.xml.tmp
echo >> symbols.xml.tmp

sed -n '/<!-- end osx -->/,$ p' symbols.xml >> symbols.xml.tmp

mv -f symbols.xml.tmp symbols.xml
rm -f *.xml.tmp

perl ./make-keybindings.pl < ../linux64/g_src/keybindings.h > df.keybindings.xml

git add symbols.xml df.keybindings.xml
git commit -m "Automatically generated symbols.xml for DF $Version"

git push -fu BenLubar auto-symbols-update
