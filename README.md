# fg-notesapp-laravel-php

Example on how to host a [Laravel](https://laravel.com/) web application on **T Cloud Public** FunctionGraph.

The app lets users create, edit, search, pin, and delete notes, with authentication and per-user access control.

It uses following T Cloud Public resources:

- FunctionGraph HTTP function
- Relation Database Service (RDS)
- Log Tank Service (LTS)
- API Gateway (APIG)
- Software Repository for Container (SWR)


## Contents

- [fg-notesapp-laravel-php](#fg-notesapp-laravel-php)
  - [Contents](#contents)
  - [Development Environment](#development-environment)
  - [Deploy to FunctionGraph via Console](#deploy-to-functiongraph-via-console)
    - [Prerequisites](#prerequisites)
      - [Resources on T Cloud Public](#resources-on-t-cloud-public)
      - [Local PC - Environment variables](#local-pc---environment-variables)
    - [Build and Push Docker Image](#build-and-push-docker-image)
    - [Configure FunctionGraph](#configure-functiongraph)
      - [Basic Settings](#basic-settings)
      - [Triggers](#triggers)
      - [Permissions](#permissions)
      - [Network](#network)
      - [Environment Variables](#environment-variables)
      - [Logs](#logs)
      - [Advanced Settings](#advanced-settings)
  - [Deploy to FunctionGraph with Terraform](#deploy-to-functiongraph-with-terraform)
    - [Configuration](#configuration)
    - [Deploy](#deploy)
    - [Update FunctionGraph code](#update-functiongraph-code)

## Development Environment

This sample was written using WSL2 and Ubuntu-22.04 distribution but might also work on other Linux versions.

The used IDE is vscode,

Additional software needed:
- Docker

For further setup see [README_SETUP.md](./README_SETUP.md).


## Deploy to FunctionGraph via Console

### Prerequisites

#### Resources on T Cloud Public

Following resources must exist on T Cloud Public:
- RDS (Postgres Database)
- API Gateway
- SWR (Software Repository for Container)

All in same VPC and Subnet.

#### Local PC - Environment variables

Set following environment variables:

| Variable             | Description                   |
| -------------------- | ----------------------------- |
| OTC_SDK_PROJECTNAME  | Project Name (Same as Region) |
| OTC_SDK_AK           | Your access key               |
| OTC_SWR_LOGIN_KEY    | see below                     |
| OTC_SWR_ENDPOINT     | see below                     |
| OTC_SWR_ORGANIZATION | see below                     |

For SWR variables, see: [Obtaining a Long-Term Valid Login Command for SWR](https://docs.otc.t-systems.com/software-repository-container/umn/image_management/obtaining_a_long-term_valid_login_command.html#swr-01-1000)



### Build and Push Docker Image

Check and adapt [Makefile](./Makefile).

In project root execute

```bash
make docker_push
```

### Configure FunctionGraph

Create Function as **Container Image** -  **HTTP Function**

- Region: your region
- Function name: your function name
- Enterprise project: default
- Agency: see below
- Container Image:  notes-app-laravel-php:${IAMGE_TAG}

#### Basic Settings

- Enterprise Project: default
- Execution Timeout: 300
- Memory: 256

#### Triggers

API Gateway Trigger:

- API Group: APIGroup_php_notes_app
- Environment: RELEASE
- Security Authentication: NONE
- Matching: Prefix match
- Method: Any
- Protocol: HTTPS
- Path: /
- Timeout: 60000 ms

#### Permissions

An agency with following permissions is needed:

- SWR Administrator
- VPC FullAccess

#### Network

- VPC Access: enabled
- VPC: same as RDS database / SWR / APIG
- Subnet: same as RDS database / SWR / APIG

#### Environment Variables

| Key              | Value           | Description           | Encrypted
| ---------------- | ----------------| --------------------- | ----
| DB_CONNECTION    | pgsql           | Use Postgres          | 
| DB_HOST          | YOUR DB HOST    | Database host         | 
| DB_PORT          | 5432            | Database port         | 
| DB_DATABASE      | notes           | Database name         | 
| DB_USERNAME      | root            | Database user name    | 
| DB_PASSWORD      | *****           | Password for DB User  | YES
| APP_KEY          |                 | APP_KEY for laravel   encryption | YES
| APP_URL          | URL             | API Gateway URL, see Trigger |
| RUN_MIGRATIONS   | false           | on database changes set to true to run migrations |
| ADMIN_EMAILS     | email1          | Comma separated list of admin email addresses |


#### Logs

- Collect Logs: enabled
- Log Group: specify your log group
- Log Stream specify your log stream

#### Advanced Settings

- Dynamic Memory: enable
- Include Keys: enable


## Deploy to FunctionGraph with Terraform

You can deploy project using terraform.

Following resources must exist on T Cloud Public:
- RDS (Postgres Database)
- API Gateway
- SWR (Software Repository for Container)

All in same VPC and Subnet.

### Configuration

1. Create a `terraform/variables.auto.tf` and set following values:

    ```bash
    # API Gateway instance ID
    API_GATEWAY_INSTANCE_ID =
    # VPC ID
    VPC_ID =
    # Subnet ID 
    NETWORK_ID = 
    # Database name, e.g. notestf
    DB_DATABASE = "notestf"
    # RDS Host
    DB_HOST = 
    # Port of RDS
    DB_PORT = "5432"
    # db user
    DB_USERNAME = "root"
    # Password of db user 
    DB_PASSWORD = 
    # Laravel APP KEY
    APP_KEY = 
    # comma separated list of admin user emails
    ADMIN_EMAILS = "admin@company.com"    
    ```

    > [!WARNING]
    > Do not commit this file as it contains credentials

2. Adapt MakefileTF

```make
# Terraform backend configuration
# bucket for tf states
BACKEND_CONFIG_BUCKET := 
# key for tf state, e.g. "terraform_state/php/fg-notesapp-laravel-php.tf"
BACKEND_CONFIG_KEY := 
# Region e.g. "eu-de"
BACKEND_CONFIG_REGION := "eu-de"
# obs endpoint
BACKEND_CONFIG_ENDPOINTS := "endpoints={s3=\"https://obs.eu-de.otc.t-systems.com\"}"
```

### Deploy
To deploy use:

```bash
make -f MakefileTF tf_apply
```

### Update FunctionGraph code

To update FunctionGraph code with image use:

```bash
make -f MakefileTF update_fg_image
```


> Warranty Disclaimer
> -------------------
> THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
> INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
> PARTICULAR PURPOSE AND NONINFRINGEMENT. 
> IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
> DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, 
> ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
> DEALINGS IN THE SOFTWARE.
