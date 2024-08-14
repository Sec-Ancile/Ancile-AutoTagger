# Exit on any error
$ErrorActionPreference = "Stop"

# Check if Docker is installed
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "Docker is not installed. Installing Docker..."
    Invoke-WebRequest -UseBasicParsing "https://desktop.docker.com/win/stable/Docker%20Desktop%20Installer.exe" -OutFile "$env:TEMP\DockerInstaller.exe"
    Start-Process -FilePath "$env:TEMP\DockerInstaller.exe" -ArgumentList "/S" -Wait
    Remove-Item "$env:TEMP\DockerInstaller.exe"
    Write-Host "Docker installation completed. Please restart your computer and re-run this script."
    exit
} else {
    Write-Host "Docker is already installed."
}

# Check if Docker Compose is installed
if (-not (Get-Command docker-compose -ErrorAction SilentlyContinue)) {
    Write-Host "Docker Compose is not installed. Installing Docker Compose..."
    $COMPOSE_VERSION = (Invoke-RestMethod -Uri "https://api.github.com/repos/docker/compose/releases/latest").tag_name
    $URL = "https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)"
    Invoke-WebRequest -Uri $URL -OutFile "/usr/local/bin/docker-compose" -UseBasicParsing
    Start-Process -FilePath "sudo" -ArgumentList "chmod +x /usr/local/bin/docker-compose" -Wait
    Write-Host "Docker Compose installation completed."
} else {
    Write-Host "Docker Compose is already installed."
}

# Create a virtual environment in the 'venv' directory
python -m venv venv

# Activate the virtual environment
& ./venv/Scripts/Activate.ps1

# Install required packages inside the virtual environment
pip install --upgrade pip  # Upgrade pip to the latest version
pip install python-dotenv

# Run the Python script to generate the init.sql file
python generate_init_sql.py

# Deactivate the virtual environment (optional)
# & ./venv/Scripts/Deactivate.ps1

# Stop and remove Docker containers
docker compose down

# Run Docker Compose
docker-compose up -d
