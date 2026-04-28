# Workshop v2 — design decisions and source attributions

Internal facilitator reference. Captures the source material, factual anchors, and
deliberate design choices behind the v2 enhancement pass (April 2026). This file is
the durable record of decisions that future maintainers should not have to relitigate.

---

## 1. Source materials reviewed

| Source | Use in v2 |
|---|---|
| **Microsoft Learn** — Copilot Studio docs and 2025 Wave 2 / 2026 Wave 1 release plans | Primary authority for GA dates, capabilities, regional caveats |
| **PowerCAT MCS Labs Architecture Bootcamp** — https://microsoft.github.io/mcs-labs/events/bootcamp/ | Pedagogy, teaching patterns ("Three Zones", "child vs connected", "five evaluator types"), lab inventory |
| **PowerCAT slide corpus** (13 PPTX decks, formerly under `review/`) | Slide structure, "Knowledge Prioritization" framing, Component Collections concepts |

The original raw research artifacts (`research/mcs-labs-bootcamp-analysis.md` and
`workshop/research/2026-04-copilot-studio-capabilities-review.md`) and the PowerCAT
PPTX corpus (`review/`) were deleted after v2 merge. This file is the distilled
record kept in the repo.

---

## 2. Verified Copilot Studio capability anchors (April 2026)

These facts are cited on Microsoft Learn and drive workshop content. **Do not change
them without re-verifying against learn.microsoft.com first.**

### Models (in the Copilot Studio model picker)

| Model | Status | Notes |
|---|---|---|
| **GPT-5 / GPT-5 Chat** | GA **August 7, 2025** | Workshop baseline recommendation |
| **GPT-4.1** | GA — labeled "Default" in picker | Explicit GA fallback when GPT-5 unavailable in region |
| **GPT-5 mini** | GA | Cheaper / faster sibling |
| **Claude Sonnet** | GA **March 2026** | Rolling, opt-in per environment. **NOT available in GCC, EU, UK, EFTA at GA.** |
| **Deep Reasoning** | GA **March 2025** | Powered by **OpenAI o1**. Do not describe as the o-series successor; the picker entry is o1. |

### Connected Agents
- **GA: November 30, 2025**. No preview banners in current UX.
- Distinct from Child Agents — see Lab 15 README for the matrix.

### Evaluation
- **GA: April 2026.** Capabilities at GA: multi-grader, multi-turn, auto-generated
  test inputs, EvalGate-style CI/CD pattern (e.g., EvalGateADO).
- Workshop adopts PowerCAT's "Zones of Coverage" framing (capability / regression /
  safety) as a teaching aid in Lab 24.

### MCP transport
- **Streamable HTTP** is the recommended transport for new MCP servers.
- **SSE is deprecated** for new servers (existing SSE servers continue to function,
  recommended to migrate).
- In-product MCP onboarding wizard is the supported path; no hand-edited JSON.

### Billing
- **Copilot Credits** replaced "messages" as the metering unit (Sep 1, 2025).
- Pay-as-you-go: $0.01 / credit.
- Autonomous trigger cost is a non-trivial credit consumer; workshop ships
  `Disable-WorkshopAutonomousTriggers.ps1` to stop autonomous demo triggers
  post-workshop.

### Capabilities flagged as planned, not GA (do not present as GA)
- **SharePoint Lists as knowledge source** — planned Wave 1 2026 (target May 2026 GA).
- **Computer Use** — limited preview; targets H1 CY2026 (May–June). Avoid stating
  "May 2026" as a firm date.
- **Group files with instructions** — preview; planned May 2026 GA.
- **Bing Custom Search as knowledge source** — preview.
- **Enhanced Task Completion** — experimental.

---

## 3. PowerCAT bootcamp lab inventory (for future-mining)

The PowerCAT bootcamp is structured as 11 hands-on labs across 3 days, drawn from a
larger 31-lab parent repo at https://github.com/microsoft/mcs-labs.

### Bootcamp labs (curated subset)

