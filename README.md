# fg-notesapp-laravel-php

Example on how to host a [Laravel](https://laravel.com/) web application on **T Cloud Public** FunctionGraph.

## Development Environment

This sample was written using WSL2 and Ubuntu-22.04 distribution but might also work on other Linux versions.

The used IDE is vscode,

Additional software needed:
- Docker

For further setup see [README_SETUP.md](./README_SETUP.md).


## Deploy to FunctionGraph using console

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



### Create docker image

Check and adapt [Makefile](./Makefile).

In project root execute

```bash
make docker_push
```

### Create FunctionGraph

Create Function as **Container Image** -  **HTTP Function**

- Region: your region
- Function name: your function name
- Enterprise project: default
- Agency: see below
- Container Image:  

#### Basic Settings

- Enterprise Project: default
- Execution Timeout: 300
- Memory: 256

#### Triggers

API Gateway Trigger:

- API Group: 
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
- VPC: same as RDS database
- Subnet: same as RDS database

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


## Deploy to FunctionGraph using Terraform

You can deploy project using terraform.

Following resources must exist on T Cloud Public:
- RDS (Postgres Database)
- API Gateway
- SWR (Software Repository for Container)

All in same VPC and Subnet.

### Configuration

1. Create a terraform/variables.auto.tf and set following values:

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
> THE OPEN SOURCE SOFTWARE IN THIS PRODUCT IS DISTRIBUTED IN THE HOPE THAT IT
> WILL BE USEFUL,BUT WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY
> OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.
> 
> SEE THE APPLICABLE LICENSES FOR MORE DETAILS.
