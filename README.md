# MVP-3.0
MVP 3.0 is not about bells and whistles; it's about efficiency, simplicity, and getting the job done with the least amount of fuss.
It's the embodiment of the phrase "good enough is better than perfect."

# Project Infrastructure Deployment using Terraform and GitHub Actions

## Overview
This project leverages Terraform for Infrastructure as Code (IaC) to manage and deploy resources in Azure. The deployment process is automated and managed through GitHub Actions workflows, enabling seamless deployments across multiple environments (e.g., `dev`, `qa`, `prod`) and tenants (e.g., `em01`, `em02`).

## Repository Structure
The repository is structured to support modular, scalable, and reusable Terraform configurations:

```
├── README.md
└── terraform
    ├── environments
    │   ├── dev-em01.tfvars
    │   ├── prod.tfvars
    │   └── qa-em02.tfvars
    └── modules
        ├── bits
        │   └── resource_group
        │       ├── main.tf
        │       ├── outputs.tf
        │       └── variables.tf
        ├── conventions
        │   ├── main.tf
        │   ├── outputs.tf
        │   ├── settings.yml
        │   └── variables.tf
        ├── kubernetes-vm
        └── network
            ├── acr.tf
            ├── aks.tf
            ├── main.tf
            ├── nsg_backend.tf
            ├── nsg_iaas.tf
            ├── nsg_paas.tf
            ├── nsg_public.tf
            ├── providers.tf
            ├── variables.tf
            └── vnet_subnets.tf
```

### Key Components
- **`environments` Directory**:
  - Contains `.tfvars` files for defining environment-specific variables (e.g., `dev-em01.tfvars`, `qa-em02.tfvars`).
  - Each file specifies variables such as location, application instance, and Azure configurations.

- **`modules` Directory**:
  - Modular Terraform configurations for specific resources (e.g., resource groups, networks, Kubernetes).
  - Encourages reusability and separation of concerns.

## Workflow Configuration
The deployment workflow is managed via the `terraform_deployment.yaml` file in the `.github/workflows` directory. This workflow supports both automated and manual triggers for deployments.

### Workflow Triggers
- **Automatic Trigger**:
  - Runs on pushes to `feature/**` or `bugfix/**` branches to validate changes.
- **Manual Trigger**:
  - Can be triggered manually via `workflow_dispatch` for specific environments and tenants.

### Key Features
- Supports environment-specific deployments (`dev`, `qa`, `pd`).
- Supports multi-tenant deployments via `application_instance` (e.g., `em01`, `em02`).
- Enforces production approvals using GitHub Environments.

### Workflow Steps
1. **Checkout Code**:
   - Pulls the repository code into the GitHub Actions runner.

2. **Azure Login**:
   - Authenticates with Azure using Service Principal credentials stored in GitHub Secrets (`AZURE_CREDENTIALS`).

3. **Set Environment Variables**:
   - Dynamically sets Terraform variables (`ENVIRONMENT`, `APPLICATION_INSTANCE`, `TFVARS_FILE`, `BACKEND_KEY`).

4. **Terraform Initialization**:
   - Initializes Terraform with the backend configuration for state management.

5. **Terraform Plan**:
   - Creates an execution plan to preview the infrastructure changes.

6. **Production Approval**:
   - Requires manual approval before applying changes to `prod`.

7. **Terraform Apply**:
   - Applies the infrastructure changes for the specified environment and tenant.

### Workflow YAML
Below is the workflow configuration file (`terraform_deployment.yaml`):

