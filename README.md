# dq-tf-dataingest

This Terraform module has one private subnet and deploys an RDS instance. Allowing inbound SQL TCP traffic on 1443.
Also it deploys S3 buckets and associated IAM policies.

## Connectivity

| In/Out        | Type           | Protocol | FromPort| To Port | Description |
| ------------- |:-------------:| -----:| -----:|-----:| -----:|
|INBOUND | PostgreSQL TCP | TCP | 1443 | 1443 | MDS MSSQL|

## Content overview

This repo controls the deployment of an application module.

It consists of the following core elements:

### main.tf

This file has the basic components for an RDS instances
- Private subnet and route table association
- One RDS instances
- Security group for the SQL

### iam.tf

IAM policies used by the S3 buckets.

### mds-rds.tf

Deploys an RDS instance along with a security and database resource group.

### outputs.tf

Various data outputs for other modules/consumers.

### variables.tf

Input data for resources within this repo.

### tests/di_test.py

Code and resource tester with mock data. It can be expanded by adding further definitions to the unit.


## User guide

### Prepare your local environment

This project currently depends on:

* drone v0.5+dev
* terraform v0.11.1+
* terragrunt v0.13.21+
* python v3.6.3+

Please ensure that you have the correct versions installed (it is not currently tested against the latest version of Drone)

### How to run/deploy

To run tests using the [tf testsuite](https://github.com/UKHomeOffice/dq-tf-testsuite):
```shell
drone exec --repo.trusted
```
To launch:
```shell
terragrunt plan
terragrunt apply
```

## FAQs

### The remote state isn't updating, what do I do?

If the CI process appears to be stuck with a stale `tf state` then run the following command to force a refresh:

```
terragrunt refresh
```
If the CI process is still failing after a refresh look for errors about items no longer available in AWS - say something that was deleted manually via the AWS console or CLI.
To explicitly delete the stale resource from TF state use the following command below. *Note:*```terragrunt state rm``` will not delete the resource from AWS it will unlink it from state only.

```shell
terragrunt state rm aws_resource_name
```
