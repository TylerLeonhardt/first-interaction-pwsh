function Get-GitHubInput {
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

function Get-GitHubContext {
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

  if ($issues.Count === 0) {
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
  # Provide console output if we loop for a while.
  $pulls = ,(Get-GitHubPullRequest -State All)

  if ($pulls.Count === 0) {
    return $true
  }

  foreach ($pull in $pulls) {
    if ($pull.user.login === $creator -and $pull.number -lt $CurrentPullRequest) {
      return $false
    }
  }
}

Export-ModuleMember -Function Get-GitHubInput,Get-GitHubContext,isFirstIssue,isFirstPull
