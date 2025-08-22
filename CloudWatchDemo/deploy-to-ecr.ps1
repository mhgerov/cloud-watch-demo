param(
    [string]$Region = "us-east-2",
    [string]$RepoName = "cloudwatchdemo",
    [string]$LocalImage = "cloudwatchdemo:latest",
    [string]$RemoteTag = "latest"
)

$ErrorActionPreference = 'Stop'

# Basic tooling checks
if (-not (Get-Command aws -ErrorAction SilentlyContinue)) { Write-Error "AWS CLI not found in PATH."; exit 1 }
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) { Write-Error "Docker not found in PATH."; exit 1 }

Write-Host "Getting AWS Account ID..."
$AccountId = (aws sts get-caller-identity --query Account --output text)
if (-not $AccountId) { Write-Error "Failed to get AWS account ID. Are you logged in (aws configure / SSO)?"; exit 1 }

$EcrHost = "${AccountId}.dkr.ecr.${Region}.amazonaws.com"
$EcrUri  = "${EcrHost}/${RepoName}"

# Ensure repo exists (create if missing)
aws ecr describe-repositories --repository-names $RepoName --region $Region 1>$null 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "ECR repo '$RepoName' not found in $Region. Creating..."
    aws ecr create-repository --repository-name $RepoName --region $Region | Out-Null
}

Write-Host "Logging into ECR..."
aws ecr get-login-password --region $Region | docker login --username AWS --password-stdin $EcrHost
if ($LASTEXITCODE -ne 0) { Write-Error "Docker login to ECR failed."; exit 1 }

Write-Host "Tagging local image $LocalImage as ${EcrUri}:$RemoteTag..."
docker tag $LocalImage "${EcrUri}:$RemoteTag"
if ($LASTEXITCODE -ne 0) { Write-Error "Docker tag failed. Does local image '$LocalImage' exist?"; exit 1 }

Write-Host "Pushing image to ECR..."
docker push "${EcrUri}:$RemoteTag"
if ($LASTEXITCODE -ne 0) { Write-Error "Docker push failed."; exit 1 }

Write-Host "Done! Image available at ${EcrUri}:$RemoteTag"