```yaml
name: Terraform Deployment

on:
  # Automatically trigger workflows for changes in feature/ or bugfix/ branches
  push:
    branches:
      - 'feature/**'
      - 'bugfix/**'
  # Allow manual trigger for specific environments and instances
  workflow_dispatch:
    inputs:
      environment:
        description: "Environment to deploy (dev, qa, prod)"
        required: true
        default: "dev"
      application_instance:
        description: "Application instance (e.g., em01, em02)"
        required: true
        default: "em01"

permissions:
  contents: read
  id-token: write

env:
  IMAGE_NAME: 'mvp-3.0'

jobs:
  terraform:
    if: github.ref != 'refs/heads/master' || github.event_name == 'workflow_dispatch'
    runs-on: ubuntu-latest
    environment: ${{ github.event.inputs.environment }}
    defaults:
      run:
        working-directory: 'terraform/modules/network/'
    steps:
      - uses: actions/checkout@v2

      - name: Azure Login
        uses: azure/login@v1
        with:
          creds: '${{ secrets.AZURE_CREDENTIALS }}'

      - name: Set Terraform Authentication
        run: |
          echo "ARM_CLIENT_ID=$(jq -r '.clientId' <<< '${{ secrets.AZURE_CREDENTIALS }}')" >> $GITHUB_ENV
          echo "ARM_CLIENT_SECRET=$(jq -r '.clientSecret' <<< '${{ secrets.AZURE_CREDENTIALS }}')" >> $GITHUB_ENV
          echo "ARM_SUBSCRIPTION_ID=$(jq -r '.subscriptionId' <<< '${{ secrets.AZURE_CREDENTIALS }}')" >> $GITHUB_ENV
          echo "ARM_TENANT_ID=$(jq -r '.tenantId' <<< '${{ secrets.AZURE_CREDENTIALS }}')" >> $GITHUB_ENV
          echo "ARM_ACCESS_KEY=$(az storage account keys list --account-name mvp30backendsa --resource-group ts-rg-01 --query '[0].value' --output tsv)" >> $GITHUB_ENV

      - name: Set Environment Variables
        run: |
          echo "ENVIRONMENT=${{ github.event.inputs.environment }}" >> $GITHUB_ENV
          echo "APPLICATION_INSTANCE=${{ github.event.inputs.application_instance }}" >> $GITHUB_ENV

      - name: Set TFVARS File Path
        run: |
          echo "TFVARS_FILE=${{ env.ENVIRONMENT }}-${{ env.APPLICATION_INSTANCE }}.tfvars" >> $GITHUB_ENV
          echo "BACKEND_KEY=${{ env.ENVIRONMENT }}-${{ env.APPLICATION_INSTANCE }}/terraform.tfstate" >> $GITHUB_ENV

      - name: Debug Environment Variables
        run: |
          echo "Environment: ${{ env.ENVIRONMENT }}"
          echo "Application Instance: ${{ env.APPLICATION_INSTANCE }}"
          echo "Variables file: ${{ env.TFVARS_FILE }}"
          echo "Backend key: ${{ env.BACKEND_KEY }}"

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v1

      - name: Terraform Init
        run: terraform init -backend-config="key=${{ env.BACKEND_KEY }}"

      - name: Terraform Plan
        run: terraform plan -var-file=$GITHUB_WORKSPACE/terraform/environments/${{ env.TFVARS_FILE }}

      # Require approval for production deployments
      - name: Require Approval for Production
        if: ${{ env.ENVIRONMENT == 'prod' }}
        run: |
          echo "Production deployment requires approval."

      - name: Terraform Apply
        if: ${{ env.ENVIRONMENT != 'prod' || github.event.environment_approved }}
        run: terraform apply -auto-approve -var-file=$GITHUB_WORKSPACE/terraform/environments/${{ env.TFVARS_FILE }}
```

## Example `.tfvars` File
Below is an example `.tfvars` file for `dev-em02`:

```hcl
location              = "GermanyWestCentral"
environment           = "dev"
application_name      = "mvp"
application_instance  = "em02"
functions             = ["network", "aks", "acr"]
resource_instance     = "01"
tooling_vnet_ip_range = "185.252.180.222"
```

## Best Practices
- Use **feature branches** for development and **pull requests** for merging to `master`.
- Protect `master` and `prod` deployments with review and approval workflows.
- Modularize Terraform configurations for reusability.
- Maintain separate `.tfvars` files for each environment and application instance.
- Regularly rotate credentials stored in GitHub Secrets.

## Conclusion
This setup ensures a scalable, secure, and efficient infrastructure deployment process using Terraform and GitHub Actions. By adopting best practices, the project can support multiple environments and tenants with minimal manual intervention.

