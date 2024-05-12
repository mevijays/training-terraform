# How to setup the pipeline and credentials.
- Generate the Terraform cloud API key and create secret in github action repository setting. Assume the name of secret you have created is ``TF_API_TOKEN``
- Generate ( *only in case TF CLoud workspace execution mode is local* ) the aws secret key and token and create secret in github actions repository setting. Assume you have created ``AWS_ACCESS_KEY_ID`` and ```AWS_SECRET_ACCESS_KEY```.  
- Example workflow  will be like this.
```yaml
name: "AWS Terraform workflow"
on:
  workflow_dispatch: # Parameterization to make a selection of apply or destroy.
    inputs:
      TFACTION:
        description: "Terraform Action"
        default: "apply"
        required: true
        type: choice
        options:
         - "apply"
         - "destroy"

permissions:
  contents: 'read'
  id-token: 'write'
jobs:
  aws_action:
    runs-on: ubuntu-latest
    defaults:
      run:
        shell: bash
    name: 'workflow setup'
# Code checkout
    steps:
      - name: Checkout
        uses: actions/checkout@v4
# configure aws credentials for action
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-2
# Setup terraform CLI with TF_API_TOKEN
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.8.0
          cli_config_credentials_token: ${{ secrets.TF_API_TOKEN }}
# Initialize terraform
      - name: Terraform Init
        run: terraform  init
        working-directory: tfroot # this is directory where all terraform files are

# Generates an execution plan for Terraform
      - name: Terraform Plan
        run: terraform  plan -input=false
        working-directory: tfroot
# Apply the plan if apply parameter selected during run.
      - name: Terraform Apply
        if: ${{ github.event.inputs.TFACTION == 'apply' }}
        run: terraform  apply --auto-approve -input=false
        working-directory: tfroot
# Destroy the infra if destroy parameter selected during run.
      - name: Terraform Destroy
        if: ${{ github.event.inputs.TFACTION == 'destroy' }}
        run: terraform destroy --auto-approve -input=false
        working-directory: tfroot
```