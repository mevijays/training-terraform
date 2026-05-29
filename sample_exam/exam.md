# Terraform Associate (004) — Sample Exam (60 Questions)

Read each question, pick your answer, then click **Answer** to reveal the explanation.

Target: **≥ 42 / 60 (70%)** before attempting the real exam.

---

## Domain 1 — Infrastructure as Code Concepts

### Q1. Which of the following is NOT a benefit of Infrastructure as Code?

A. Repeatable provisioning across environments
B. Version-controlled history of infrastructure changes
C. Automatic patching of operating systems on running VMs
D. Code review of infrastructure changes via pull requests

<details><summary>Answer</summary>

**Correct: C**

IaC describes desired infrastructure state; it doesn't manage in-place patching of running guest OSes — that's a configuration-management or patch-management concern (Ansible, Chef, Azure Update Manager). A, B, and D are classic IaC benefits.
</details>

---

### Q2. Terraform is best described as which type of tool?

A. Imperative configuration-management tool
B. Declarative infrastructure-provisioning tool
C. Runtime container orchestrator
D. Continuous-integration build agent

<details><summary>Answer</summary>

**Correct: B**

Terraform is declarative — you describe desired state and Terraform figures out the API calls. It's provisioning (creating cloud resources), not configuration management (configuring software inside an OS), and it's not an orchestrator or CI runner.
</details>

---

### Q3. (True/False) Terraform can only manage resources in a single cloud provider per configuration.

<details><summary>Answer</summary>

**Correct: False**

A single root module can declare multiple providers (`aws`, `azurerm`, `google`, `github`, etc.). Multi-cloud and multi-provider configurations are a core selling point.
</details>

---

## Domain 2 — Terraform Basics and Providers

### Q4. Where does Terraform download provider binaries to by default?

A. `$HOME/.terraform.d/plugins`
B. `./.terraform/providers/`
C. `/var/lib/terraform/plugins`
D. The system PATH

<details><summary>Answer</summary>

**Correct: B**

After `terraform init`, providers are downloaded into the current working directory's `.terraform/providers/` folder, then locked to specific versions in `.terraform.lock.hcl`.
</details>

---

### Q5. Which version constraint matches `~> 4.10`?

A. Exactly 4.10.0
B. Any version `>= 4.10` and `< 5.0`
C. Any version `>= 4.10.0` and `< 4.11.0`
D. Any version greater than or equal to 4.10

<details><summary>Answer</summary>

**Correct: B**

The pessimistic constraint `~> 4.10` (without a patch component) allows the rightmost specified component to increment. With a third component like `~> 4.10.5`, only patch can grow.
</details>

---

### Q6. You need two AWS provider instances — one in `us-east-1`, one in `us-west-2`. What feature enables this?

A. Workspaces
B. Provider `alias`
C. Multiple `terraform { }` blocks
D. Two separate state files

<details><summary>Answer</summary>

**Correct: B**

Provider `alias` lets you declare multiple instances of the same provider with different config. Resources then opt in with `provider = aws.west`.
</details>

---

### Q7. What is the purpose of `.terraform.lock.hcl`?

A. To prevent two engineers from applying at the same time
B. To record exact provider versions and checksums for reproducible runs
C. To store backend credentials securely
D. To lock the state file during apply

<details><summary>Answer</summary>

**Correct: B**

The lock file pins provider versions and records checksums. Commit it. State locking (A/D) is a backend concern; credentials never go in the lock file.
</details>

---

### Q8. (Multi-select) Which are valid provider source addresses? (Choose two.)

A. `hashicorp/aws`
B. `registry.terraform.io/hashicorp/aws`
C. `aws-provider:5.80.0`
D. `azure/azurerm@latest`

<details><summary>Answer</summary>

**Correct: A and B**

A is the short form (assumes `registry.terraform.io`), B is the fully qualified form. C and D use invalid syntax.
</details>

