$ProgressPreference = 'Ignore'
$ErrorActionPreference = 'Stop'

Import-Module $PSScriptRoot/github.psm1
[System.Environment]::GetEnvironmentVariables()
$token = Get-GitHubInput -Name repo-token
if (!$token) {
    throw "repo-token not specified"
}

# Setup PowerShellForGitHub for use in GitHub Actions
$secureString = $token | ConvertTo-SecureString -AsPlainText -Force
$cred = [System.Management.Automation.PSCredential]::new("username is ignored", $secureString)
Set-GitHubAuthentication -Credential $cred
$repoArgs = $token -split '/'
Set-GitHubConfiguration -DefaultOwnerName $repoArgs[0] -DefaultRepositoryName $repoArgs[1]

$context = Get-GitHubContext
if ($context.payload.action -ne 'opened') {
    Write-Host 'No issue or PR was opened, skipping'
    return
}

# Do nothing if its not a pr or issue
$isIssue = !!$context.payload.issue
if (!$isIssue -and !$context.payload.pull_request) {
    Write-Host 'The event that triggered this action was not a pull request or issue, skipping.'
    return
}

# Do nothing if its not their first contribution
Write-Host 'Checking if its the users first contribution'
if (!$context.payload.sender) {
    throw 'Internal error, no sender provided by GitHub'
}

$creator = $context.payload.sender.login;
$issue = $context.issue;
if ($isIssue) {
    $firstContribution = isFirstIssue -Creator $creator -CurrentIssue $issue.number
} else {
    $firstContribution = isFirstPull -Creator $creator -CurrentPullRequest $issue.number
}

if (!$firstContribution) {
    Write-Host 'Not the users first contribution'
    return
}

$issueType = $isIssue ? 'issue' : 'pull request';

# Add a comment to the appropriate place
Write-Host "Adding message: $message to $issueType $($issue.number)"
if ($isIssue) {
    await client.issues.createComment({
    owner: issue.owner,
    repo: issue.repo,
    issue_number: issue.number,
    body: message
    });

    New-GitHubComment -Issue $issue.number -Body (Get-GitHubInput -Name issue-message)
} else {
    New-GitHubComment -Issue $issue.number -Body (Get-GitHubInput -Name pr-message)
}