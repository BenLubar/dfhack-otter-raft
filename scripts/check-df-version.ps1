Param($workingDirectory, $lastETag, $lastModified, [ref]$etag, [ref]$modified, [ref]$version, [ref]$date, [ref]$versions)

cd $workingDirectory

if ($lastModified -eq '') {
	$lastModified = [DateTime]::MinValue
}

@{'If-None-Match' = $lastETag; 'If-Modified-Since' = $lastModified} | Export-Clixml input.xml

powershell -version 5 -command '& {
	$input = Import-Clixml input.xml

	$output = @{
		''etag'' = $input[''If-None-Match'']
		''modified'' = $input[''If-Modified-Since'']
		''version'' = ''''
		''date'' = ''''
		''versions'' = @()
	}

	try {
		$req = Invoke-WebRequest http://bay12games.com/dwarves/older_versions.html -UseBasicParsing -Headers $input
	} catch [Net.WebException] {
		$req = $_.Exception.Response
	}

	if ($req.StatusCode -eq ''NotModified'') {
		$output | Export-Clixml output.xml
		exit
	}

	$output[''etag''] = $req.Headers[''ETag'']
	$output[''modified''] = $req.Headers[''Last-Modified'']

	$parsedHtml = New-Object -Com ''HTMLFile''
	$parsedHtml.IHTMLDocument2_write($req.Content)

	$latestVersion = ($parsedHtml.getElementsByTagName(''p'') | where className -eq ''menu'')[0]

	if ($latestVersion.firstChild.textContent -match ''^DF ([0-9]+\.[0-9]+\.[0-9]+) \(([A-Z][a-z]+ [1-9][0-9]?, [2-9][0-9]{3,})\)$'') {
		$output[''version''] = $matches[1];
		$output[''date''] = [DateTime]::Parse($matches[2]).ToString(''yyyy-MM-dd'')
	} else {
		Write-Error ''Could not parse version header: '' + latestVersion.firstChild.textContent;
	}

	$output[''versions''] = $latestVersion.getElementsByTagName(''a'') | where innerText -ne ''Small'' | where innerText -ne ''Legacy Windows'' | foreach-object pathname

	foreach ($v in $output[''versions'']) {
		Invoke-WebRequest (''http://bay12games.com/dwarves/'' + $v) -UseBasicParsing -OutFile $v
	}

	$output | Export-Clixml output.xml
	exit
}'

$output = Import-Clixml output.xml

$etag = $output['etag']
$modified = $output['modified']
$version = $output['version']
$date = $output['date']
$versions = (ConvertTo-Json $output['versions'])
