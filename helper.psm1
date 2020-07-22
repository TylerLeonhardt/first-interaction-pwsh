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