---

### Q9. Which command upgrades providers to the latest versions allowed by your constraints?

A. `terraform init -upgrade`
B. `terraform plan -upgrade`
C. `terraform providers update`
D. `terraform get`

<details><summary>Answer</summary>

**Correct: A**

`-upgrade` tells `init` to ignore the lock file and bring providers/modules up to the highest version allowed by `required_providers`. The lock file is then rewritten.
</details>

---

### Q10. (True/False) Terraform core itself contains the logic to call AWS, Azure, and GCP APIs.

<details><summary>Answer</summary>

**Correct: False**

Terraform core is provider-agnostic. Cloud-specific logic lives in providers, which run as separate processes and communicate with core over gRPC.
</details>

---

## Domain 3 — Core Workflow

### Q11. Which command does NOT need cloud credentials to run successfully?

A. `terraform plan`
B. `terraform validate`
C. `terraform apply`
D. `terraform destroy`

<details><summary>Answer</summary>

**Correct: B**

`validate` checks syntax and internal consistency — purely local. `plan`/`apply`/`destroy` typically refresh against the cloud and need credentials.
</details>

---

### Q12. What is the correct order of the core Terraform workflow?

A. plan → init → apply
B. validate → init → plan → apply
C. init → plan → apply
D. apply → plan → init

<details><summary>Answer</summary>

**Correct: C**

`init` downloads providers and prepares the backend, `plan` computes the diff, `apply` executes it. `validate` is optional but typically between `init` and `plan`.
</details>

---

### Q13. What does the `-/+` symbol in `terraform plan` output indicate?

A. Update in place
B. Create the resource
C. Destroy and recreate (forced replacement)
D. Drift detected

<details><summary>Answer</summary>

**Correct: C**

`-/+` means destroy and recreate — usually because an immutable attribute changed. `+` is create, `~` is update in place, `-` is destroy.
</details>

---

### Q14. You want to apply exactly what was shown in a plan, with no chance of new changes appearing. What do you do?

A. Run `terraform apply -auto-approve` immediately after `terraform plan`
B. Save the plan with `terraform plan -out=tfplan`, then `terraform apply tfplan`
C. Use `terraform apply -refresh-only`
D. Run `terraform apply -target=<resource>`

<details><summary>Answer</summary>

**Correct: B**

A saved plan file locks in the actions. `apply tfplan` executes exactly that — no re-planning, no refresh, no prompt. This is the recommended CI/CD pattern.
</details>

---

### Q15. What does `terraform fmt -recursive` do?

A. Recursively destroys all resources
B. Rewrites all `.tf` files in the current directory and subdirectories in canonical style
C. Recursively validates all child modules
D. Re-formats the state file

<details><summary>Answer</summary>

**Correct: B**

`fmt` is the formatter. `-recursive` makes it descend into subdirectories. It only touches `.tf` files on disk.
</details>

---

### Q16. Which command would you run after adding a new provider to `required_providers`?

A. `terraform plan`
B. `terraform init`
C. `terraform validate`
D. `terraform refresh`

<details><summary>Answer</summary>

**Correct: B**

`init` downloads the new provider. Without re-init, `plan` will error with "missing provider plugin."
</details>

---

### Q17. (Multi-select) Which of these can `terraform apply` do? (Choose two.)

A. Re-apply a saved plan file exactly as planned
B. Run a fresh plan and prompt for approval before changes
C. Modify the source `.tf` files
D. Delete the state file backend configuration

<details><summary>Answer</summary>

**Correct: A and B**

`apply` either re-plans (prompting) or applies a saved plan file. It never edits source files (C) or backend config (D).
</details>

---

### Q18. (True/False) `terraform destroy` is equivalent to `terraform apply -destroy`.

<details><summary>Answer</summary>

**Correct: True**

Since Terraform 0.15.2, `terraform destroy` is an alias for `terraform apply -destroy`. Same outcome, same prompts, same state update.
</details>

