/* Exam Simulator — engine */
(() => {
  const $ = (sel, root = document) => root.querySelector(sel);
  const $$ = (sel, root = document) => Array.from(root.querySelectorAll(sel));

  // ---- State ----
  const state = {
    exam: null,           // loaded exam object
    answers: {},          // qid -> [selected option ids]
    marked: new Set(),    // qid set marked for review
    current: 0,
    submitted: false,
    review: false,
  };

  // ---- Helpers ----
  function fetchJSON(url) {
    return fetch(url).then(r => {
      if (!r.ok) throw new Error(`Failed to load ${url}`);
      return r.json();
    });
  }

  function arraysEqual(a, b) {
    if (a.length !== b.length) return false;
    const aSorted = [...a].sort();
    const bSorted = [...b].sort();
    return aSorted.every((v, i) => v === bSorted[i]);
  }

  function isAnswered(qid) {
    return state.answers[qid] && state.answers[qid].length > 0;
  }

  // ---- Landing ----
  function renderLanding(manifest) {
    const app = $("#app");
    const exams = manifest.exams;
    app.innerHTML = `
      <div class="landing">
        <h1>${manifest.title}</h1>
        <p class="lead">${manifest.subtitle}</p>
        <div class="exam-picker">
          ${exams.map(e => `
            <div class="exam-card" data-file="${e.file}">
              <h3>${e.name}</h3>
              <p>${e.description}</p>
              <div class="meta">
                <span>${e.questions} questions</span>
                <span>${e.passingScore}% to pass</span>
                ${e.timeLimit ? `<span>${e.timeLimit} min</span>` : `<span>Untimed</span>`}
              </div>
            </div>
          `).join("")}
        </div>
        <p style="color: var(--text-dim); font-size: 0.85rem; margin-top: 32px; max-width: 600px;">
          ${manifest.disclaimer || ""}
        </p>
      </div>
    `;
    $$(".exam-card").forEach(card => {
      card.addEventListener("click", () => loadExam(card.dataset.file));
    });
  }

  // ---- Load exam ----
  function loadExam(file) {
    fetchJSON(file)
      .then(exam => {
        state.exam = exam;
        state.answers = {};
        state.marked = new Set();
        state.current = 0;
        state.submitted = false;
        state.review = false;
        renderExam();
      })
      .catch(err => {
        $("#app").innerHTML = `<div class="container"><p style="color:var(--danger)">Failed to load exam: ${err.message}</p></div>`;
      });
  }

  // ---- Render exam shell + question ----
  function renderExam() {
    const exam = state.exam;
    $("#app").innerHTML = `
      <div class="exam-header">
        <h1>${exam.title}</h1>
        <div class="progress-info">
          <div>Question <strong id="qnum">${state.current + 1}</strong> of <strong>${exam.questions.length}</strong></div>
          <div>Answered <strong id="ansCount">0</strong> / ${exam.questions.length}</div>
        </div>
      </div>
      <div class="exam-body">
        <div id="qarea"></div>
        <aside class="nav-panel">
          <h3>Question navigator</h3>
          <div class="nav-grid" id="navGrid"></div>
          <div class="nav-legend">
            <div><span class="swatch" style="background:var(--primary)"></span> Answered</div>
            <div><span class="swatch" style="background:var(--warning-tint);border:1px solid var(--warning)"></span> Marked for review</div>
            <div><span class="swatch" style="background:var(--surface);border:1px solid var(--border)"></span> Unanswered</div>
          </div>
          <div class="summary-stats" id="summaryStats"></div>
          <div style="margin-top: 16px;">
            <button class="btn btn-success" style="width: 100%;" id="submitBtn">Submit Exam</button>
          </div>
        </aside>
      </div>
    `;
    renderQuestion();
    renderNavGrid();
    $("#submitBtn").addEventListener("click", openSubmitModal);
  }

  function renderQuestion() {
    const exam = state.exam;
    const q = exam.questions[state.current];
    const userAns = state.answers[q.id] || [];
    const inputType = q.type === "single" || q.type === "truefalse" ? "radio" : "checkbox";
    const inputName = `q-${q.id}`;

    // In review mode, mark each option with correct / wrong / selected classes inline
    // (we can't do it after innerHTML is set because the explanation block above us
    //  needs the classes too for visual consistency).
    const optionClass = (optId) => {
      const cls = [];
      if (userAns.includes(optId)) cls.push("selected");
      if (state.review) {
        if (q.correct.includes(optId)) cls.push("correct");
        else if (userAns.includes(optId)) cls.push("wrong");
        cls.push("disabled");
      }
      return cls.join(" ");
    };

    const qarea = $("#qarea");
    qarea.innerHTML = `
      <article class="question-card">
        <div class="question-header">
          <span class="question-number">Question ${state.current + 1}</span>
          ${q.domain ? `<span class="question-tag">${q.domain}</span>` : ""}
        </div>
        <div class="question-type">${prettyType(q.type)}</div>
        <div class="question-stem">${renderInline(q.stem)}</div>
        ${q.stemCode ? `<pre><code>${escapeHtml(q.stemCode)}</code></pre>` : ""}
        <div class="options" id="opts">
          ${q.options.map(o => `
            <label class="option ${optionClass(o.id)}" data-opt="${o.id}">
              <input type="${inputType}" name="${inputName}" value="${o.id}" ${userAns.includes(o.id) ? "checked" : ""} ${state.review ? "disabled" : ""}>
              <span class="opt-label">${o.id}.</span>
              <span class="opt-text">${renderInline(o.text)}</span>
            </label>
          `).join("")}
        </div>
        ${state.review ? renderExplanation(q, userAns) : ""}
        ${state.review ? "" : `
          <div class="question-controls">
            <div class="controls-left">
              <button class="btn btn-secondary" id="prevBtn" ${state.current === 0 ? "disabled" : ""}>← Previous</button>
              <button class="btn btn-warning" id="markBtn">${state.marked.has(q.id) ? "Unmark" : "Mark for review"}</button>
            </div>
            <div class="controls-right">
              <button class="btn btn-primary" id="nextBtn" ${state.current === exam.questions.length - 1 ? "disabled" : ""}>Next →</button>
            </div>
          </div>
        `}
        ${state.review ? `
          <div class="question-controls" style="margin-top: 28px;">
            <div class="controls-left">
              <button class="btn btn-secondary" id="prevBtn" ${state.current === 0 ? "disabled" : ""}>← Previous</button>
            </div>
            <div class="controls-right">
              <button class="btn btn-primary" id="nextBtn" ${state.current === exam.questions.length - 1 ? "disabled" : ""}>Next →</button>
              <button class="btn btn-secondary" id="backResultsBtn">Back to results</button>
            </div>
          </div>
        ` : ""}
      </article>
    `;
    if (!state.review) {
      $$("#opts .option").forEach(el => {
        el.addEventListener("click", () => {
          // Let label handle the actual input toggle; we just sync state on the next tick.
          setTimeout(() => onOptionChange(q, inputType), 0);
        });
      });
      $("#prevBtn")?.addEventListener("click", () => goto(state.current - 1));
      $("#nextBtn")?.addEventListener("click", () => goto(state.current + 1));
      $("#markBtn")?.addEventListener("click", () => toggleMark(q.id));
    } else {
      $("#prevBtn")?.addEventListener("click", () => goto(state.current - 1));
      $("#nextBtn")?.addEventListener("click", () => goto(state.current + 1));
      $("#backResultsBtn")?.addEventListener("click", showResults);
    }

    $("#qnum") && ($("#qnum").textContent = state.current + 1);
    updateAnsCount();
    refreshNavGrid();
  }

  function prettyType(t) {
    return {
      single: "Single answer",
      multi: "Multi-select — choose all that apply",
      truefalse: "True / False"
    }[t] || t;
  }

  // Lightweight inline markdown: `code` → <code>code</code>, ** → <strong>
  function renderInline(text) {
    if (!text) return "";
    let s = escapeHtml(text);
    s = s.replace(/`([^`]+)`/g, "<code>$1</code>");
    s = s.replace(/\*\*([^*]+)\*\*/g, "<strong>$1</strong>");
    return s;
  }

  function escapeHtml(t) {
    return String(t)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;");
  }

  function onOptionChange(q, type) {
    const checked = $$(`input[name="q-${q.id}"]:checked`).map(i => i.value);
    state.answers[q.id] = checked;
    // refresh selected class on labels
    $$("#opts .option").forEach(el => {
      if (checked.includes(el.dataset.opt)) el.classList.add("selected");
      else el.classList.remove("selected");
    });
    updateAnsCount();
    refreshNavGrid();
  }

  function toggleMark(qid) {
    if (state.marked.has(qid)) state.marked.delete(qid);
    else state.marked.add(qid);
    renderQuestion();
  }

  function goto(idx) {
    const len = state.exam.questions.length;
    state.current = Math.max(0, Math.min(len - 1, idx));
    renderQuestion();
    window.scrollTo({ top: 0, behavior: "smooth" });
  }

  // ---- Nav grid ----
  function renderNavGrid() {
    const grid = $("#navGrid");
    grid.innerHTML = state.exam.questions.map((q, i) => `
      <div class="nav-cell" data-idx="${i}">${i + 1}</div>
    `).join("");
    $$(".nav-cell").forEach(c => c.addEventListener("click", () => goto(parseInt(c.dataset.idx))));
    refreshNavGrid();
  }

  function refreshNavGrid() {
    $$(".nav-cell").forEach((cell, i) => {
      const q = state.exam.questions[i];
      cell.classList.toggle("answered", isAnswered(q.id));
      cell.classList.toggle("marked", state.marked.has(q.id));
      cell.classList.toggle("current", i === state.current);
    });
    const total = state.exam.questions.length;
    const ans = state.exam.questions.filter(q => isAnswered(q.id)).length;
    const marked = state.marked.size;
    const stats = $("#summaryStats");
    if (stats) stats.innerHTML = `
      <div>Total: <strong>${total}</strong></div>
      <div>Answered: <strong>${ans}</strong></div>
      <div>Marked: <strong>${marked}</strong></div>
      <div>Unanswered: <strong>${total - ans}</strong></div>
    `;
  }

  function updateAnsCount() {
    const ans = state.exam.questions.filter(q => isAnswered(q.id)).length;
    const el = $("#ansCount");
    if (el) el.textContent = ans;
  }

  // ---- Submit modal ----
  function openSubmitModal() {
    const unanswered = state.exam.questions.filter(q => !isAnswered(q.id)).length;
    const modal = document.createElement("div");
    modal.className = "modal-backdrop";
    modal.innerHTML = `
      <div class="modal">
        <h3>Submit exam?</h3>
        <p>${unanswered > 0
          ? `You have <strong>${unanswered}</strong> unanswered question(s). Unanswered questions are graded as incorrect.`
          : "All questions answered. Ready to grade."}</p>
        <div class="actions">
          <button class="btn btn-secondary" id="cancelSubmit">Continue exam</button>
          <button class="btn btn-success" id="confirmSubmit">Submit and grade</button>
        </div>
      </div>
    `;
    document.body.appendChild(modal);
    $("#cancelSubmit").addEventListener("click", () => modal.remove());
    $("#confirmSubmit").addEventListener("click", () => {
      modal.remove();
      gradeExam();
      showResults();
    });
  }

  // ---- Grading ----
  function gradeExam() {
    let correct = 0;
    const perQuestion = state.exam.questions.map(q => {
      const userAns = state.answers[q.id] || [];
      const isCorrect = arraysEqual(userAns, q.correct);
      if (isCorrect) correct++;
      return { q, userAns, isCorrect };
    });
    state.submitted = true;
    state.results = {
      correct,
      total: state.exam.questions.length,
      perQuestion,
    };
  }

  function showResults() {
    const { correct, total } = state.results;
    const pct = Math.round((correct / total) * 100);
    const pass = pct >= state.exam.passingScore;
    const circleColor = pass ? "var(--success)" : "var(--danger)";

    $("#app").innerHTML = `
      <div class="container">
        <div class="results">
          <h1 style="margin-top:0">Results — ${escapeHtml(state.exam.title)}</h1>
          <div class="score-display">
            <div class="score-circle" style="--pct:${pct};--circle-color:${circleColor}">
              <span>${pct}%</span>
            </div>
            <div class="verdict ${pass ? "pass" : "fail"}">
              ${pass ? "✓ PASS" : "✗ FAIL — try again"}
            </div>
          </div>
          <div class="breakdown">
            <div><span>Correct</span><strong>${correct} / ${total}</strong></div>
            <div><span>Score</span><strong>${pct}%</strong></div>
            <div><span>Passing score</span><strong>${state.exam.passingScore}%</strong></div>
            <div><span>Verdict</span><strong style="color:${pass ? "var(--success)" : "var(--danger)"}">${pass ? "PASS" : "FAIL"}</strong></div>
          </div>
          <div class="actions">
            <button class="btn btn-secondary btn-lg" id="reviewBtn">Review answers</button>
            <button class="btn btn-primary btn-lg" id="retryBtn">${pass ? "Take again" : "Try again"}</button>
            <a class="btn btn-secondary btn-lg" href="./">Back to home</a>
          </div>
        </div>
        <div class="review-list" id="reviewList"></div>
      </div>
    `;
    $("#reviewBtn").addEventListener("click", enterReviewMode);
    $("#retryBtn").addEventListener("click", () => loadExam(currentExamFile()));
    renderReviewSummary();
  }

  // For the "Review answers" detailed list shown above the per-question review walkthrough.
  function renderReviewSummary() {
    const list = $("#reviewList");
    list.innerHTML = `
      <h2>Per-question summary</h2>
      <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(60px, 1fr)); gap: 6px;">
        ${state.results.perQuestion.map((r, i) => `
          <button class="nav-cell ${r.isCorrect ? "answered" : "marked"}" style="background:${r.isCorrect ? "var(--success)" : "var(--danger)"};color:white;border-color:transparent;" data-idx="${i}" title="Q${i+1}: ${r.isCorrect ? "Correct" : "Wrong"}">${i+1}</button>
        `).join("")}
      </div>
      <p style="color:var(--text-dim);font-size:0.85rem;margin-top:12px;">Click any number to jump into review mode for that question.</p>
    `;
    $$("#reviewList .nav-cell").forEach(c => c.addEventListener("click", () => {
      enterReviewMode();
      goto(parseInt(c.dataset.idx));
    }));
  }

  function renderExplanation(q, userAns) {
    return `
      <div class="explanation">
        <div style="margin-bottom: 8px;"><strong>Correct answer:</strong> ${q.correct.join(", ")}</div>
        <div style="margin-bottom: 8px;"><strong>Your answer:</strong> ${userAns.length ? userAns.join(", ") : "(not answered)"}</div>
        <div>${renderInline(q.explanation)}</div>
      </div>
    `;
  }

  function enterReviewMode() {
    state.review = true;
    state.current = 0;
    renderExam();
  }

  // ---- Bootstrap ----
  function currentExamFile() {
    return state._lastFile || "questions.json";
  }

  // Hook loadExam to remember file
  const origLoad = loadExam;
  // (no need to redefine — we'll inline)

  function start() {
    // If a `?exam=<file>` URL param exists, jump straight in.
    const params = new URLSearchParams(location.search);
    const direct = params.get("exam");
    if (direct) {
      state._lastFile = direct;
      loadExam(direct);
      return;
    }
    fetchJSON("manifest.json")
      .then(m => renderLanding(m))
      .catch(() => {
        // single-exam mode: no manifest, just load questions.json
        state._lastFile = "questions.json";
        loadExam("questions.json");
      });
  }

  // Wrap loadExam to record file each time
  const _loadExam = loadExam;
  loadExam = function(file) {
    state._lastFile = file;
    return _loadExam(file);
  };

  document.addEventListener("DOMContentLoaded", start);
})();
