$ProgressPreference = 'Ignore'
$ErrorActionPreference = 'Stop'

# Setup PowerShellForGitHub for use in GitHub Actions.
$secureString = Get-ActionInput -Name repo-token -Required | ConvertTo-SecureString -AsPlainText -Force
Set-GitHubAuthentication -Credential ([System.Management.Automation.PSCredential]::new("username is ignored", $secureString))
$repo = Get-ActionRepo
Set-GitHubConfiguration -DefaultOwnerName $repo.Owner -DefaultRepositoryName $repo.Repo

# Import helper module used later.
Import-Module $PSScriptRoot/helper.psm1

# Check to make sure they configued at least one message.
$issueMessage = Get-ActionInput -Name issue-message
$prMessage = Get-ActionInput -Name pr-message
if (!$issueMessage -and !$prMessage) {
    throw "Action must have at least one of issue-message or pr-message set."
}

$context = Get-ActionContext
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

$creator = $context.payload.sender.login
$issueOrPrNumber = Get-ActionIssue | Select-Object -ExpandProperty Number
if ($isIssue) {
    $issueType = "issue"
    if (!$issueMessage) {
        Write-Host "Skipping. No message configured for type: $issueType"
    }
    $firstContribution = isFirstIssue -Creator $creator -CurrentIssue $issueOrPrNumber
    $commentMessage = $issueMessage
} else {
    $issueType = "pull request"
    if (!$prMessage) {
        Write-Host "Skipping. No message configured for type: $issueType"
    }
    $firstContribution = isFirstPull -Creator $creator -CurrentPullRequest $issueOrPrNumber
    $commentMessage = $prMessage
}

if (!$firstContribution) {
    Write-Host "Not the users first contribution"
    return
}

# Add a comment to the appropriate place
Write-Host "Adding message: $commentMessage to $issueType $($issueOrPrNumber)"
$comment = New-GitHubComment -Issue $issueOrPrNumber -Body $commentMessage
Write-Host -ForegroundColor Green "Done! Comment can be found here: $($comment.html_url)"