---

## Domain 4 — Configuration: variables, outputs, expressions, dependencies, validation, secrets

### Q19. What is the precedence of variable values, highest to lowest?

A. `default` → env var → tfvars file → `-var`
B. `-var` → `-var-file` → auto.tfvars → env var → `default`
C. env var → `-var` → tfvars → `default`
D. `default` → tfvars → `-var-file` → env var → `-var`

<details><summary>Answer</summary>

**Correct: B**

Highest wins. CLI `-var` beats files, files beat env vars (`TF_VAR_*`), env vars beat the variable block's `default`.
</details>

---

### Q20. Which variable type is correct for `["10.0.1.0/24", "10.0.2.0/24"]`?

A. `string`
B. `list(string)`
C. `set(any)`
D. `map(string)`

<details><summary>Answer</summary>

**Correct: B**

An ordered list of strings. A `set` would also accept it but loses order; `list(string)` is the most precise type.
</details>

---

### Q21. What does this expression return when `var.env = "prod"`?

```hcl
var.env == "prod" ? "GRS" : "LRS"
```

A. `"prod"`
B. `"LRS"`
C. `"GRS"`
D. error — invalid syntax

<details><summary>Answer</summary>

**Correct: C**

A ternary: condition true → first value, false → second. `var.env == "prod"` is true, so `"GRS"`.
</details>

---

### Q22. Which function would you use to combine two maps, with the second overriding overlapping keys?

A. `concat()`
B. `merge()`
C. `union()`
D. `tomap()`

<details><summary>Answer</summary>

**Correct: B**

`merge(map_a, map_b)` combines, with later arguments overriding earlier on conflict. `concat` is for lists.
</details>

---

### Q23. What does `sensitive = true` on an output do?

A. Encrypts the value in the state file
B. Redacts the value from CLI output
C. Prevents the value from being stored in state
D. Both A and B

<details><summary>Answer</summary>

**Correct: B**

It hides the value from CLI display. The value is still in state, unencrypted. For true secret hygiene use `ephemeral` and write-only arguments (Terraform 1.10+).
</details>

---

### Q24. What does this `validation` block check?

```hcl
variable "env" {
  type = string
  validation {
    condition     = contains(["dev","stage","prod"], var.env)
    error_message = "env must be dev, stage, or prod."
  }
}
```

A. That the variable is set
B. That the variable's value is one of three allowed strings
C. That the cloud accepts the value
D. That the variable is marked sensitive

<details><summary>Answer</summary>

**Correct: B**

A `validation` block runs at plan time with `var.env` as input. `contains(list, x)` returns true if `x` is in `list`. Fails the plan otherwise.
</details>

---

### Q25. Where is a `precondition` block defined?

A. Top-level in a `.tf` file
B. Inside a `resource`, `data`, or `output` `lifecycle { }` block
C. Inside a `variable` block
D. Inside `terraform { }`

<details><summary>Answer</summary>

**Correct: B**

`precondition` and `postcondition` live inside `lifecycle`. `validation` lives inside `variable`. `check` is the only one at top-level.
</details>

---

### Q26. Which lifecycle meta-argument creates the new resource BEFORE destroying the old one during a replacement?

A. `prevent_destroy`
B. `ignore_changes`
C. `create_before_destroy`
D. `replace_triggered_by`

<details><summary>Answer</summary>

**Correct: C**

`create_before_destroy = true` flips the default destroy-then-create order. Useful for zero-downtime replacements where the resource supports running two instances briefly.
</details>

---

### Q27. What happens if you try to `terraform destroy` a resource with `prevent_destroy = true`?

A. The destroy succeeds with a warning
B. The destroy succeeds after a 10-second pause
C. Terraform errors out and does not destroy the resource
D. Terraform prompts you twice for confirmation

<details><summary>Answer</summary>

**Correct: C**

