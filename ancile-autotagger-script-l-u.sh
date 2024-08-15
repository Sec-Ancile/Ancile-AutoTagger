#!/bin/bash

# Exit on any error
set -e

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to ensure proper DNS resolution by adding nameservers to resolv.conf
ensure_dns_resolution() {
    echo "Updating /etc/resolv.conf with reliable nameservers..."
    sudo bash -c 'cat <<EOF > /etc/resolv.conf
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF'
}

# Function to install Docker and Docker Compose on Amazon Linux or CentOS
install_docker_amazon_linux() {
    echo "Detected Amazon Linux or CentOS."
    sudo yum update -y
    sudo yum install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker
    install_docker_compose
}

# Function to install Docker and Docker Compose on Ubuntu
install_docker_ubuntu() {
    echo "Detected Ubuntu."
    sudo apt-get update -y
    sudo apt-get install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
    install_docker_compose
}

# Function to install Docker Compose (shared across all systems)
install_docker_compose() {
    if command_exists docker-compose; then
        echo "Docker Compose is already installed."
    else
        COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
        sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    fi
}

# Function to add user to the Docker group and refresh group membership
add_user_to_docker_group() {
    if groups $USER | grep &>/dev/null '\bdocker\b'; then
        echo "User is already in the Docker group."
    else
        echo "Adding user to the Docker group..."
        sudo usermod -aG docker $USER
        echo "Please log out and log back in for the group membership changes to take effect."
    fi
}

# Function to set up Python virtual environment and run script for Ubuntu
setup_python_venv_and_run_script_ubuntu() {
    # Ensure python3-venv is installed
    if ! dpkg -l | grep -q python3-venv; then
        echo "Installing python3-venv package..."
        sudo apt-get update
        sudo apt-get install -y python3-venv
    fi

    # Recreate the virtual environment if it doesn't exist
    if [ ! -d "venv" ]; then
        echo "Creating virtual environment..."
        python3 -m venv venv
    fi

    # Check if the activate script exists
    if [ -f "venv/bin/activate" ]; then
        echo "Activating virtual environment..."
        source venv/bin/activate
    else
        echo "Virtual environment activation script not found. Please check the venv directory."
        exit 1
    fi

    echo "Installing required Python packages..."
    pip install --upgrade pip
    pip install python-dotenv

    if [ -f "generate_init_sql.py" ]; then
        echo "Running Python script to generate init.sql..."
        python generate_init_sql.py
    else
        echo "Python script generate_init_sql.py not found!"
        exit 1
    fi

    echo "Deactivating virtual environment..."
    deactivate
}

# Function to set up Python virtual environment and run script for Amazon Linux
setup_python_venv_and_run_script_amazon_linux() {
    # Ensure python3 and python3-virtualenv are installed
    if ! command_exists python3; then
        echo "Installing python3 and python3-virtualenv package..."
        sudo yum install -y python3 python3-virtualenv
    fi

    # Recreate the virtual environment if it doesn't exist
    if [ ! -d "venv" ]; then
        echo "Creating virtual environment..."
        python3 -m venv venv
    fi

    # Check if the activate script exists
    if [ -f "venv/bin/activate" ]; then
        echo "Activating virtual environment..."
        source venv/bin/activate
    else
        echo "Virtual environment activation script not found. Please check the venv directory."
        exit 1
    fi

    echo "Installing required Python packages..."
    pip install --upgrade pip
    pip install python-dotenv

    if [ -f "generate_init_sql.py" ]; then
        echo "Running Python script to generate init.sql..."
        python generate_init_sql.py
    else
        echo "Python script generate_init_sql.py not found!"
        exit 1
    fi

    echo "Deactivating virtual environment..."
    deactivate
}

# Detect the OS and run the appropriate installation function
OS_TYPE=$(uname -s)

case "$OS_TYPE" in
    Linux*)
        . /etc/os-release
        case "$ID" in
            amzn|centos)
                install_docker_amazon_linux
                setup_python_venv_and_run_script_amazon_linux
                ;;
            ubuntu)
                ensure_dns_resolution
                install_docker_ubuntu
                setup_python_venv_and_run_script_ubuntu
                ;;
            *)
                echo "Unsupported Linux distribution."
                exit 1
                ;;
        esac
        ;;
    *)
        echo "Unknown OS type: $OS_TYPE"
        exit 1
        ;;
esac

# Add user to Docker group
add_user_to_docker_group

# Stop existing Docker Compose services if running
echo "Bringing down any existing Docker Compose services..."
sudo docker-compose down

# Run Docker Compose
echo "Bringing up Docker Compose services..."
sudo docker-compose up -d

# Notify the user that the setup and execution are complete
echo "Setup and script execution complete!"

exit 0
