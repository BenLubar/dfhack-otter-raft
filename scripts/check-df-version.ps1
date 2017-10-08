Param($lastETag, $lastModified)

if ($lastModified -eq '') {
	$lastModified = [DateTime]::MinValue
}

$req = $null
$etag = $lastETag
$modified = $lastModified
$version = ''
$date = ''
$versions = @()

try {
	$req = Invoke-WebRequest http://bay12games.com/dwarves/older_versions.html -Headers @{"If-None-Match" = $lastETag; "If-Modified-Since" = $lastModified}
} catch {
	$req = $_.Exception.Response
}

if ($req.StatusCode -eq 'NotModified') {
	return
}

$etag = $req.Headers['ETag']
$modified = $req.Headers['Last-Modified']

$latestVersion = ($req.ParsedHtml.getElementsByTagName("p") | where className -eq 'menu')[0]

if ($latestVersion.firstChild.textContent -match '^DF ([0-9]+\.[0-9]+\.[0-9]+) \(([A-Z][a-z]+ [1-9][0-9]?, [2-9][0-9]{3,})\)$') {
	$version = $matches[1];
	$date = [DateTime]::Parse($matches[2]).ToShortDateString()
} else {
	Write-Error 'Could not parse version header: ' + latestVersion.firstChild.textContent;
}

$versions = $latestVersion.getElementsByTagName('a') | where innerText -ne 'Small' | where innerText -ne 'Legacy Windows'

foreach ($v in $versions) {
	Invoke-WebRequest ('http://bay12games.com/dwarves/' + $v.pathname) -OutFile $v.pathname
}