`prevent_destroy` makes any plan that would destroy the resource fail outright. To actually destroy, you remove the lifecycle rule first, apply, then destroy.
</details>

---

### Q28. (New in 004) What is a write-only argument (`*_wo`)?

A. An argument that can only be set once and never changed
B. A resource attribute that is sent to the API but not stored in state
C. A read-only computed output
D. A deprecated form of `sensitive = true`

<details><summary>Answer</summary>

**Correct: B**

Write-only arguments (e.g. `administrator_password_wo`) are passed to the cloud API but never persisted in state. Paired with `*_wo_version`, they let you rotate secrets without leaking them.
</details>

---

### Q29. Where should you reference a Vault-stored secret to avoid persisting it in state?

A. As an input variable with `default`
B. Via a `data` source for the secret, passing to a regular resource attribute
C. Via an `ephemeral` resource feeding a `_wo` (write-only) argument
D. As an environment variable read by the provider

<details><summary>Answer</summary>

**Correct: C**

`ephemeral` resources (Terraform 1.10+) are never written to state. Passing them into a write-only argument means the secret reaches the cloud but never lands on disk in the state file.
</details>

---

### Q30. Terraform creates resources in dependency order. Which two ways can you express a dependency?

A. `depends_on` and resource references
B. `provider` and `version`
C. `for_each` and `count`
D. `lifecycle` and `metadata`

<details><summary>Answer</summary>

**Correct: A**

References (e.g. `azurerm_resource_group.x.name` inside another resource) create implicit dependencies. `depends_on = [...]` creates explicit ones, used when no reference exists.
</details>

---

### Q31. Given:

```hcl
resource "aws_instance" "web" {
  count = 3
  ami   = "ami-1234"
}
```

What is the address of the second instance?

A. `aws_instance.web[2]`
B. `aws_instance.web[1]`
C. `aws_instance.web.2`
D. `aws_instance.web["second"]`

<details><summary>Answer</summary>

**Correct: B**

`count` produces a zero-indexed list. Second instance = index 1. `for_each` would let you use string keys like `["second"]`.
</details>

---

### Q32. (Multi-select) Which arguments are valid `meta-arguments` on any resource? (Choose three.)

A. `count`
B. `for_each`
C. `lifecycle`
D. `provider`
E. `subnet_id`

<details><summary>Answer</summary>

**Correct: A, B, C, D (and provider)**

Meta-arguments are reserved on every resource: `count`, `for_each`, `lifecycle`, `provider`, `depends_on`. `subnet_id` is a resource-specific argument, not a meta-argument.
</details>

---

## Domain 5 — Modules

### Q33. A module's source is `git::https://github.com/me/tf-modules.git//vnet?ref=v1.2.0`. Where does `version = "1.2.0"` go?

A. Inside the module call block, as `version = "1.2.0"`
B. As `?ref=v1.2.0` in the URL
C. In a separate `version` file
D. In `.terraform.lock.hcl`

<details><summary>Answer</summary>

**Correct: B**

For Git sources, version is encoded as `?ref=` (tag/branch/SHA). The `version = ...` argument inside the module block is only valid for **Terraform Registry** sources.
</details>

---

### Q34. Where can a Terraform module be sourced from? (Multi-select — choose three.)

A. Local file path
B. Terraform Registry (public or private)
C. Git over HTTPS or SSH
D. A Docker container registry

<details><summary>Answer</summary>

**Correct: A, B, C**

Terraform module sources include: local paths, Terraform Registry, Git, HTTP archives, S3, GCS, Mercurial. Docker registries are not a module source.
</details>

---

### Q35. (True/False) A variable declared inside a child module is automatically accessible in the root module.

<details><summary>Answer</summary>

**Correct: False**

Variables in child modules are scoped to that module. The root passes values explicitly via `module.foo { ... }`. There is no global variable scope.
</details>

---

### Q36. To access output `vnet_id` from a child module call `module.network`, you reference it as:

