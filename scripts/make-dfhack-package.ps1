Param($key, $applicationName, $releaseNumber, $variables)

$body = @{
    key = $key
    applicationName = $applicationName
    releaseNumber = $releaseNumber
} + $variables

$package = Invoke-RestMethod -Method Post -Uri https://buildmaster.local.lubar.me/api/releases/packages/create -Body $body

$body = @{
    key = $key
    packageId = $package.id
}

Invoke-RestMethod -Method Post -Uri https://buildmaster.local.lubar.me/api/releases/packages/deploy -Body $body
