# Terraform exam 003 and 004 update
Here’s a direct **comparison of Terraform Associate Exam 003 and the upcoming 004 content lists** based on official HashiCorp documentation:

***

### Exam Content Structure Overview

| **003 Topics** | **004 Topics** |
|----------------|---------------|
| 1. IaC concepts (Explain, Advantages) | 1. Infrastructure as Code (IaC) with Terraform - Explain, Advantages, Multi-cloud, Service agnostic |
| 2. Purpose of Terraform, state benefits | 2. Terraform fundamentals - Install/version providers, How providers work, Multi-provider configs, State mgmt |
| 3. Terraform basics & providers | 3. Core Terraform workflow - Workflow, Init, Validate, Plan, Apply, Destroy, Fmt |
| 4. Terraform outside core workflow (Import/state/logging) | 4. Terraform configuration - Resource/data blocks, cross-resource references, variables, outputs, complex types, expressions, functions, dependencies, validation, sensitive data mgmt, Vault |
| 5. Modules (source, inputs/outputs, scope, version) | 5. Terraform modules - Source, scope, usage, version mgmt |
| 6. Core workflow (Write→Plan→Create...) | 6. Terraform state management - Local backend, state locking, remote state, drift, refactor/refresh/moved/removed blocks |
| 7. State implementation/maintenance | 7. Maintain infrastructure with Terraform - Import, inspect state, verbose logging |
| 8. Read, generate, modify configuration | 8. HCP Terraform - Create infra, collaboration/governance, workspaces/projects, integration |
| 9. HCP Terraform capabilities |  |


***

### **Key Changes in 004 vs 003**

**1. Expanded Scope and Structure**
- **004 covers more detailed workflows** (init, validate, plan, apply, destroy, fmt) in their own sections.
- Split, renamed & clarified objectives for easier reference.
- **State management** has **more nuanced topics**: resource drift, refactor state, refresh-only, removed/moved blocks.

**2. HCP Terraform Has Its Own Dedicated Section**
- **Collaboration, governance, projects, integration, variable sets, drift detection, policy enforcement** specifically mentioned.

**3. Higher Focus on Best Practices**
- **Managing sensitive data and secrets now explicitly includes Vault integration** and practices for handling secrets.

**4. Configuration Validation**
- Custom condition validation, checks, and module validation are now listed as explicit exam topics.

**5. Additional Advanced Features**
- Remote operations, run triggers, health checks, OPA policy enforcement covered.

**6. Tutorials & Docs Reference Updates**
- Most content updated to reference Terraform 1.12.x and HCP Terraform integration features.

***

### **Notable New/Additions in 004**

- **Multi-cloud, hybrid cloud, service-agnostic workflows**
- **Complex variable types** and dynamic configuration
- **Module variable scope** is clarified
- **State drift management**, **refresh-only mode**
- **Access to HCP Terraform features:** collaboration, governance, organization
- **Advanced validation and security**: checks, OPA, Vault
- **Workspaces/project organization** in HCP Terraform
- **Integration and migration between local and cloud state**

***

### **Topics Retired or De-emphasized in 004**

- **Sentinel** (previously mentioned in 003, replaced by broader “policy enforcement” references in 004).
- Some generic state backend options streamlined into deeper “state management” topics.
- More “provider architecture”-type details merged into fundamental sections.

***

**Overall:**  
004 is **modernized, expanded, and refocused** for a more practical, security-oriented, and cloud-integrated workflow that matches recent Terraform and HCP capabilities. You’ll need to be familiar with variable sets, workspace/project organization, remote operations, drift detection, secret management, and advanced validation—not just basics and provider configurations.


[1](https://developer.hashicorp.com/terraform/tutorials/certification-004/associate-review-004)
[2](https://developer.hashicorp.com/terraform/tutorials/certification-003/associate-review-003)
