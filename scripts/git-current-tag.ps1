Param($dir, $repo, $branch)

if (Test-Path $dir) {
    git -C $dir pull -q
} else {
    git clone -q -b $branch $repo $dir
}
git -C $dir fetch -q --tags
$commit = git -C $dir log -n 1 --format='%H'
$ErrorActionPreference = 'SilentlyContinue'
$tag = git -C $dir describe --tags --abbrev=0
