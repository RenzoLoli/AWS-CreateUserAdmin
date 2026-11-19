# AWS IAM Administration with Terraform

Terraform project for provisioning and managing AWS Identity and Access Management (IAM) resources. It automates the creation of an administrative IAM user, configures account-level password requirements, and assigns administrative permissions through an IAM group.

The project follows an Infrastructure as Code (IaC) approach, keeping IAM configuration declarative, reproducible, and version-controlled.

## Overview

This project provisions the following AWS resources:

- **IAM User:** Creates an IAM user named `administrator` under the `/admin` path.
- **Console Access:** Generates an initial console password with a mandatory password reset on first login.
- **Password Policy:** Configures account-level password requirements.
- **IAM Group:** Creates an `Admins` group to centralize administrative permissions.
- **Managed Policy Attachment:** Attaches AWS-managed `AdministratorAccess` to the group.
- **Group Membership:** Adds the `administrator` user to the `Admins` group.

## Architecture

```text
AWS Account
│
├── IAM Password Policy
│
├── IAM Group: Admins
│   │
│   └── AWS Managed Policy
│       └── AdministratorAccess
│
└── IAM User: administrator
    │
    ├── Path: /admin
    ├── Console Login Profile
    └── Group Membership
        └── Admins
```

## Project Structure

```text
.
├── main.tf
├── outputs.tf
├── provider.tf
└── variables.tf
```

| File | Description |
|---|---|
| `main.tf` | Defines IAM users, groups, password policy, login profile, and permissions. |
| `outputs.tf` | Exposes the generated username and encrypted initial password. |
| `provider.tf` | Configures Terraform requirements and the AWS provider. |
| `variables.tf` | Declares input variables required by the configuration. |

## Prerequisites

- Terraform >= 1.0.0
- AWS account
- AWS CLI configured with appropriate credentials
- IAM permissions to manage users, groups, policies, login profiles, and account password policies
- GPG public key for encrypting the generated console password

### AWS Provider

The project uses the HashiCorp AWS provider:

- Provider: `hashicorp/aws`
- Version constraint: `~> 6.0.0`
- Default region: `us-east-1`

AWS credentials are obtained through the standard AWS provider authentication mechanisms, such as environment variables, AWS CLI profiles, or IAM roles.

## Configuration

### 1. AWS Credentials

Configure your AWS credentials using an AWS CLI profile:

```bash
aws configure
```

Alternatively, use environment variables:

```bash
export AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="YOUR_SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION="us-east-1"
```

Do not commit credentials or expose them in source control.

### 2. GPG Public Key

The IAM login profile uses a GPG public key to encrypt the generated initial console password.

Generate a GPG key pair if you do not already have one:

```bash
gpg --full-generate-key
```

Export your public key and encode it in Base64:

```bash
gpg --export admin@test.com | base64 -w 0
```

Copy the resulting Base64 string.

Create a `terraform.tfvars` file in the project root:

```hcl
admin_gpg_key = "YOUR_BASE64_ENCODED_GPG_PUBLIC_KEY"
```

The `admin_gpg_key` variable expects the Base64-encoded ASCII GPG public key.

The public key is used by Terraform to encrypt the generated IAM console password. The corresponding private key is required to decrypt it.

**Important:**
- Never share or commit your GPG private key.
- Keep `terraform.tfvars` out of version control.
- Protect the Terraform state because it may contain sensitive information.

## Deployment

### 1. Initialize Terraform

Download the required providers and initialize the working directory:

```bash
terraform init
```

### 2. Validate Configuration

Check the Terraform configuration:

```bash
terraform validate
```

### 3. Review Execution Plan

Inspect the resources Terraform intends to create:

```bash
terraform plan
```

### 4. Apply Configuration

Provision the IAM resources:

```bash
terraform apply
```

Review the execution plan and confirm the deployment.

## Retrieve Initial Credentials

After deployment, Terraform exposes two outputs:

| Output | Description |
|---|---|
| `username` | IAM username generated for console authentication. |
| `password` | Encrypted initial console password. |

Retrieve the username:

```bash
terraform output username
```

Retrieve the encrypted password:

```bash
terraform output -raw password
```

Because the password is encrypted, decrypt it using your GPG private key:

```bash
terraform output -raw password | base64 --decode | gpg --decrypt
```

The generated password must be changed during the first console login.

**Security considerations:**
- The password output is marked as sensitive in Terraform.
- Sensitive outputs can still be stored in Terraform state.
- Protect your Terraform state file and any remote state backend.
- Never commit decrypted passwords, private GPG keys, or AWS credentials.

## Password Policy

The project configures an account-level IAM password policy with the following requirements:

| Setting | Configuration |
|---|---|
| Minimum password length | 14 characters |
| Lowercase characters | Required |
| Uppercase characters | Required |
| Numbers | Required |
| Symbols | Required |
| User password changes | Allowed |
| Maximum password age | 15 days |
| Password reuse prevention | Last 24 passwords |

The password policy applies at the AWS account level, rather than exclusively to the `administrator` user.

## Permissions Management

The `Admins` group receives the AWS-managed `AdministratorAccess` policy.

Policy ARN:

```text
arn:aws:iam::aws:policy/AdministratorAccess
```

This policy grants broad administrative permissions across AWS services and resources.

Permissions are assigned to the group instead of directly to the user, allowing centralized permission management as additional IAM users are introduced.

## Security Considerations

- **Least Privilege:** `AdministratorAccess` grants extensive permissions. It should only be assigned to identities that genuinely require administrative access.
- **Root Account Protection:** The AWS root user should be protected with MFA and reserved for tasks that specifically require root access.
- **Credential Management:** AWS credentials and GPG private keys must never be committed to the repository.
- **Terraform State:** Terraform state can contain sensitive information, including IAM login profile data. Use a protected remote backend and restrict access.
- **Password Rotation:** The configured 15-day expiration is intentionally restrictive. Evaluate whether periodic expiration is appropriate for your operational environment.
- **User Lifecycle:** The `force_destroy` setting allows Terraform to delete the IAM user even when it has associated credentials. Use caution when destroying resources.

## Cleanup

To remove the resources managed by this configuration:

```bash
terraform destroy
```

Review the proposed changes before confirming.

**Warning:** This operation deletes the IAM user, group, group membership, policy attachment, and the account password policy managed by this configuration. Ensure that removing these resources will not disrupt other account users or workloads.

## References

- [AWS IAM Documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html)
- [IAM Security Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [Creating an IAM Admin User and Group](https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started_create-admin-group.html)
- [AWS Managed Policies](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_managed-vs-inline.html)
- [IAM Password Policy](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_passwords_account-policy.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

---

**Infrastructure as Code:** Terraform  
**Cloud Provider:** Amazon Web Services (AWS)  
**Service:** Identity and Access Management (IAM)
