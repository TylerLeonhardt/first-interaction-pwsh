$ProgressPreference = 'Ignore'
$ErrorActionPreference = 'Stop'

Import-Module $PSScriptRoot/github.psm1

$token = Get-GitHubActionInput -Name repo-token
if (!$token) {
    throw "repo-token not specified"
}

# Setup PowerShellForGitHub for use in GitHub Actions.
$secureString = $token | ConvertTo-SecureString -AsPlainText -Force
$cred = [System.Management.Automation.PSCredential]::new("username is ignored", $secureString)
Set-GitHubAuthentication -Credential $cred
$repoArgs = $env:GITHUB_REPOSITORY -split '/'
Set-GitHubConfiguration -DefaultOwnerName $repoArgs[0] -DefaultRepositoryName $repoArgs[1]

# Check to make sure they configued at least one message.
$issueMessage = Get-GitHubActionInput -Name issue-message
$prMessage = Get-GitHubActionInput -Name pr-message
if (!$issueMessage -and !$prMessage) {
    throw "Action must have at least one of issue-message or pr-message set."
}

$context = Get-GitHubActionContext
if ($context.payload.action -ne 'opened') {
    Write-Host 'No issue or PR was opened, skipping'
    return
}

# Do nothing if its not a pr or issue.
$isIssue = !!$context.payload.issue
if (!$isIssue -and !$context.payload.pull_request) {
    Write-Host "The event that triggered this action was not a pull request or issue, skipping."
    return
}

# Do nothing if its not their first contribution.
Write-Host "Checking if its the users first contribution"
if (!$context.payload.sender) {
    throw "Internal error, no sender provided by GitHub"
}

$creator = $context.payload.sender.login;
$issue = $context.payload.issue;
if ($isIssue) {
    $issueType = "issue"
    if (!$issueMessage) {
        Write-Host "Skipping. No message configured for type: $issueType"
    }
    $firstContribution = isFirstIssue -Creator $creator -CurrentIssue $issue.number
    $commentMessage = $issueMessage
} else {
    $issueType = "pull request"
    if (!$prMessage) {
        Write-Host "Skipping. No message configured for type: $issueType"
    }
    $firstContribution = isFirstPull -Creator $creator -CurrentPullRequest $issue.number
    $commentMessage = $prMessage
}

if (!$firstContribution) {
    Write-Host "Not the users first contribution"
    return
}

# Add a comment to the appropriate place
Write-Host "Adding message: $commentMessage to $issueType $($issue.number)"
$comment = New-GitHubComment -Issue $issue.number -Body $commentMessage
Write-Host -ForegroundColor Green "Done! Comment can be found here: $($comment.html_url)"
