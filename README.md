# Terraform Project 2 — Application Load Balancer with EC2 Backends

## Overview

This project demonstrates how to design and provision a production-style, load-balanced application architecture on AWS using Terraform, **without relying on prebuilt Terraform modules**.

The purpose of this project is to gain a deep, practical understanding of:

- How AWS services interact with each other
- How Terraform manages cross-resource dependencies
- How to debug real infrastructure issues that occur in non-trivial setups

This project intentionally avoids modules and advanced abstractions to expose the underlying mechanics clearly.

---

## What This Project Builds

Using Terraform, this project provisions:

- An internet-facing **Application Load Balancer (ALB)**
- A **Target Group** with HTTP health checks
- Multiple **EC2 instances** running Nginx
- Dynamic registration of EC2 instances into the target group
- **Security groups** designed with least-privilege access
- Infrastructure discovered via **data sources** (no hardcoded IDs)

Each EC2 instance serves a unique HTTP response so that load-balancing behavior can be visually verified.

---

## Architecture

**Traffic flow:**

```
Internet
   |
   v
Application Load Balancer (HTTP :80)
   |
   v
Target Group
   |
   v
EC2 Instance 1 (Nginx)
EC2 Instance 2 (Nginx)
EC2 Instance 3 (Nginx)
```

**Key architectural decisions:**

- ALB is internet-facing
- EC2 instances are **NOT** directly exposed to the internet
- EC2 instances only accept traffic from the ALB security group
- All infrastructure is managed entirely through Terraform

---

## AWS Services Used

- **EC2** — application compute
- **Application Load Balancer** — traffic distribution
- **Target Groups** — backend health and routing
- **Security Groups** — network access control
- **Default VPC** — networking foundation

---

## Terraform Concepts Covered

- Providers and data sources
- Dynamic AMI lookup
- Resource dependencies and ordering
- Security group referencing (SG → SG, not CIDR-based)
- Scaling resources using `count`
- User data for EC2 bootstrapping
- Target group attachments
- Debugging unhealthy targets and ALB 503 errors
- Proper Git hygiene for Terraform repositories

---

## Prerequisites

Before running this project, ensure the following are installed and configured:

- An active **AWS account**
- **AWS CLI**
- **Terraform** (version 1.x recommended)

**Verify installations:**

```bash
aws --version
terraform version
```

**Configure AWS credentials:**

```bash
aws configure
```

---

## Project Structure

```
Project2/
├── provider.tf
├── data.tf
├── loadBalancer.tf
├── ec2.tf
├── variables.tf
├── terraform.tfvars.example
├── outputs.tf
├── .gitignore
└── README.md
```

**Notes:**

- `.terraform/` and state files are intentionally excluded from Git
- `.terraform.lock.hcl` is committed to lock provider versions
- `terraform.tfvars` is not committed; an example file is provided

---

## Configuration

All configurable values are defined using variables.

**Example `terraform.tfvars`:**

```hcl
instance_type  = "t3.micro"
instance_count = 3
```

No VPC IDs, subnet IDs, or AMI IDs are hardcoded.

---

## How to Run

### 1. Initialize Terraform:

```bash
terraform init
```

### 2. Review the execution plan:

```bash
terraform plan
```

### 3. Apply the infrastructure:

```bash
terraform apply
```

Type `yes` when prompted.

---

## Verification

After a successful apply, Terraform outputs the ALB DNS name.

Open a browser and visit:

```
http://<ALB_DNS_NAME>
```

Refresh the page multiple times.

**Expected output (alternates on refresh):**

```
Hello from Instance 1
Hello from Instance 2
Hello from Instance 3
```

This confirms:

- ✅ Load balancing is working
- ✅ Target group health checks are passing
- ✅ EC2 instances are correctly registered

---

## Challenges Encountered and Solutions

### Challenge 1: ALB returning 503 Service Unavailable

**Symptoms:**

- ALB was reachable
- Target group showed no healthy targets
- Application did not respond

**Root cause:**

- EC2 instances could not reach the internet
- Nginx installation via `user_data` failed
- Health checks failed as port 80 was not serving traffic

**Underlying issue:**

- Subnets in the default VPC were not effectively associated with a route table that provided internet access

**Solution:**

- Corrected subnet and route table association
- Ensured outbound access via Internet Gateway
- EC2 instances successfully installed Nginx
- Target group health checks passed
- ALB began routing traffic correctly

**Key lesson:**

> A "public subnet" is defined by route tables and IGW access, not by name or assumption.

---

## Why This Project Matters

This project was built **without Terraform modules** to intentionally expose:

- Resource repetition
- Cross-resource dependencies
- Configuration complexity
- Debugging challenges

These pain points are exactly what **Terraform modules** are designed to solve.

Building this project first makes module usage meaningful rather than abstract.

---

## What This Project Is NOT

- ❌ Not production-hardened
- ❌ No autoscaling
- ❌ No remote state
- ❌ No CI/CD integration
- ❌ No Terraform modules

These are intentionally deferred to later stages of learning.

---

## Next Steps

- Refactor this project into reusable Terraform modules
- Introduce multi-environment support (dev / prod)
- Add remote state using S3 and DynamoDB
- Replace EC2 with autoscaling groups

---

## Disclaimer

⚠️ **This project is for learning and demonstration purposes only.**

Additional security, scalability, and monitoring considerations are required for production environments.

---

## Author

**Adil**

Built as part of a structured Terraform and DevOps learning journey.

---

**Happy Learning! 🚀**
