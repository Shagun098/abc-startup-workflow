

***

# 🚀 Transaction Workflow System
### Enterprise Event-Driven Architecture (AWS)

This repository contains the complete **Infrastructure as Code (IaC)** and orchestration logic for an automated transaction processing platform. Engineered for **ABC Startup**, the system leverages a serverless-first approach to ensure scalability, auditability, and strict cost control.

---

## 🏛️ System Architecture

The system utilizes a **synchronized state machine** to gate processing based on infrastructure availability. Deployment is fully automated from GitHub to AWS via OIDC-authenticated pipelines.

```text
[ GitHub ]
    |
    | (OIDC Authentication)
    v
[ GitHub Actions ]
    |
    | (Terraform)
    v
[ AWS Environment ]
    |
    +------------------------------------------------------------------------------+
    | AWS VPC (Virtual Private Cloud)                                              |
    |                                                                              |
    |   [ S3 Bucket ] --> [ EventBridge ] --> [ Step Functions ]                   |
    |      (Input)           (Event Bus)         (Orchestrator)                    |
    |                                                |                             |
    |                                                | (Step 1: Status Check)      |
    |                                                v                             |
    |                                         [ EC2 Instance ]                     |
    |                                          (Dependency)                        |
    |                                                |                             |
    |                                                | (Step 2: Execution)         |
    |                                                v                             |
    |                                       [ ECS Fargate Task ]                   |
    |                                          (Batch Logic)                       |
    |                                                                              |
    +------------------------------------------------------------------------------+
```

---

## 🔧 Technical Component Deep-Dive

### 1. Orchestration Layer (`stepfunctions.tf`)
The **AWS Step Functions** state machine acts as the system "brain," coordinating service interactions without custom glue code.
* **Service Integration:** Uses `aws-sdk:ec2:describeInstanceStatus` to query the pre-processing dependency directly.
* **Logical Gating:** A `Choice` state evaluates the JSON path `$.ec2.InstanceStatuses[0].InstanceState.Name`.
* **Synchronous Execution:** The ECS task is invoked using the `.sync` pattern, ensuring the workflow tracks the container lifecycle until it exits.

### 2. Compute Strategy (`ecs.tf` & `ec2.tf`)
* **Pre-processing Dependency (EC2):** A `t3.micro` instance serves as a required environment gate. It represents a persistent system pillar managed via Terraform.
* **Batch Processor (ECS Fargate):** * **Resource Allocation:** Optimized at **256 CPU units** and **512MB RAM** for maximum cost-efficiency.
    * **Ephemeral Nature:** Tasks spin up on-demand and terminate immediately upon completion of the shell command.
    * **Isolation:** Runs in a dedicated `awsvpc` network mode for enhanced security.

### 3. Event-Driven Trigger (`s3.tf`)
The system eliminates manual triggers or polling:
* **S3 Notifications:** The bucket is configured with `eventbridge = true` to push metadata to the regional bus.
* **EventBridge Rule:** Specifically filters for `Object Created` events to initiate the State Machine execution automatically.

### 4. Networking & Security (`network.tf` & `iam.tf`)
* **Identity:** A unified IAM role is assumed via **GitHub OIDC**, eliminating the risk of long-lived access keys.
* **VPC Design:** A secure VPC (`10.0.0.0/16`) with an Internet Gateway and public subnets ensures the system has the necessary outbound paths for AWS API communication.
* **Security Groups:** Restricted ingress/egress rules ensure only internal VPC traffic and required outbound updates are permitted.

---

## 🚀 DevOps & Deployment

### Infrastructure as Code
* **Terraform Backend:** State is managed remotely in an S3 bucket (`abc-startup-terraform-state`) with **native state locking** (`use_lockfile = true`) to prevent corruption during concurrent deployments.
* **Provider:** Locked to the `ap-south-1` (Mumbai) region for data residency and performance.

### CI/CD Pipelines (GitHub Actions)
The repository includes two manually triggered workflows (`workflow_dispatch`) for maximum safety:
1.  **🚀 Deploy:** Runs `terraform init` and `terraform apply`. Use this to provision or update the stack.
2.  **💣 Destroy:** Runs `terraform destroy`. A fail-safe to decommission all resources and stop AWS billing.

---

## 📊 Operational Visibility

| Metric | Source of Truth |
| :--- | :--- |
| **Workflow Progress** | Step Functions Visual Workflow Graph |
| **Infrastructure State** | Terraform S3 State File |
| **Container Logic** | ECS Task Exit Codes (0 = Success) |
| **Deployment Logs** | GitHub Actions Console |

---

## 📖 Execution Guide

1.  **Infrastructure Setup:** Navigate to GitHub Actions and trigger the **Deploy** workflow.
2.  **Verify Dependency:** Ensure the EC2 instance is in a `running` state (this acts as your processing gate).
3.  **Process Data:** Upload a file to the S3 bucket (`2472737-usecase-bucket`).
4.  **Audit:** View the execution in the AWS Step Functions console to confirm success and view logs.

---

## 📝 Conclusion
This system provides **ABC Startup** with a professional, auditable, and serverless processing pipeline. By coupling **Event-Driven Architecture** with **Rigid IaC standards**, the platform remains easy to operate for non-technical users while meeting high-tier engineering requirements.
