$ProgressPreference = 'Ignore'

if (!$env:GITHUB_TOKEN) {
    throw "Environment variable for GITHUB_TOKEN not found"
}

# Setup PowerShellForGitHub for use in GitHub Actions
$secureString = $env:GITHUB_TOKEN | ConvertTo-SecureString -AsPlainText -Force
$cred = [System.Management.Automation.PSCredential]::new("username is ignored", $secureString)
Set-GitHubAuthentication -Credential $cred
$repoArgs = $env:GITHUB_REPOSITORY -split '/'
Set-GitHubConfiguration -DefaultOwnerName $repoArgs[0] -DefaultRepositoryName $repoArgs[1]

# Put custom code after here
Get-GitHubPullRequest | Select-Object title,number,html_url
