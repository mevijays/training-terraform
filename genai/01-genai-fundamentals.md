# 1 — GenAI Fundamentals

## What is generative AI?

**Generative AI** is a family of machine-learning models that **produce new content** — text, code, images, audio, video — rather than just classifying or predicting from existing content.

| "Traditional" ML | Generative AI |
|---|---|
| "Is this email spam?" | "Write me a polite reply to this email." |
| "What's tomorrow's temperature?" | "Write a weather report for tomorrow." |
| "Detect cats in photos." | "Generate a photo of a cat in a spacesuit." |
| Outputs a label/number | Outputs a paragraph/image/song |

### Why now?

Three things converged ~2017-2022:

1. **The transformer architecture** (2017 paper "Attention Is All You Need") made it practical to train models on huge text corpora.
2. **GPU + data scaling** — turns out, models *keep getting better* the more compute and data you throw at them.
3. **Instruction tuning + RLHF** — making models actually helpful, not just statistically plausible.

### Analogy: a very well-read intern

Picture an intern who has read every public book, every Stack Overflow answer, every well-tagged GitHub repo. They can:
- Recall patterns instantly.
- Mimic styles they've seen.
- Combine ideas from different domains.

But they:
- Don't have a memory of *your* private codebase.
- Confidently make things up sometimes ("hallucinate").
- Have no real-world side effects unless you give them tools.

That's the right mental model for an LLM.

## Common terms you'll hear

| Term | Meaning |
|---|---|
| **LLM** (Large Language Model) | A neural network trained on huge text corpora to predict the next token. The engine behind ChatGPT, Claude, Gemini. |
| **Token** | A chunk of text the model operates on (~3-4 chars on average). "Hello world" is ~2 tokens. |
| **Context window** | How many tokens the model can consider in one pass. 100k-1M+ in modern models. |
| **Prompt** | The text you give the model. |
| **Completion / response** | The text it produces. |
| **System prompt** | Instructions that shape the model's behavior, set by the app. |
| **Temperature** | Knob for randomness. 0 = deterministic; 1+ = more creative. |
| **Hallucination** | When the model fluently produces something false. |
| **Embedding** | A vector representation of text. Used for similarity search. |
| **RAG** (Retrieval-Augmented Generation) | Look up relevant docs at query time, paste them into the prompt. |
| **Fine-tuning** | Further training a base model on your data. Expensive. |
| **Agent** | An LLM with tools it can call (read files, run commands, make HTTP requests). |
| **Multimodal** | A model that handles images / audio / video as well as text. |

## What GenAI is good at

- Drafting code that follows known patterns.
- Translating between languages (HCL → Bicep, English → bash).
- Summarizing long output.
- Explaining unfamiliar code.
- Generating tests, docstrings, README sections.
- Boilerplate.

## What GenAI is NOT good at (yet)

- Truly novel design without enough context.
- Strict mathematical reasoning.
- Knowing what's true in *your* environment.
- Being sure when it's wrong.
- Replacing review and judgment.

## The implication for engineers

GenAI changes **what a junior engineer can accomplish solo** and **how a senior engineer spends their day**. The bottleneck shifts from typing code to:

- Reviewing AI-generated code.
- Writing clear specifications.
- Catching subtle errors and bad assumptions.
- Curating context for the model.

## Navigation

- ⬅ [GenAI index](README.md)
- ➡ [Module 2 — LLMs Explained](02-llms-explained.md)