| # | Slug | Day | Time | Title | v2 disposition |
|---|---|---|---|---|---|
| 1 | `agent-builder-m365` | D1 | 30m | Build Progressive Agents with M365 Agent Builder | **Adopted** as Lab 03 optional walkthrough (license-gated) |
| 2 | `core-concepts-agent-knowledge-tools` | D1 | 45m | Knowledge, Tools, Topics | Already covered in Labs 06–07 |
| 3 | `core-concepts-variables-agents-channels` | D1 | 30m | Variables, Multi-Agent, Channels | Already covered in Labs 06–11 |
| 4 | `core-concepts-analytics-evaluations` | D1 | 30m | Analytics + Evaluation | Lab 24 absorbed multi-grader / Zones-of-Coverage |
| 5 | `mcs-alm` | D2 | 45m | ALM, Pipelines, Source Control | **Concept-only** in Module 13b (PP Pipelines requires Production envs; students are Sandbox) |
| 6 | `component-collections` | D2 | 30m | Reusable Component Collections | **Adopted** as Day 1 sidebar (Lab 06) + Day 2 micro-step (Lab 14) |
| 7 | `ask-me-anything` | D2 | 90m | Multi-source AMA, knowledge prio, M365 channel | **Adopted in pieces** — knowledge prioritization + suggested prompts + M365 channel went into Lab 11 |
| 8 | `mcs-tools` | D2 | 60m | Connectors, Flows, MCP, Custom Prompts | Already covered in Labs 09 + 22 |
| 9 | `mcs-governance` | D3 | 30m | Three Zones (Green/Yellow/Red) | **Adopted as concept** in Module 13b. **NOT a hands-on student lab** — three envs per student is infeasible |
| 10 | `mcs-multi-agent` | D3 | 30m | Connected vs Child Agents | **Adopted** — Lab 15 now has the Child vs Connected matrix |
| 11 | `autonomous-account-news` | D3 | 60m | Autonomous Sales Agent + Deep Reasoning | **Adopted in reframed form** — see autonomous-triage-demo.md (facilitator-only, internal-triage scenario) |

### Adjacent PowerCAT labs considered but NOT adopted (with rationale)

| Slug | Why not | Could revisit if |
|---|---|---|
| `human-in-the-loop` | Multistage approvals **partially adopted** as Lab 09 Part 2 (FSI loan approval pattern) | Need full HITL teaching depth |
| `autonomous-cua` (Computer Use Agents) | CUA still preview; high risk for live demo | Computer Use reaches GA |
| `mcs-byom` | Adds an Azure AI Foundry dependency outside Copilot Studio core | Customer asks for BYOM specifically |
| `guildhall-custom-mcp` | Build-your-own MCP server is too deep for a 2-day workshop | Spin up as an "MCS Labs Advanced" follow-on |
| `data-fabric-agent` | Microsoft Fabric outside core scope | Adjacent BI/analytics workshop |
| `pipelines-and-source-control` | Production envs required (student Sandbox limitation) | Facilitator demo only — solution.zip take-home |
| `measure-success` | Lab 23 (User Feedback) is sufficient for v2 scope | Need deeper CSAT analytics |
| `dataverse-mcp-connector` | Lab 20 + Lab 22 cover the pieces | Want the unified path |

---

## 4. PowerCAT teaching patterns adopted

These are PowerCAT-originated pedagogical artifacts. **They are not Microsoft official
frameworks** — call them out as "PowerCAT pattern" the first time they appear in any
deck or facilitator script.

| Pattern | Where used in v2 | Authority |
|---|---|---|
| **Three Zones** (Personal Sandbox / Team Dev / Production) | Module 13b — concept slide + facilitator demo via `Initialize-FacilitatorGovernanceZones.ps1` | PowerCAT teaching pattern. **NOT** Microsoft Cloud Adoption Framework "landing zones" — those are different. |
| **Child vs Connected Agent matrix** | Lab 15 callout | PowerCAT bootcamp lab `mcs-multi-agent` |
| **Zones of Coverage** (capability / regression / safety) | Lab 24 callout + Module 12 slides | PowerCAT bootcamp lab `core-concepts-analytics-evaluations` |
| **Knowledge prioritization** (per-source ordering) | Lab 11 publish step | PowerCAT bootcamp lab `ask-me-anything` |
| **Five evaluator types** (exact / keyword / similarity / quality / meaning) | Lab 24 — extended to seven GA grader types in v2 | PowerCAT bootcamp + Learn |

