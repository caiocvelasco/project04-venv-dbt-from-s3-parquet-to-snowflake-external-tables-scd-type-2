# ETL - Leveraging dbt-Snowflake to perform Transformation Step (Reading Parquet from S3 -> Storing in Snowflake External Tables -> dbt Transformation in Snowflake).

<img src = "img/dbt_transformation.jpg"> 

## Table of Contents

- [Project Structure](#project-structure)
- [Setup Instructions](#setup-instructions)
  - [Prerequisites](#prerequisites)
  - [Environment Variables](#environment-variables)
  - [Initiate the Environment](#initiate-the-environment)
- [dbt](#dbt)

## Project Structure

- **dbt_2_transformation (project-root)/**
    - **.venv/**
    - **dbt_transformation/**   (This is where your dbt project lives)
    - **img/**
    - **logs/**
    - **.env**
    - **.gitignore**
    - **.python-version**
    - **requirements.txt**
    - feng_dbt_user_no_MFA.sql (a file to help with creating a role an user in Snowflake)
    - feng_snf_s3_storage_integration_ext_table.sql (a file to help with storage integration in Snowflake)
    - **README.md**

## Setup Instructions

### Prerequisites

Make sure you have the following installed on your local development environment:

* [VSCode](https://code.visualstudio.com/)
  * Install `GitLens — Git supercharged` extension and Jupyter Notebook extensions.
* [Pyenv](https://github.com/pyenv-win/pyenv-win)
  * This is not mandatory.
  * This is just to help you manage both the Global (on your machine) and Local (for your project) Python Versions.
  * Open Windows Powershell and follow the instructions from the Pyenv website, which are:
    * `Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/pyenv-win/pyenv-win/master/pyenv-win/install-pyenv-win.ps1" -OutFile "./install-pyenv-win.ps1"; &"./install-pyenv-win.ps1"`
  * If there is an error, try this:
    * `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
  * Then, try the command above again
  * Open Git Bash:
    * pyenv --version (This will show if pyenv was installed successfully)
  * Create Pyenv Environment Variables in Windows
    * Windows Flag on your Keyboard + R:
      * sysdm.cpl -> Advanced Tab -> Environment Variables
      * Get the `pyenv-win` folder path. Usually, it is created here: `C:\Users\YOUR_USER\.pyenv\pyenv-win\`
      * Create 3 variables in the "User variables for YOUR_USER" part, and put the path above to each of them:
        * PYENV, PYENV_ROOT, PYENV_HOME
      * Double-click `Path` in the same part and click on New and add the paths for `bin` and for `shims`
        * `C:\Users\YOUR_USER\.pyenv\pyenv-win\bin`
        * `C:\Users\YOUR_USER\.pyenv\pyenv-win\shims`
        * Move both of them to the top (This will allow pyenv to have preference over the other python interpreters)
    * Check if it is working: Git Bash -> pyenv
  * Install Python Versions (This will install the python version that will be linked to different project with pyenv)
    * pyenv install 3.12.1
    * pyenv install 3.9.13
    * Check with: pyenv versions
  * Configure the Global Python version for your machine:
    * pyenv global 3.12.1
    * pyenv global (This will show the current global python version)
  * Configure the Local Python version for your project 
    * cd your_repo_folder
    * pyenv local 3.9.13 (This will create a `.python-version` file in your repo folder with the local version of your project)
    * Check with: python --version
* [.venv - Virtual Environment](https://docs.python.org/3/library/venv.html)
  * cd your_repo_folder:
    * cd "C:\PATH_TO_YOUR_DBT_FOLDER"
  * python -m venv .venv           (This will create a virtual environment for the repo folder)
  * source .venv/Scripts/activate  (This will activate your virtual environment)
  * Install everything you need for your project from the `requirements.txt` file:
    * make sure to update pip, this is important to avoid conflicts: `python.exe -m pip install --upgrade pip`
    * `pip install --no-cache-dir -r requirements.txt`  (This will install things inside your virtual environment)
    * Check: pip list

* [dbt - profiles.yml - DBT_PROFILES_DIR - Connections](https://docs.getdbt.com/docs/core/connect-data-platform/connection-profiles#advanced-customizing-a-profile-directory)
  * When you invoke dbt from the command line (or from any terminal), dbt parses the `dbt_project.yml` file and obtains the 'profile name', which is where the connection credentials (the ones used to connect to your Data Warehouse) are defined. This 'profile name' is a parameter in the `dbt_project.yml` that makes reference for the any of the 'profiles' you created in the `profiles.yml` file.  
  * In order for dbt to test if the connections to databases are working, it needs to find the `profiles.yml`, which is usually located in `~/.dbt` folder.
  * However, since we have multiple dbt project, it is better to put the `profiles.yml` file within a `.dbt` folder closer to our dbt projects so that it can be easier to manage.
  * Create a `DBT_PROFILES_DIR` environment variable in Windows:
    * Windows Flag on your Keyboard + R:
      * sysdm.cpl -> Advanced Tab -> Environment Variables
      * Create a `DBT_PROFILES_DIR` variable in the "User variables for YOUR_USER" part, and put the path to your `.dbt` folder from your repo folder.
        * Example: Set `DBT_PROFILES_DIR` to C:\Projeto_dbt
    * Close and Open your VSCode
    * Go the the Git Bash Terminal (or Powershell)
    * Check it by doing: echo $DBT_PROFILES_DIR
    * Go to your dbt project folder in your repo (C:\PATH_TO_DBT_FOLDER)
    * Do: dbt debug

Make sure to inclue a .gitignore file with the following information:

* .venv/         (to ignore the virtual environment stuff)
* *.pyc          (to ignore python bytecode files)
* .env           (to ignore sensitive information, such as database credentials)

### Environment Variables
The .gitignore file, ignores the `.env` file for security reasons. However, since this is just for educational purposes, follow the step below to include it in your project. If you do not include it, the docker will not work.

Create a `.env` file in the project root with the following content:

S3_REGION=YOUR_REGION
S3_BUCKET_NAME=YOUR_BUCKET_NAME                            
S3_SNOWFLAKE_STORAGE_INTEGRATION=MY_S3_INTEGRATION
S3_SNOWFLAKE_STAGE=MY_S3_STAGE
S3_SNOWFLAKE_FILE_FORMAT=MY_PARQUET_FORMAT
S3_SNOWFLAKE_IAM_ROLE_ARN=arn:aws:iam::YOUR_ROLE:role/mysnowflakerole
SNOWFLAKE_HOST=YOUR_HOST.YOUR_REGION.aws.snowflakecomputing.com
SNOWFLAKE_PORT=443 
SNOWFLAKE_USER=YOUR_USER
SNOWFLAKE_ROLE=STORAGE_ADMIN
SNOWFLAKE_PASSWORD=YOUR_PASSWORD
SNOWFLAKE_DBT_USER=DBT_USER
SNOWFLAKE_DBT_ROLE=DBT_ROLE
SNOWFLAKE_ACCOUNT=YOUR_ACCOUNT
SNOWFLAKE_ACCOUNT_URL=https://YOUR_HOST.YOUR_REGION.aws.snowflakecomputing.com
SNOWFLAKE_WAREHOUSE=MY_DBT_WAREHOUSE
SNOWFLAKE_DATABASE=MY_DBT_DATABASE
SNOWFLAKE_SCHEMA_BRONZE=bronze

If you want to check the environment variables from your current folder, do:
* printenv (this will show if the environmental variables were loaded within the Docker container)
* printenv | grep SNOWFLAKE (this functions as a filter to show only the variables that contain 'POSTGRES')

### Initiate the Environment

1. **Clone the repository:**

   ```bash
   git clone YOUR_GIT_REPO_URL.git
   cd "C:\PATH_TO_DBT_FOLDER"

2. **Activate you Virtual Environment (.venv)**

* cd "C:\PATH_TO_DBT_FOLDER"
* source .venv/Scripts/activate

## dbt

* Go to the `dbt_transformation/` folder and operate dbt by following the `README` in there.
  * cd "C:\PATH_TO_DBT_FOLDER"
  * `dbt debug`