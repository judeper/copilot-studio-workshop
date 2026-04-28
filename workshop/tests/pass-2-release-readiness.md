# Pass 2 Release Readiness Checklist

One-stop pre-release checklist for the Plan v2 — Pass 1 (P0 correctness sweep) and Pass 2 (P1 reduced) changes. Use this **before tagging a release** and after any major content edit. Each item is a manual verification step (the workshop has no automated test runner). Pair this with the morning-of [Environment Smoke Tests](environment-smoke-tests.md) and the per-lab [Validation Checklist](validation-checklist.md).

> Convention: check ☐ → ☑ as items pass. If an item fails, log it in the release notes and either fix or document a known-issue with a workaround.

---

## 1. Pass 1 — P0 correctness sweep (terminology + GA status)

### 1.1 Terminology lint

- [ ] Run `pwsh -File workshop/tests/terminology-lint.ps1` from the repo root. **Expected:** exits with code 0 and prints "no forbidden tokens". The lint flags deprecated billing terms, the deprecated product name, the wrong reasoning-model identifier, the deprecated MCP transport name, and generic agent-as-bot phrasing. Inspect the lint output for the specific rule names if any line trips.
- [ ] Re-run the lint after any late-stage doc edit. The lint is the atomic-merge gate for the P0 PR.

### 1.2 Model picker (Lab 17 spot check)

- [ ] Open the Loan Processing Agent in Copilot Studio, go to **Settings → Generative AI → Model**. Confirm the picker lists **GPT-5 Chat** as an available model and **GPT-4.1** is labeled "Default". The next-gen reasoning identifier flagged by the terminology lint does not appear anywhere in the model picker or in Lab 17 / Module-08 docs.
- [ ] Lab 17 references **Deep Reasoning (o1-based, GA Mar 2025)** — not o3.

### 1.3 Connected Agents UX (Lab 15 spot check)

- [ ] Open the agent overview in Copilot Studio. Confirm **Connected agents** is a first-class GA surface — no "preview" badge, no "early access" banner. Lab 15 / Module-07 contains no preview caveats and includes the child-vs-connected matrix.

### 1.4 Evaluation UX (Lab 24 spot check)

- [ ] Open **Evaluation → New evaluation** in Copilot Studio. Confirm GA capabilities are visible: multi-grader selection, multi-turn test inputs, auto-generate test inputs from transcripts. Lab 24 / Module-12 uses GA terminology and references the **Apr 2026 GA** baseline plus the EvalGateADO CI/CD pattern.

### 1.5 MCP wizard (Lab 22 spot check)

- [ ] In Copilot Studio open **Tools → Add a tool → Model Context Protocol** and confirm the in-product onboarding wizard launches. Lab 22 / Module-10 names **Streamable HTTP** as the recommended transport and notes SSE is deprecated. No instructions ask the maker to hand-edit secrets.

---

## 2. Pass 2 — P1 reduced (content additions)

### 2.1 Lab 09 — Multistage + AI Approvals

- [ ] In the workshop environment confirm the **Approvals** connector is enabled (Power Automate → Connectors). The connection can be created without DLP block.
- [ ] Walk Lab 09 end-to-end: trigger a sample loan-approval flow and confirm the **Tier-1 → Tier-2** escalation path runs — AI policy stage routes to a senior-credit-officer approval, and either the approval-letter or adverse-action-notice branch executes.
- [ ] Lab 09 cites **ECOA Reg B §1002.9** in the scenario framing.

### 2.2 Lab 11 — Publish enhancements

