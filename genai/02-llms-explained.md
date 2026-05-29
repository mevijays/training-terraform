# 2 — LLMs Explained (Intuition, Not Math)

## What an LLM actually does

A **Large Language Model** does one thing: given some text, predict the most likely next chunk of text.

That's it.

Everything else — chat, code completion, document Q&A — is built by feeding the model the right inputs and reading its outputs in clever ways.

### Analogy: incredibly aggressive autocomplete

Your phone's autocomplete suggests the next word.

An LLM is the same idea, but:
- Trained on billions of words across the open internet.
- Predicts the next token, then the next, then the next — for thousands of tokens at a time.
- Pays attention to *all* the words before, not just the last one.

That's why it can write a whole working Terraform module: it's "autocompleting" the rest of the file, having "seen" a few hundred thousand similar files during training.

## The transformer

Modern LLMs are based on the **transformer architecture**. The key idea is **attention** — for every token the model produces, it can selectively look back at any previous token in its context and decide how much that token matters.

Compare:

| Older architecture (RNN) | Transformer |
|---|---|
| Reads left to right, one word at a time | Looks at all words at once |
| Forgets things from earlier in the input | "Attends" to anything relevant |
| Hard to parallelize | Embarrassingly parallel on GPUs |

This is why transformers can hold a 100,000-token codebase in one prompt and still understand which function calls which.

## Tokens, not words

LLMs see **tokens**, not words. A token is roughly 3-4 characters. "Terraform" might be 2 tokens; "Hello" is 1; whitespace counts. This matters because:

- Cost is per token.
- Context limits are in tokens.
- The model is doing math on token IDs, not English.

## Training, in three stages

1. **Pre-training** — model is shown trillions of tokens of internet text. Learns grammar, facts, code patterns, jokes, prejudices — everything in the data, good and bad.
2. **Supervised fine-tuning** — humans write good responses to a set of prompts. Model learns to imitate them. Now it can follow instructions.
3. **RLHF / preference tuning** — humans rank pairs of model outputs. Model learns *what people prefer*, including helpfulness and safety.

After all that, you have a **chat model** — not a raw "predict next token" model, but one shaped to be a helpful assistant.

## Why LLMs hallucinate

The model's job is to produce **plausible-sounding text**. It has no separate "truth" signal. If your prompt asks about something the model doesn't know:

- It can't say "I don't know" by default — that's a learned behavior.
- It will produce something that *looks* like a correct answer.

How to reduce hallucination:

- **Ground the model** in real data via RAG (paste the docs into the prompt).
- **Give it tools** — let it actually run a command or look up a fact.
- **Ask for citations** — and verify them.
- **Use lower temperature** for factual tasks.

## Context window — the most important number

The **context window** is how much input the model can consider at once.

- Old GPT-3.5 (2022): 4,000 tokens.
- GPT-4 (2023): 8k → 32k → 128k.
- Claude 3.5 Sonnet (2024): 200k.
- Claude 4.x (2025-2026): 200k+, with extended caching.
- Gemini 1.5 Pro: 1-2 million tokens.

For a coding agent, the context window is how much of your codebase it can read at once.

## Frontier model families (as of mid-2026)

| Family | Vendor | Strengths |
|---|---|---|
| **Claude** (Opus, Sonnet, Haiku) | Anthropic | Coding, long context, careful reasoning |
| **GPT** (5, 4o) | OpenAI | Broad capability, image understanding |
| **Gemini** (Pro, Flash) | Google | Massive context, multimodal |
| **Llama** (open weights) | Meta | Self-hostable, customizable |
| **Mistral**, **Qwen**, **DeepSeek** | various | Cost-efficient, strong on code in some sizes |

For Terraform / DevOps tasks, all of the top models work well. Differences become significant for very large codebases (favor long-context models) and for autonomous agents (favor models with strong tool-use training, currently Claude leads).

## The "agent" leap

A bare LLM is a function: text in, text out. An **agent** is an LLM that can:

1. Read its environment (files, tickets, monitoring data).
2. Decide on an action.
3. Call a tool to do it (write a file, run a command, post to Slack).
4. Observe the result.
5. Loop until done.

That's what coding agents like Claude Code do. The next module compares the main ones.

## Navigation

- ⬅ [Module 1 — GenAI Fundamentals](01-genai-fundamentals.md)
- ➡ [Module 3 — Coding Agents Overview](03-coding-agents-overview.md)
