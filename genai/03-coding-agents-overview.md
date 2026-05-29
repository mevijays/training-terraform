# 3 — Coding Agents Overview

A landscape tour of the AI coding tools most relevant to Terraform / infrastructure engineers in 2026.

## What's a "coding agent"?

A **coding agent** is an LLM-driven assistant that can read, write, and run code on your behalf. Compared to a plain chat box, an agent has:

- File-system access (read/write your codebase).
- A shell or tool API (run commands, run tests, query clouds).
- A loop that lets it work for many steps without each step needing human input.

That last point — the loop — is what separates **agents** from **autocomplete**.

## The main tools, side by side

### GitHub Copilot

**Vendor:** GitHub (Microsoft) — powered by various models including OpenAI's GPT family and Anthropic's Claude family.

**Form factor:** IDE plugin (VS Code, JetBrains, Vim), chat panel, code review on GitHub PRs.

**Strengths:**
- Tight VS Code integration.
- Excellent inline autocomplete for almost any language.
- "Copilot Workspace" lets it plan multi-file changes.
- Native PR review and code suggestions inside GitHub.
- Enterprise data controls — your code doesn't train the model.

**For Terraform:** great at completing `resource` blocks once you've typed a few lines, generating variable validations, drafting README tables.

### Claude Code

**Vendor:** Anthropic. Uses Claude models (Opus, Sonnet, Haiku).

**Form factor:** CLI in your terminal, with optional IDE integrations. Lives where your repo lives.

**Strengths:**
- Strongest model family for long-context, multi-file edits.
- Designed agent-first — it plans, edits, runs commands, reads output, iterates.
- First-class skills (reusable instruction packs), MCP servers (custom tool plugins), hooks, and sub-agents.
- Available in CLI, JetBrains/VS Code extensions, a desktop app, and via the web on claude.ai/code.

**For Terraform:** especially strong at multi-file refactors, writing tests for modules, and reading provider docs to draft new resources you've never used before.

### Cursor

**Vendor:** Anysphere.

**Form factor:** A fork of VS Code with deep AI integration.

**Strengths:**
- Best-in-class inline chat ("Cmd-K").
- Multi-file "Composer" workflow.
- Cursor Rules let you encode team conventions.
- Frequently the fastest IDE for "explain this codebase to me."

**For Terraform:** good for "rename this module across the repo" or "convert these resources to use `for_each`".

### Google Antigravity

**Vendor:** Google.

**Form factor:** A development environment from Google built around Gemini models, surfacing an agent layer on top of an IDE.

**Strengths:**
- Massive context window (Gemini's strength).
- Good at codebase-wide analysis.
- Tight integration with Google Cloud tools.

**For Terraform:** useful when working with very large monorepos, or in GCP-heavy environments.

### Windsurf

**Vendor:** Codeium.

**Form factor:** IDE with built-in "Cascade" agent flow.

**Strengths:**
- Aggressive multi-step editing.
- Easy on-prem / self-hosted deployment story.

### Aider, Continue.dev, etc.

**Form factor:** Open-source CLI / VS Code extensions. Bring your own model API key.

**Strengths:**
- Total control over which model you call.
- Inexpensive if you have an existing API key.
- Good for teams skeptical of vendor lock-in.

## How to choose

| If you want… | Pick |
|---|---|
| The lowest-friction inline autocomplete in your IDE | GitHub Copilot |
| The most capable agent in your terminal | Claude Code |
| The most capable agent in your IDE | Cursor |
| Massive-context cross-repo analysis | Google Antigravity |
| Self-hosted, open-source | Aider + your own model |

Most teams end up using **two**: one for inline completion (Copilot or Cursor's tab) and one for autonomous edits (Claude Code or Cursor Composer).

## How a coding agent helps a Terraform engineer specifically

Day-in-the-life examples:

1. **"Draft a module for an Azure Front Door with WAF, using the same conventions as our other modules in `modules/`."** The agent reads existing modules, infers your conventions (variable naming, output style, tagging), and produces a new one consistent with them.
2. **"Run `terraform plan` and explain anything that's `~ update in-place`."** The agent executes the command, reads the output, and writes a human-readable summary you can paste into your PR description.
3. **"Add validation to every variable in this module."** The agent reads each `variable` block and adds appropriate `validation` blocks.
4. **"This PR has a `-/+ replace` on the prod database. Why? Should we worry?"** The agent reads the diff, inspects state, looks up the forced-replacement attribute in the provider docs, and gives you a real answer.
5. **"Migrate this codebase from `count` to `for_each` using `moved` blocks."** The agent does the refactor module-by-module with `moved` blocks so no resource is destroyed.

## What agents are bad at (still)

- Knowing what's secret. Always review what gets pasted into context.
- Knowing your team's preferences without being told. Use Rules / CLAUDE.md / Cursor Rules.
- Strict mathematical correctness ("does this CIDR fit inside that one?"). Verify.
- Knowing when something is unsafe. Ask for explicit confirmation before destructive operations.

## Where this goes next

Expect 2026-2027 to be the year of:

- Agents that work asynchronously (PR posted → background agent fixes lint, writes tests, opens PR for review).
- Cloud-resident agents that can `terraform apply` in a sandbox and report back.
- Voice / chat ops integrations ("Hey Claude, what changed in prod last week?").

## Navigation

- ⬅ [Module 2 — LLMs Explained](02-llms-explained.md)
- ➡ [Module 4 — GenAI in Terraform Workflows](04-genai-in-terraform.md)