- [ ] In the agent **Knowledge** pane, confirm the documented prioritization order is applied (the orderable list in the UI matches Lab 11's screenshot/instructions).
- [ ] In the published agent test pane, confirm **suggested prompts / starter prompts** appear on first load and match Lab 11's configured values.
- [ ] **Microsoft 365 Copilot channel** — publish the agent to the M365 Copilot channel. **Expected:** publish succeeds for accounts with a Microsoft 365 Copilot license; license-gated failure for unlicensed accounts is documented in Lab 11 troubleshooting (not a blocker).

### 2.3 Lab 21 — Adverse Action Notice (Document Generation)

- [ ] Run the Lab 21 doc-gen flow against a denied sample loan application. Confirm the generated Word doc contains the expected fields: **specific reasons for denial**, **credit bureau disclosure**, **ECOA notice**, applicant + lender details.
- [ ] Confirm **draft-only behavior**: the generated document lands in the configured drafts folder (or returns to the user) and is **not auto-sent** to the applicant.
- [ ] Lab 21 cites **ECOA Reg B §1002.9** and **FCRA §615(a)**.

### 2.4 Lab 14 — Component Collection (Day-2 consumption side)

- [ ] In the workshop environment confirm the facilitator-pre-seeded **"Woodgrove Product & Fee Disclosures"** component collection exists in the solution.
- [ ] Open the **Loan Processing Agent** and confirm the collection is referenced (imported) per Lab 14's steps.
- [ ] Cross-day asset check: `workshop/assets/compliance-disclosures-collection.zip` exists and can be imported as a recovery path if a student blew up their Day-1 work.

### 2.5 Lab 03 — Agent Builder access (M365 Copilot license)

- [ ] Sign in as a participant **with a Microsoft 365 Copilot license** and open `https://m365.cloud.microsoft/chat`. Confirm the **Agents → Create agent** entry point (Agent Builder) loads.
- [ ] Sign in as a participant **without** an M365 Copilot license and confirm Lab 03's documented fallback path is followed (license-gated, the workshop does not block on this).

### 2.6 Module 13b — Three Zones (facilitator demo only)

- [ ] If the facilitator has provisioned 3 governance environments and populated `Governance` config keys, run `pwsh -File workshop/automation/Initialize-FacilitatorGovernanceZones.ps1`. **Expected:** validates config keys, sets up the three zones cleanly, no unhandled exceptions.
- [ ] If 3 environments are **not** configured, the script must exit with a clear "skipping — Governance zones not configured" message rather than throwing. Confirm this skip path is documented in Module 13b's facilitator notes.
- [ ] Module 13b labels the Three-Zone pattern as **"PowerCAT teaching pattern"**, never as official Microsoft framework. Cited regulations: **GLBA Safeguards / NYDFS Part 500 §500.11 / OCC AI guidance / EU AI Act Annex III §5(b)**.

### 2.7 Autonomous Borrower-Watch (facilitator demo + cleanup)

- [ ] Run `pwsh -File workshop/automation/Disable-WorkshopAutonomousTriggers.ps1 -ListOnly`. **Expected:** runs without errors, lists 0+ autonomous triggers in the facilitator demo environment, makes no changes.
- [ ] Confirm the lab is framed as **Tier-2 Triage Assistant** — internal-only memo, no outbound communication, no portfolio action, explicit **SR 11-7** + four-eyes governance callout.
- [ ] After the facilitator demo, run the same script **without** `-ListOnly` to clean up triggers in the demo environment.

---

## 3. New / updated automation scripts

- [ ] `Disable-WorkshopAutonomousTriggers.ps1 -ListOnly` runs cleanly against a configured environment. Exits 0; lists triggers; makes no changes.
- [ ] `Initialize-FacilitatorGovernanceZones.ps1` validates config keys on startup. With `Governance` keys missing it skips with a clear message; with all keys present it provisions zones without throwing.
- [ ] `Invoke-WorkshopPrereqCheck.ps1` (updated): the **M365 Copilot license** section runs and emits **WARN** or **PASS** — never throws. Run the script and confirm exit code 0 even when no licenses are present (warning only).

## 4. Config schema

- [ ] `workshop/automation/workshop-config.example.json` is valid JSON. Verify with:
  ```pwsh
  Get-Content workshop/automation/workshop-config.example.json -Raw | ConvertFrom-Json | Out-Null
  ```
  Exits without error.
- [ ] The example config contains the new top-level sections introduced in Pass 2: **`Governance`**, **`Autonomous`**, and **`ComponentCollections`**. Each section has placeholder values and is documented in the facilitator guide.

## 5. Cross-references

- [ ] [`environment-smoke-tests.md`](environment-smoke-tests.md) links to this checklist for the deeper pre-release pass.
- [ ] [`validation-checklist.md`](validation-checklist.md) covers the per-lab Success Criteria; this file is the **release-gate** companion that verifies new content from Plan v2.
- [ ] Release notes for the tag (e.g. `v2026.04-p0`, `v2026.05-p1`) link back to this file as the readiness evidence.

---

## Sign-off

- [ ] All sections above are checked or have a documented known-issue.
- [ ] Terminology lint is green on `main`.
- [ ] Release tag created and release notes published.
