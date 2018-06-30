param($build_dir, $dbg_dir)

Set-Location $build_dir
$build_dir_len = (Get-Item .).FullName.Length
Get-ChildItem '**/RelWithDebInfo/*.pdb' | ForEach-Object {
    $dest_dir = $_.Directory.Parent.FullName.Substring($build_dir_len);
    Write-Output ('Copying PDB file ' + $dest_dir + '/' + $_.Name)
    if ($dest_dir -eq '\library') {
        $dest_dir = $dbg_dir
    } else {
        $dest_dir = $dbg_dir + '/' + $dest_dir
    }
    New-Item -ItemType Directory -Path $dest_dir -Force
    Copy-Item $_.FullName ($dest_dir + '/' + $_.Name)
}
