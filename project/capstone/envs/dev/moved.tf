# Example of refactoring with a `moved` block (Phase 7).
# Imagine we originally called the network module "vnet"; now we call it "network".
# This block tells Terraform to update state in place — no destroy/create.
#
# When you actually rename, uncomment the block, run apply once, then delete it.
#
# moved {
#   from = module.vnet
#   to   = module.network
# }
