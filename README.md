# fg-notesapp-laravel-php

Example on how to host a [Laravel](https://laravel.com/) web application on **T Cloud Public** FunctionGraph.



## Development Environment

This sample was written using WSL2 and Ubuntu-22.04 distribution but might also work on other Linux versions.

The used IDE is vscode,

Additional software needed:
- Docker


For further setup see [README_SETUP.md](./README_SETUP.md).


## Deploy to FunctionGraph

### Prerequisites

#### Resources on T Cloud Public

- API Gateway created
- RDS Instance created
- SWR created

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


> Warranty Disclaimer
> -------------------
> THE OPEN SOURCE SOFTWARE IN THIS PRODUCT IS DISTRIBUTED IN THE HOPE THAT IT
> WILL BE USEFUL,BUT WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY
> OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.
> 
> SEE THE APPLICABLE LICENSES FOR MORE DETAILS.