A. `module.network.vnet_id`
B. `network.vnet_id`
C. `output.network.vnet_id`
D. `var.network.vnet_id`

<details><summary>Answer</summary>

**Correct: A**

`module.<MODULE_NAME>.<OUTPUT_NAME>` is the syntax. The output must be explicitly declared in the child module.
</details>

---

### Q37. You publish a private module to HCP Terraform. What's the recommended source format?

A. `git::https://github.com/me/repo.git`
B. `app.terraform.io/<ORG>/<MODULE>/<PROVIDER>`
C. `https://app.terraform.io/v2/modules/...`
D. `./modules/<MODULE>`

<details><summary>Answer</summary>

**Correct: B**

Private registry modules in HCP Terraform follow `app.terraform.io/<ORG>/<NAME>/<PROVIDER>` and pin version via `version = "X.Y.Z"`.
</details>

---

### Q38. What is the minimum recommended way to use a community module from the public Terraform Registry safely?

A. Always use `latest`
B. Pin a specific version with `version = "X.Y.Z"` or a pessimistic constraint
C. Fork the repo and reference the fork by Git URL
D. Vendor the module into your repo as a local source

<details><summary>Answer</summary>

**Correct: B**

Pinning prevents accidental breakage when the module author publishes a major version. Forking (C) and vendoring (D) are sometimes done for extra control but pinning is the minimum.
</details>

---

## Domain 6 — State Management

### Q39. By default, Terraform stores state in which location?

A. A managed HashiCorp service
B. The local file `terraform.tfstate` in the working directory
C. The provider's cloud storage
D. The lock file `.terraform.lock.hcl`

<details><summary>Answer</summary>

**Correct: B**

The default backend is `local`, which writes `terraform.tfstate` (and `.backup`) next to your `.tf` files. Fine for learning, not for teams.
</details>

---

### Q40. Why is state locking important?

A. To encrypt state at rest
B. To prevent two concurrent `apply` operations from corrupting state
C. To audit who modified state
D. To compress state for faster reads

<details><summary>Answer</summary>

**Correct: B**

Locking serializes write operations on shared state. Without it, two simultaneous applies could each overwrite the other's changes.
</details>

---

### Q41. Which backend natively supports state locking? (Multi-select — choose three.)

A. `azurerm` (Blob lease)
B. `s3` (with DynamoDB or native S3 conditional writes)
C. `local`
D. `gcs`

<details><summary>Answer</summary>

**Correct: A, B, D**

`azurerm` uses blob leases, `s3` uses DynamoDB or native conditional writes, `gcs` uses object metadata. `local` only locks within one machine — not safe for teams.
</details>

---

### Q42. Why are variables NOT allowed inside a `backend` block?

A. They would be a security risk
B. The backend is initialized before variable values are known
C. HashiCorp removed that feature in 1.0
D. It's a syntax limitation that will be lifted in 1.13

<details><summary>Answer</summary>

**Correct: B**

`init` configures the backend before any variables exist. Workaround: partial configuration plus `-backend-config="key=value"` flags or files.
</details>

---

### Q43. You renamed a resource in code from `azurerm_resource_group.rg` to `azurerm_resource_group.main`. What's the safest way to update state without destroying the cloud resource?

A. Run `terraform apply` — it'll just rename it
B. Add a `moved { from = ..., to = ... }` block
C. Delete the state file and re-import
D. Run `terraform refresh`

<details><summary>Answer</summary>

**Correct: B**

A `moved` block tells Terraform to update its state mapping without destroying or re-creating. Once everyone has applied, you can remove the block.
</details>

---

### Q44. (New in 004) The `removed` block lets you:

A. Forcibly delete a resource regardless of state
B. Stop managing a resource (optionally without destroying it)
C. Mark a resource as deprecated
D. Remove a provider entirely

<details><summary>Answer</summary>

**Correct: B**

