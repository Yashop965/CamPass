$ErrorActionPreference = "Stop"

# Configuration
$ContainerName = "campass_gravity-db-1"
$DbUser = "postgres"
$DbName = "campass"
$OutputDir = "database"
$OutputFile = "$OutputDir\init.sql"

# Ensure output directory exists
if (-not (Test-Path -Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
    Write-Host "Created directory: $OutputDir"
}

# Check if container is running
$ContainerStatus = docker inspect -f '{{.State.Running}}' $ContainerName 2>$null
if ($ContainerStatus -ne "true") {
    Write-Error "Container '$ContainerName' is not running. Please start it with 'docker-compose up -d db'."
}

Write-Host "Dumping database '$DbName' from container '$ContainerName' to '$OutputFile'..."

# Dump database
# We use cmd /c to handle the redirection properly in PowerShell when calling external executables with redirection
cmd /c "docker exec -t $ContainerName pg_dump -U $DbUser $DbName -c > $OutputFile"

if ($LASTEXITCODE -eq 0) {
    Write-Host "Database dump successful!"
    Write-Host "File saved to: $(Resolve-Path $OutputFile)"
} else {
    Write-Error "Database dump failed with exit code $LASTEXITCODE."
}