---

## 5. FSI re-skinning principles (carry forward)

When future maintainers consider porting more PowerCAT content:

1. **Generic scenarios stay generic — don't bank-wash trivially.** Only re-skin if the
   FSI version teaches something the generic does not.
2. **KYC must NEVER be agent-side knowledge.** KYC is a system-of-record process
   (Fenergo / Actimize / Pega) accessed via dedicated connector. Agent-side KYC
   knowledge is a compliance landmine.
3. **No AI-only credit decisions.** Any FSI workflow that involves credit, denial,
   pricing, or adverse action MUST be drafted-by-AI and approved-by-human, with the
   four-eyes principle for high-stakes (cite **SR 11-7**, **OCC AI guidance**, **ECOA Reg B**).
4. **Adverse action workflows are regulated.** Lab 21 specifically illustrates this
   pattern (cite **ECOA Reg B 12 CFR §1002.9**, **FCRA §615(a) / 15 U.S.C. §1681m**).
5. **Autonomous agents in FSI must stay internal-only.** No customer-facing autonomous
   actions. See `autonomous-triage-demo.md` for the reframed pattern.

---

## 6. Regulatory citation index (for slide / lab authors)

| Regulation | Workshop content that cites it |
|---|---|
| **SR 11-7** (Federal Reserve model risk management) | Lab 09 multistage approvals, autonomous-triage-demo, Module 13b |
| **OCC AI guidance** (model risk principles 2024) | Lab 09, autonomous-triage-demo, Module 13b |
| **ECOA Regulation B (12 CFR §1002.9)** | Lab 09, Lab 21 (adverse action), autonomous-triage-demo |
| **FCRA §615(a) (15 U.S.C. §1681m)** | Lab 21 (adverse action notice content requirements) |
| **GLBA Safeguards Rule** | Module 13b (data protection / access controls) |
| **NYDFS Part 500 §500.11** | Module 13b (third-party service provider security policies) |
| **EU AI Act Annex III §5(b)** | Lab 21, autonomous-triage-demo, Module 13b (high-risk classification: credit scoring) |
| **PRA SS1/23** | Lab 09 (model risk management — UK equivalent) |

---

## 7. Items deferred to v3 backlog

Council explicitly deferred these from v2 scope. They are NOT committed; documenting
here so the next planning pass starts from a known baseline.

- **BYOM (Azure AI Foundry models as tools)** — depth doesn't fit 2-day cap
- **Build-your-own MCP server lab** — too deep for in-class
- **Computer Use Agents (CUA)** — wait for GA
- **Deeper CSAT / analytics lab** (`measure-success` adjacent) — Lab 23 is sufficient
- **Visualization deep-dive** — out of scope
- **Copilot Studio SDK pro-code path** — Lab 25 already gestures at it; full SDK lab deferred
- **Researcher / Analyst frontier-reasoning agents** — M365 specialty; surfaces in Lab 03 contrast only
- **Fabric Data Agent ↔ Copilot Studio** — adjacent workshop territory
- **PPTX deck for Module 13b** — currently Markdown-only (`Module-13b-ALM-and-Governance.md`); future work

---

## 8. Maintenance notes

- Run `pwsh -File workshop/tests/terminology-lint.ps1` before any release to catch
  regressions in deprecated product names, billing terminology, model identifiers,
  MCP transport names, and the "Three Zones" framing claim.
- The lint allows disambiguation phrasing — see `AllowLineContains` in the script.
- `workshop/tests/pass-2-release-readiness.md` is the v2 release-gate checklist.
- Re-verify model-picker facts on Learn before each major workshop delivery; the
  models page changes frequently.
