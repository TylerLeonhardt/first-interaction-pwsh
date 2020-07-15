# This should go in PowerShellForGitHub or another Actions specific module
function Get-GitHubActionInput {
    param(
        # Name of the input
        [Parameter(Mandatory)]
        [string]
        $Name
    )

    $Name = ($Name -replace " ","_").ToUpper()
    $var = Get-Item Env:/INPUT_$Name
    if ($var) {
        $var.Value
    }
}

# This should go in PowerShellForGitHub or another Actions specific module
function Get-GitHubActionContext {
    if ($env:GITHUB_EVENT_PATH) {
        $payload = (Get-Content -Raw $env:GITHUB_EVENT_PATH) | ConvertFrom-Json
    }

    @{
        EventName = $env:GITHUB_EVENT_NAME
        Sha = $env:GITHUB_SHA
        Ref = $env:GITHUB_REF
        Workflow = $env:GITHUB_WORKFLOW
        Action = $env:GITHUB_ACTION
        Actor = $env:GITHUB_ACTOR
        Payload = $payload
    }
}

function isFirstIssue($creator, $CurrentIssue) {

  $issues = ,(Get-GitHubIssue -Creator $creator)

  if (!$issues.Count) {
    return $true
  }

  foreach ($issue in $issues) {
    if ($issue.number -lt $CurrentIssue -and !$issue.pull_request) {
      return $false
    }
  }

  return $true
}

# No way to filter pulls by creator
function isFirstPull($Creator,$CurrentPullRequest) {
  
  $pulls = ,(Get-GitHubPullRequest -State All)

  if (!$pulls.Count) {
    return $true
  }

  foreach ($pull in $pulls) {
    if ($pull.user.login -eq $creator -and $pull.number -lt $CurrentPullRequest) {
      return $false
    }
  }

  return $true
}

Export-ModuleMember -Function Get-GitHubActionInput,Get-GitHubActionContext,isFirstIssue,isFirstPull
