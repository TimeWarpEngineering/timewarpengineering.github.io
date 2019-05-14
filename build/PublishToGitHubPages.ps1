# Display inputs.
Write-Host "DocPath:$env:DocPath"
Write-Host "GitHubUsername:$env:GitHubUsername"
Write-Host "RepositoryName:$env:RepositoryName"
Write-Host "CommitMessage:$env:CommitMessage" 
Write-Host "GitHubEmailSecret:$env:GitHubEmail"
Write-Host "GitHubAccessTokenSecret:$env:GitHubAccessTokenSecret"
Write-Host "DefaultWorkingDirectory:$env:System_DefaultWorkingDirectory" 

$repoUrl = "https://$env:GitHubUsername`:$env:GitHubAccessTokenSecret@github.com/$env:GitHubUsername/$env:RepositoryName.git"

Write-Host "Cloning existing master branch"

git clone  $repoUrl --branch=master $env:System_DefaultWorkingDirectory\master --quiet

if ($lastexitcode -gt 0)
{
    Write-Host "##vso[task.logissue type=error;]Unable to clone repository - check username, access token and repository name. Error code $lastexitcode"
    [Environment]::Exit(1)
}

$to = "$env:System_DefaultWorkingDirectory\master"

Write-Host "Copying new documentation into branch"

Copy-Item $env:DocPath $to -recurse -Force

cd $env:System_DefaultWorkingDirectory\master
Write-Host "config git"
git config core.autocrlf false
git config user.email $env:GitHubEmail
git config user.name $env:GitHubUsername
git config --list

Write-Host "git add *"
git add *

Write-Host "Committing the master branch"
Write-Host "git commit -m $env:CommitMessage"
git commit -m $env:CommitMessage

if ($lastexitcode -gt 0)
{
    Write-Host "##vso[task.logissue type=error;]Error committing - see earlier log, error code $lastexitcode"
    [Environment]::Exit(1)
}

Write-Host "git push the master branch"

git push --quiet


if ($lastexitcode -gt 0)
{
    Write-Host "##vso[task.logissue type=error;]Error pushing to master branch, probably an incorrect Personal Access Token, error code $lastexitcode"
    [Environment]::Exit(1)
}