`removed { from = ... lifecycle { destroy = false } }` removes the resource from state without deleting it from the cloud. Set `destroy = true` to actually destroy.
</details>

---

### Q45. The modern equivalent of `terraform refresh` is:

A. `terraform plan -refresh-only` then `terraform apply -refresh-only`
B. `terraform state pull`
C. `terraform init -upgrade`
D. `terraform reconcile`

<details><summary>Answer</summary>

**Correct: A**

`terraform refresh` is deprecated as a standalone command. Use `plan -refresh-only` to preview the drift, then `apply -refresh-only` to update state.
</details>

---

### Q46. (Multi-select) Which information lives in `terraform.tfstate`? (Choose three.)

A. Provider versions in use
B. Resource attributes returned by the cloud at last apply
C. Mappings from resource addresses to real-world IDs
D. The current branch of your Git repo

<details><summary>Answer</summary>

**Correct: A, B, C**

State holds resource mappings, the cached attribute snapshot, and metadata like Terraform/provider versions and a lineage UUID. Git information is not in state.
</details>

---

### Q47. Which command tells you all addresses present in state?

A. `terraform state list`
B. `terraform show`
C. `terraform state show`
D. `terraform list`

<details><summary>Answer</summary>

**Correct: A**

`state list` returns the address namespace. `show <address>` returns one resource's full attributes. `terraform show` (no subcommand) prints the full state.
</details>

---

### Q48. Drift detection answers which question?

A. Are my modules up to date?
B. Does the real cloud state still match what's in my state file?
C. Have my providers changed major version?
D. Is my state file corrupted?

<details><summary>Answer</summary>

**Correct: B**

Drift = state file says one thing, real cloud says another. `plan -refresh-only` and HCP Terraform's drift detection both surface this.
</details>

---

## Domain 7 — Maintain Infrastructure (import, logging)

### Q49. Which of the following correctly imports an existing Azure RG into Terraform state?

A. `terraform state import azurerm_resource_group.x /subscriptions/.../rg-x`
B. `terraform import azurerm_resource_group.x /subscriptions/.../rg-x`
C. `terraform pull azurerm_resource_group.x`
D. `az import azurerm_resource_group.x ...`

<details><summary>Answer</summary>

**Correct: B**

`terraform import <ADDRESS> <CLOUD_ID>`. The newer alternative is an `import { }` block in code, which can be combined with `-generate-config-out=` to scaffold the resource block.
</details>

---

### Q50. (New in 1.5) The `import` block + `-generate-config-out=` does what?

A. Auto-generates the `resource` block by reading cloud state
B. Imports without needing credentials
C. Imports across regions
D. Imports without modifying state

<details><summary>Answer</summary>

**Correct: A**

`terraform plan -generate-config-out=generated.tf` produces a starter `resource` block based on what's in the cloud. You then refine and commit it.
</details>

---

### Q51. To see detailed provider/HTTP debugging during a run, set:

A. `TF_DEBUG=1`
B. `TF_LOG=DEBUG` (or TRACE)
C. `terraform --verbose`
D. `TF_VERBOSE=1`

<details><summary>Answer</summary>

**Correct: B**

`TF_LOG` accepts `TRACE`, `DEBUG`, `INFO`, `WARN`, `ERROR`, `OFF`. Set `TF_LOG_PATH=tf.log` to write to a file. TRACE may include secrets — treat the log file as sensitive.
</details>

---

### Q52. Which is NOT a valid `TF_LOG` value?

A. `TRACE`
B. `INFO`
C. `VERBOSE`
D. `OFF`

<details><summary>Answer</summary>

**Correct: C**

Valid: `TRACE`, `DEBUG`, `INFO`, `WARN`, `ERROR`, `OFF`. `VERBOSE` is not recognized — it's silently ignored.
</details>

---

## Domain 8 — HCP Terraform

