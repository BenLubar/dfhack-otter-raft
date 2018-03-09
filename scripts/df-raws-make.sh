#!/bin/bash -e

go get -u github.com/BenLubar/df2014/cmd/dipscript

DF() {
    version=${1//\./_}
    version=${version#0_}
    name=../df_${version}_linux.tar.bz2
    if [[ -f "$name" ]]; then
        rm -rf -- *
        tar xf "$name" df_linux/raw df_linux/data/{announcement,dipscript,help,init,speech} df_linux/data/index
    else
        echo "(cannot make raws for $1 - no archive)" >&2
        return 1
    fi
    mv df_linux/raw/* df_linux/data/* .
    rmdir df_linux/raw df_linux/data df_linux
    chmod -x+X -R -- *
    dipscript_opts=
    dipscript_opts_index=-i
    case "${version:0:3}" in
        2[1-3]_)
                dipscript_opts=-w
                dipscript_opts_index=-w
                ;;
        2[7-8]_)
                dipscript_opts=-o
                dipscript_opts_index="-o -i"

                # fix 23a encoded file in 40d
                if [[ -f announcement/end1 ]]; then
                        dipscript -d -w < announcement/end1 | dipscript -e -o > announcement/end1.tmp && mv -f announcement/end1.tmp announcement/end1
                fi
                ;;
    esac
    find ./*/ -name '*.txt' -print0 | xargs -0 -n1 bash -ec "sed -e 's/\r//' \"\$@\" | iconv -f cp437 -t utf-8 > \"\$@.tmp\" && mv -f \"\$@.tmp\" \"\$@\"" _
    dipscript -d -l $dipscript_opts_index < index > index.tmp && mv -f index.tmp index
    find ./*/ -type f -name '*' -not -name '*.*' -print0 | xargs -0 -n1 bash -ec "dipscript -d -l $dipscript_opts < \"\$@\" > \"\$@.tmp\" && mv -f \"\$@.tmp\" \"\$@\"" _
    find ./*/ -iname 'Thumbs.db' -delete
    git add --all .
    git commit --allow-empty --date="$2"T00:00:00Z --author="Toady One <toadyone@bay12games.com>" -m "DF $1"
    git tag "v$1"
}

DF "$1" "$2"
