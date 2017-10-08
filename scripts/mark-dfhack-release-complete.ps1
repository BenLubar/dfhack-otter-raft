Param($key, $applicationName, $releaseNumber)

$body = @{
    key = $key
    applicationName = $applicationName
    releaseNumber = $releaseNumber
}

$releases = Invoke-RestMethod -Method Get -Uri https://buildmaster.local.lubar.me/api/releases -Body $body

$body = @{
    key = $key
    packageId = $releases[0].latestPackageId
    toStage = "Deployed"
    force = "true"
}

Invoke-RestMethod -Method Post -Uri https://buildmaster.local.lubar.me/api/releases/packages/deploy -Body $body
