#!/bin/bash

# Exit on any error
set -e

# Create a virtual environment in the 'venv' directory
python3 -m venv venv

# Activate the virtual environment
source venv/bin/activate

# Install required packages inside the virtual environment
pip install --upgrade pip  # Upgrade pip to the latest version
pip install python-dotenv

# Run the Python script to generate the init.sql file
python generate_init_sql.py

# Deactivate the virtual environment
deactivate

docker compose down

docker compose pull

# Run Docker Compose
docker compose up -d