### Q53. In HCP Terraform, the relationship between organizations, projects, and workspaces is:

A. Workspace → Organization → Project
B. Organization → Project → Workspace
C. Project → Workspace → Organization
D. Workspace and Project are the same thing

<details><summary>Answer</summary>

**Correct: B**

Top to bottom: Organization (tenant) → Project (grouping with shared vars/RBAC) → Workspace (one state file).
</details>

---

### Q54. Which `terraform { }` block enables HCP Terraform integration in a config?

A. `backend "remote" { }`
B. `cloud { }`
C. `hcp { }`
D. `workspace { }`

<details><summary>Answer</summary>

**Correct: B**

`cloud { organization = "x"; workspaces { name = "y" } }` is the modern integration block. `backend "remote"` still works but is legacy.
</details>

---

### Q55. A workspace's execution mode determines where `plan`/`apply` runs. Which is the recommended default?

A. Local
B. Remote
C. Agent
D. Manual

<details><summary>Answer</summary>

**Correct: B**

Remote = runs in HCP Terraform's infrastructure with logs, history, and policy enforcement. Local and Agent modes exist for specific needs (migrations, private cloud reachability).
</details>

---

### Q56. A `Variable Set` in HCP Terraform is best used for:

A. Reusable groups of variables applied across multiple workspaces
B. Per-run dynamic variables
C. Encrypted state files
D. Pipeline triggers

<details><summary>Answer</summary>

**Correct: A**

Variable sets bundle variables (often cloud credentials or common tags) and attach to many workspaces. They keep credentials in one place.
</details>

---

### Q57. (Multi-select) Sentinel/OPA policy enforcement levels in HCP Terraform are: (Choose three.)

A. `advisory`
B. `soft-mandatory`
C. `hard-mandatory`
D. `panic`

<details><summary>Answer</summary>

**Correct: A, B, C**

`advisory` logs but doesn't block. `soft-mandatory` blocks but a privileged user can override. `hard-mandatory` blocks with no override. `panic` is not a level.
</details>

---

### Q58. (True/False) HCP Terraform's CLI workspaces and `terraform workspace` (local) workspaces are the same concept.

<details><summary>Answer</summary>

**Correct: False**

They are different concepts. CLI `terraform workspace` creates extra local state files in one config. HCP Terraform workspaces are remote, full-state, project-scoped entities.
</details>

---

## Domain 9 — Best Practices

### Q59. (Multi-select) Which are best practices? (Choose three.)

A. Pin Terraform and provider versions
B. Commit `terraform.tfstate` to Git
C. Use remote state with locking for team work
D. Use OIDC federation for CI → cloud auth

<details><summary>Answer</summary>

**Correct: A, C, D**

Pinning versions, using remote state, and OIDC are recommended. Committing state to Git leaks secrets and corrupts collaboration.
</details>

---

### Q60. You have one giant Terraform config that manages dev, stage, and prod for a complex app. The team complains about long plan times and risky applies. The best refactor is:

A. Run `terraform apply -parallelism=100`
B. Split into one state file per environment, each its own root module
C. Switch from Terraform to ARM templates
D. Disable state locking

<details><summary>Answer</summary>

**Correct: B**

Smaller blast radius, faster plans, independent applies, separate permissions. The typical layout is `envs/{dev,stage,prod}/` each with its own backend and its own state.
</details>

---

## Score yourself

| Score | Verdict |
|---|---|
| 54-60 (90%+) | Strong — book the real exam |
| 42-53 (70-89%) | Likely to pass — review weak topics |
| 35-41 (60-69%) | More study needed; revisit weak modules |
| < 35 (< 60%) | Work through the [course content](../course-content/README.md) again |

## Navigation

- ⬅ [Sample exam index](README.md)
- ⬅ [Course content](../course-content/README.md)
- ⬅ [Exam prep guide](../course-content/exam-prep.md)
- 🎯 [Capstone project](../project/README.md)
