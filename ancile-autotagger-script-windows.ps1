# Exit on any error
$ErrorActionPreference = "Stop"

# Create a virtual environment in the 'venv' directory
python -m venv venv

# Activate the virtual environment
& ./venv/Scripts/Activate.ps1

# Install required packages inside the virtual environment
pip install --upgrade pip  # Upgrade pip to the latest version
pip install python-dotenv

# Run the Python script to generate the init.sql file
python generate_init_sql.py

# Deactivate the virtual environment
# & ./venv/Scripts/Deactivate.ps1

# Stop and remove Docker containers
docker compose down

# Run Docker Compose
docker-compose up -d
