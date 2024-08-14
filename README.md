# **Ancile AutoTagger Setup Instructions**
This guide will walk you through the process of setting up the Ancile AutoTagger on your local machine. Follow the steps below to get started:

## **1. Clone the Repository**
To begin, you need to clone the Ancile AutoTagger repository to your local environment. This will give you access to all the necessary files and scripts required for setup.

Execute the following command in your terminal:
    ```bash
    git clone https://github.com/Sec-Ancile/Ancile-AutoTagger.git
    ```

## **2. Create a .env File**
Once you have cloned the repository, you will need to create a .env file in the root directory of the project. This file will store your environment-specific variables such as AWS credentials, database configuration, and more.

To do this:

- Use the env-demo file provided in the repository as a template.
- Update the .env file with your own environment variables.

## **3. Run the Setup Script**
After setting up your environment variables, you can proceed to configure your environment by running the appropriate setup script based on your operating system.

### **For macOS:**
If you're using macOS, execute the following command in your terminal:
    ```bash
    ./ancile-autotagger-script.sh
    ```

### **For Windows:**
For Windows users, depending on your shell environment, run one of the following commands:

- If you are using PowerShell:
    ```powershell
    ./ancile-autotagger-script.ps1
    ```
- If you are using WSL (Windows Subsystem for Linux):
    ```bash
    ./ancile-autotagger-script-l-u.sh
    ```

### **For Linux:**
For Linux users, simply run:
    ```bash
    ./ancile-autotagger-script-l-u.sh
    ```
