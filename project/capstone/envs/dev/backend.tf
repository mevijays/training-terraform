# Choose one backend below. Local is fine for learning; HCP is production-grade.

# --- Local backend (default; uncomment and skip the cloud block) ---
# terraform { backend "local" {} }

# --- HCP Terraform integration ---
terraform {
  # Comment this block out to fall back to local state.
  cloud {
    # CHANGE this to your HCP Terraform organization
    organization = "REPLACE-WITH-YOUR-ORG"

    workspaces {
      name = "novapay-dev"
    }
  }
}
