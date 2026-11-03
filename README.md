# Terraform AWS Lab

A modular Terraform project for deploying and troubleshooting a small AWS web application path: an Application Load Balancer (ALB) forwards requests to EC2 instances in an Auto Scaling group.

The next planned feature is a serverless diagnostics API that will use API Gateway and Python Lambda functions to run read-only ALB checks and store diagnostic results in RDS. The API and Lambda integration are not implemented yet.

## Current architecture

```text
Internet
   |
Internet-facing ALB in public subnets
   |
Target group and HTTP listener
   |
EC2 Auto Scaling group in private subnets

Optional database foundation (feature branch):
Private database subnets -> PostgreSQL RDS
```

The VPC includes public, private application, and isolated database subnets. Public subnets use an Internet Gateway. Private application subnets route outbound traffic through one shared NAT Gateway. Database subnets have no default internet route. The ALB currently listens on HTTP port 80 and forwards traffic to the EC2 targets.

## Terraform modules

| Module             | Purpose                                                                                                                                                                                                                                                   |
|--------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `modules/vpc`      | Creates the VPC, public/private/database subnets, Internet Gateway, NAT Gateway, route tables, and subnet associations.                                                                                                                                   |
| `modules/security` | Creates configured security groups and their ingress/egress rules, including rules that reference other security groups.                                                                                                                                  |
| `modules/alb`      | Creates the internet-facing Application Load Balancer, target group, and HTTP listener.                                                                                                                                                                   |
| `modules/compute`  | Creates the EC2 launch template and Auto Scaling group in private subnets, with an instance role for Systems Manager access. Requires IMDSv2 and provisions a separate encrypted 20 GiB gp3 EBS volume at /dev/sdf. The current bootstrap does not mount or use this additional volume. |
| `modules/rds`      | Provides the PostgreSQL RDS instance and database subnet group. This is groundwork for the planned diagnostics API and is disabled by default in the development environment. RDS manages the master password in Secrets Manager.                         |
| `modules/db_admin` | Provides an optional private EC2 database administration host for connecting to PostgreSQL through AWS Systems Manager Session Manager (SSM). This is groundwork for the planned diagnostics API and is disabled by default.                                                 |

## Status and roadmap

### Implemented

- ALB-to-EC2 traffic path with EC2 Auto Scaling.
- VPC routing, security groups, and private application subnets.
- ALB target group health checks configured for the EC2 targets.
- RDS Terraform module and isolated database subnet foundation on `feature/aws-data-ingestion`.

### Planned

- API Gateway endpoint for ALB diagnostics.
- Python Lambda function using read-only AWS APIs to inspect the ALB-to-EC2 path.
- Store diagnostic runs and findings in the private RDS database.
- Retrieve a previous diagnostic result through the API.

The API, Lambda function, and end-to-end database integration are not implemented yet. The earlier VPC/subnet inventory schema is exploratory work and is not part of the current project scope.

## Requirements and configuration

- Terraform `>= 1.15.0, < 2.0.0`.
- AWS credentials with permissions for the resources being managed.
- An S3 bucket you control for the Terraform backend.
- An "environments/dev/dev.tfvars" file containing values for the variables declared in `environments/dev/variables.tf`.

The S3 backend configuration in `environments/dev/versions.tf` is also maintainer-specific; replace it with your own bucket and state key before running Terraform. Do not use another person's backend or state.

To enable the optional RDS instance, set `enable_rds = true` in your local development variables. It defaults to `false`. Applying after changing it back to `false` removes the RDS resources. The current RDS module defaults to skipping a final snapshot and has deletion protection disabled, so preserve any database data you need before disabling it.

## Local workflow

From the repository root:

```powershell
terraform fmt -check -recursive
Set-Location environments/dev
terraform init
terraform validate
terraform plan -var-file="dev.tfvars"
```

Review the plan before applying. AWS resources can incur charges. The shared NAT Gateway, ALB, and EC2 Auto Scaling group can incur charges while deployed; RDS adds cost when enabled. Destroying the environment removes managed resources and can delete data.

## GitHub Actions

The repository includes Terraform validation/plan, manual apply, and manual destroy workflows. The current AWS OIDC trust is scoped to the `main` branch.

## Project direction

The Terraform environment is intended as a learning and portfolio project. It demonstrates the ALB-to-EC2 path now and is being extended toward a serverless diagnostics API. It is not a production-ready deployment: the ALB is HTTP-only, the database integration is unfinished, and cost, availability, and security settings should be reviewed for any real workload.
