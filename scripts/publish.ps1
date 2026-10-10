param(
  [string]$Host = $env:DEPLOY_HOST,
  [string]$Branch = $env:DEPLOY_BRANCH,
  [string]$CommitMessage = $env:DEPLOY_COMMIT_MESSAGE,
  [string]$RepoDir = "/home/workspace/zxs-website",
  [string]$ServerScript = "scripts/server-deploy.sh"
)

$ErrorActionPreference = "Stop"

function Fail($Message) {
  Write-Error $Message
  exit 1
}

if ([string]::IsNullOrWhiteSpace($Host)) {
  Fail "Missing deploy host. Pass -Host user@server or set DEPLOY_HOST=user@server."
}

if ([string]::IsNullOrWhiteSpace($Branch)) {
  $Branch = (git rev-parse --abbrev-ref HEAD).Trim()
}

if ([string]::IsNullOrWhiteSpace($CommitMessage)) {
  $CommitMessage = "deploy: publish zxs website"
}

Write-Host "[local] building site"
npm run build

Write-Host "[local] staging changes"
git add -A

$status = (git status --porcelain)
if (-not [string]::IsNullOrWhiteSpace($status)) {
  Write-Host "[local] committing changes"
  git commit -m $CommitMessage
} else {
  Write-Host "[local] no local changes to commit"
}

Write-Host "[local] pushing branch $Branch"
git push origin $Branch

$remoteCommand = "set -euo pipefail; cd '$RepoDir'; git pull --ff-only origin '$Branch'; bash '$ServerScript'"

Write-Host "[local] running remote deployment on $Host"
ssh $Host $remoteCommand

Write-Host "[local] publish complete"