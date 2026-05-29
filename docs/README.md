# Terraform Associate (004) — Sample Exam

A practice exam for the **HashiCorp Certified: Terraform Associate (004)** exam (HCTA0-004), in two formats:

| Format | Best for |
|---|---|
| 🎮 **Interactive web simulator** ([index.html](index.html)) | Realistic exam experience with navigator, mark-for-review, submit & scoring. Deploy to GitHub Pages. |
| 📄 **Markdown with reveal-on-click answers** ([exam.md](exam.md)) | Reading on GitHub directly, printing, or studying offline. |

Both contain the **same 60 questions** covering all 9 official 004 objectives.

---

## 🚀 Deploy the interactive simulator on GitHub Pages

The `docs/` folder is a self-contained static site. There are two easy ways to publish it.

### Option A: GitHub Pages from the repo (recommended)

GitHub Pages supports only two source folders: **root** (`/`) or **`/docs`**. This site uses **`/docs`**.

1. Push the repo to GitHub.
2. In the repo, go to **Settings → Pages**.
3. Under **Source**, choose **Deploy from a branch**.
4. Set **Branch** = `main`, **Folder** = `/docs`. Save.
5. After ~30 seconds, your exam will be live at:
   ```
   https://<your-user>.github.io/<repo-name>/
   ```
   (The `/docs` folder becomes the site root — no `/docs/` suffix in the URL.)

### Option B: Run locally

```bash
cd docs/
python3 -m http.server 8080
# then open http://localhost:8080/
```

(Direct `file://` access won't work because the page fetches `questions.json` — needs an HTTP server.)

---

## What the simulator looks like

- **Landing → Exam → Submit → Results → Review**
- One question per screen with the Q text, options (single / multi / true-false), and live progress in the header.
- **Right-side navigator** shows which questions you've answered, marked, or skipped — click any number to jump.
- **Submit modal** warns about unanswered questions before grading.
- **Results page**: animated score ring, **PASS** / **FAIL** banner (fail if < 70%), per-question color grid (green = correct, red = wrong).
- **Review mode** walks you through every question showing your answer vs. the correct answer plus the explanation.
- **Retry** button restarts the exam fresh.

Fully responsive — works on phones and tablets.

---

## Files

```
docs/
├── index.html              ← entry point (open this)
├── questions.json          ← the 60 questions
├── exam.md                 ← same questions, in Markdown
├── README.md               ← this file
├── .nojekyll               ← tells GitHub Pages to skip Jekyll
└── assets/
    ├── style.css           ← all CSS
    └── app.js              ← all JS (no framework, no build step)
```

No external dependencies. No build step. Pure HTML + CSS + JS.

---

## Format match to the real exam

| Real exam | This sample |
|---|---|
| 57 questions in 60 min | 60 questions, untimed |
| Multiple choice + multi-select + true/false | Same mix |
| ~70% to pass (40/57) | Same: aim for **≥ 42/60** |
| English, online proctored | — |

## Question categories (matches official 004 objectives)

| # | Domain | Questions |
|---|---|---|
| 1 | IaC concepts | 3 |
| 2 | Terraform basics / providers | 7 |
| 3 | Core workflow | 8 |
| 4 | Variables, outputs, expressions, dependencies, validation, secrets | 14 |
| 5 | Modules | 6 |
| 6 | State management | 10 |
| 7 | Maintain infrastructure | 4 |
| 8 | HCP Terraform | 6 |
| 9 | Best practices | 2 |

## Disclaimer

Original questions modeled on the official 004 objectives. NOT taken from any live exam. Also use:
- HashiCorp's official samples: https://developer.hashicorp.com/terraform/tutorials/certification-004/associate-questions-004
- Official exam content list: https://developer.hashicorp.com/terraform/tutorials/certification-004/associate-review-004

## Navigation

- ⬅ [Repo README](../README.md)
- ⬅ [Course content](../course-content/README.md)
- ⬅ [Exam prep guide](../course-content/exam-prep.md)
- 📄 [Markdown version of exam](exam.md)
- 🎮 [Launch interactive exam](index.html)
