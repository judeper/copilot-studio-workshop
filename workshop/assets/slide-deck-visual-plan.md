# Slide Deck Visual Plan

## How to use this file

- Reuse workshop screenshots first when they have already been captured.
- Create custom visuals only where the deck needs comparison, abstraction, or a cross-lab narrative.
- Pair every visual-heavy slide with a speaker note that explains why the visual matters to the workflow.

## Workshop screenshots to capture or reuse

These filenames come from `screenshot-capture-checklist.md`. If the screenshots are not present in your local lab `assets` folders yet, treat this table as the capture plan for a facilitator dry run rather than as a guaranteed checked-in asset library.

| Slide area | Visual need | Capture target |
| --- | --- | --- |
| Slides 6-7 | Copilot Studio landing and environment readiness | `../labs/lab-00-environment-setup/assets/lab-00-copilot-studio-home.png` |
| Slides 10, 15 | Core navigation and authoring surfaces | `../labs/lab-02-copilot-studio-fundamentals/assets/lab-02-copilot-studio-navigation.png` |
| Slide 20 | Solution packaging view | `../labs/lab-04-solutions/assets/lab-04-solution-explorer.png` |
| Slides 27, 25 | Custom agent and knowledge grounding | `../labs/lab-06-custom-agent/assets/lab-06-custom-agent.png`, `../labs/lab-06-custom-agent/assets/lab-06-knowledge-sources.png` |
| Slides 31, 34 | Topic canvas and Adaptive Card flow | `../labs/lab-07-topics-triggers/assets/lab-07-topic-canvas.png`, `../labs/lab-08-adaptive-cards/assets/lab-08-adaptive-card.png` |
| Slides 38, 40 | Flow and trigger implementation | `../labs/lab-09-agent-flows/assets/lab-09-agent-flow.png`, `../labs/lab-10-event-triggers/assets/lab-10-event-trigger.png` |
| Slides 43, 78 | Publish and channel examples | `../labs/lab-11-publish-agent/assets/lab-11-publish.png`, `../labs/lab-11-publish-agent/assets/lab-11-teams-open.png` |
| Slides 45, 81 | Licensing and ROI discussion anchor | `../labs/lab-12-licensing/assets/lab-12-licensing-overview.png` |
| Slides 50, 54 | Lending setup and multi-agent topology | `../labs/lab-13-lending-agent-setup/assets/lab-13-agent-details.png`, `../labs/lab-15-multi-agent/assets/lab-15-agent-topology.png` |
| Slides 57, 59 | Trigger automation and model comparison | `../labs/lab-16-trigger-automation/assets/lab-16-trigger-flow.png`, `../labs/lab-17-model-selection/assets/lab-17-model-comparison.png` |
| Slides 62, 66 | Safety controls and multimodal results | `../labs/lab-18-content-moderation/assets/lab-18-prompt-sensitivity.png`, `../labs/lab-19-multimodal-prompts/assets/lab-19-json-output.png` |
| Slides 69, 72 | Dataverse grounding and generated artifact | `../labs/lab-20-dataverse-grounding/assets/lab-20-grounded-prompt.png`, `../labs/lab-21-document-generation/assets/lab-21-assessment-template.png` |
| Slides 76, 80 | MCP tools and feedback view | `../labs/lab-22-mcp-integration/assets/lab-22-mcp-tools.png`, `../labs/lab-23-user-feedback/assets/lab-23-feedback-review.png` |
| Slides 83, 85 | Evaluation evidence and VS Code branch | `../labs/lab-24-agent-evaluation/assets/lab-24-evaluation-results.png`, `../labs/lab-25-vscode-extension/assets/lab-25-vscode-apply.png` |

## Custom visuals to create before final deck assembly

| Visual | Why it matters | Build from |
| --- | --- | --- |
| Two-day journey and role map | The opening deck needs one clean view of Day 1 foundation to Day 2 enterprise progression for makers, IT pros, and developers | `../participant-guide/welcome-and-overview.md`, `../participant-guide/day1-foundation-guide.md`, `../participant-guide/day2-enterprise-guide.md` |
| [Grounding strategy comparison](#grounding-strategy-comparison-module-04--lab-06) | The deck needs one visual that contrasts public websites, SharePoint, files, and Dataverse across freshness, structure, and ownership | `../labs/lab-06-custom-agent/README.md`, `../labs/lab-20-dataverse-grounding/README.md`, `../tests/validation-checklist.md` |
| [Multi-agent responsibility view](#multi-agent-responsibility-view-module-07--lab-15) | The room needs a clearer mental model for orchestrator, child agent, connected agent, tools, and data | `../labs/lab-15-multi-agent/README.md` |
| Model trade-off comparison | Lab 17 is stronger with a simple side-by-side view for quality, latency, relative cost, and workshop fit | `../labs/lab-17-model-selection/README.md` |
| Licensing and ROI decision flow | Day 1 close and Day 2 evaluation are easier to connect if one visual shows credits, capacity, ROI analytics, and release readiness together | `../labs/lab-12-licensing/README.md`, `../labs/lab-24-agent-evaluation/README.md` |
| Channel readiness comparison | The publish section benefits from a single view that compares Teams, Microsoft 365 Copilot, web, and WhatsApp by ownership and governance | `lab-timing-guide.md`, `../facilitator-guide/facilitator-guide.md` |
| [Evaluation improvement loop](#evaluation-improvement-loop-module-12--lab-24) | Lab 24 should show a repeatable loop: test set, result, activity map, fix, rerun | `../labs/lab-24-agent-evaluation/README.md` |
| [Three-Zones environment diagram](#three-zones-environment-diagram-module-13b--day-2-opener) | Module 13b needs a single image that anchors the Personal Sandbox / Team Dev / Production governance posture and the promotion gates between them | `../Copilot-Studio-Workshop-Slides/Module-13b-ALM-and-Governance.md`, `../automation/Initialize-FacilitatorGovernanceZones.ps1` |
| [ALM pipeline diagram](#alm-pipeline-diagram-module-13b--day-2-opener) | Module 13b needs one visual that shows the Dev → Test → Prod promotion path with the Connector / Connection / Connection Reference triangle and Environment Variables binding per stage | `../Copilot-Studio-Workshop-Slides/Module-13b-ALM-and-Governance.md`, `../assets/WoodgroveLending_1_0_0_0.zip` |

### Grounding strategy comparison (Module 04 / Lab 06)

**Layout:** 4-column comparison table or matrix diagram.

| Dimension | Public Websites | SharePoint (with metadata filters) | Uploaded Files | Dataverse |
| --- | --- | --- | --- | --- |
| **Freshness** — how current is the data? | Live web; uncontrolled change cadence | Near-real-time; governed update cycle | Static at upload time | Transactional; always current |
| **Structure** — schema vs. unstructured | Unstructured HTML; variable quality | Semi-structured; rich metadata when columns/content types are used | Flat files; no queryable schema | Fully structured; typed columns, relationships, views |
| **Ownership** — who controls the source? | External / unknown | Internal team or department | Author who uploaded | IT / app owner with row-level security |
| **Retrieval Quality** — precision with/without filtering | Low; noisy, broad matches | High when metadata filters narrow scope; moderate without | Moderate; limited to file content | High; precise FetchXML or natural-language-to-query |
| **Enterprise Readiness** — governance, DLP, access control | ⚠ No enterprise governance; DLP cannot inspect external content | ✅ Recommended enterprise default — Entra auth, sensitivity labels, DLP-aware | Limited; no live access control sync | ✅ Full Dataverse security model, audit trail, environment-level DLP |

**Key visual cues:**

- Highlight the **SharePoint (with metadata filters)** column with a green accent or bold border as the recommended enterprise default grounding source.
- Place a red **⚠** warning icon on the **Public Websites** column header to flag the governance gap for enterprise use.
- Use a subtle upward "grounding ladder" arrow along the bottom of the table (left → right) to show increasing enterprise readiness.

**Teaching purpose:** Participants need to see WHY they are building a grounding stack in Lab 06, not just HOW. This visual makes the grounding ladder intuitive before they configure knowledge sources, so the SharePoint-first recommendation feels earned rather than arbitrary.

---

### Multi-agent responsibility view (Module 07 / Lab 15)

**Layout:** Hub-and-spoke architecture diagram with 3 agents.

```
                   ┌────────────────────────────────┐
                   │   Loan Processing Agent         │
                   │   (Orchestrator)                │
                   │   Receives all user             │
                   │   requests, delegates,          │
                   │   synthesizes responses         │
                   └─────┬──────────────────┬────────┘
          Delegate       │                  │       Delegate
       document intake   │                  │    loan advisory
             ▼           │                  │          ▼
  ┌─────────────────────┐│                  │┌──────────────────────┐
  │ Document Review     ││                  ││ Loan Advisory        │
  │ Agent               ││                  ││ Agent                │
  │ (Child Agent)       ││                  ││ (Connected Agent)    │
  │                     ││                  ││                      │
  │ Document intake,    ││                  ││ Loan review          │
  │ data extraction,    ││                  ││ scheduling, advisory │
  │ loan application    ││                  ││ material generation  │
  │ creation            ││                  ││                      │
  └──────────┬──────────┘│                  │└──────────┬───────────┘
             │  ▲ Results│                  │Results +  │
             │  + context│                  │context ▲  │
             ▼           │                  │           ▼
  ┌─────────────────────┐                    ┌──────────────────────┐
  │  Dataverse          │                    │  Outlook Calendar    │
  │  ─ Loan Types       │                    │  (via MCP)           │
  │  ─ Applicants       │                    └──────────────────────┘
  │  ─ Loan             │
  │    Applications     │
  └─────────────────────┘
```

**Delegation arrows (labeled):**

- Loan Processing Agent → Document Review Agent: **"Delegate document intake"**
- Loan Processing Agent → Loan Advisory Agent: **"Delegate loan advisory preparation"**
- Document Review Agent → Loan Processing Agent: **"Results + context"** (return)
- Loan Advisory Agent → Loan Processing Agent: **"Results + context"** (return)

**Data source connections:**

- Document Review Agent ↔ Dataverse tables: Loan Types, Applicants, Loan Applications.
- Loan Advisory Agent ↔ Outlook Calendar via MCP connector.

**Key visual cues:**

- **Color-code** child vs. connected agent to show the architectural distinction:
  - **Child Agent** (Document Review) — solid border, same-color family as orchestrator. Same environment; tightly coupled.
  - **Connected Agent** (Loan Advisory) — dashed border, different color family. Cross-environment capable; loosely coupled.
- Add a callout box near the connected agent showing the Copilot Studio toggle: *"Let other agents connect to and use this one"* — this is the setting participants must enable in Lab 15.
- Use thicker arrows for delegation (outbound) and thinner arrows for result returns (inbound).

**Teaching purpose:** Lab 15 asks participants to wire this topology. Without a visual, the five relationship arrows in the lab's Mermaid flowchart are hard to internalize from text alone. This diagram gives the room a shared mental model before they start connecting agents.

**GA framing:** Connected Agents are GA in Copilot Studio as of **November 30, 2025**. The visual should not include any "preview" badge, "limited availability" caption, or opt-in disclaimer — it is a production architecture pattern. Pair this diagram in delivery with the **Child vs Connected agent matrix** (lifecycle, reuse, knowledge/tools, versioning, best-for) from the Lab 15 README so participants understand *why* one specialist is modeled as a child and the other as a connected agent, not just *how* to wire them.

---

### Evaluation improvement loop (Module 12 / Lab 24)

**Layout:** Circular flow diagram (loop) with 6 numbered steps. The loop arrow from step 6 returns to step 3 to show the iterative nature of evaluation-driven improvement.

**Steps:**

1. **Create / Import Test Set** — CSV with 3 columns: `Input`, `ExpectedOutput`, `Context`. Participants use `evaluation-test-cases.csv` from `workshop/assets/`.
2. **Select Graders** — Choose from the seven built-in graders (and use **multi-grader** to attach more than one to a single test case):
   - *General response quality* — overall response relevance and helpfulness.
   - *Semantic meaning* — semantic similarity between actual and expected output.
   - *Capability usage* — did the agent invoke the correct tool or action?
   - *Keyword presence* — are required keywords or phrases present?
   - *Text similarity*, *Exact match*, and *Custom Graders* — string-level match, exact match, and classification-based custom policies.
3. **Run Evaluation** — Execute the test set against the agent. The platform runs every input row and scores each case against the selected graders.
4. **Interpret Results** — Read the pass rate percentage and per-case pass/fail breakdown.
5. **Diagnose Failures** — Open a failed case → read the grader reasoning → open the **Activity Map** → trace the decision chain from user input through knowledge retrieval, topic matching, and response generation.
6. **Fix and Rerun** — Edit agent instructions or knowledge configuration → rerun the evaluation → compare the new run with the baseline to confirm improvement.

**Loop arrow:** Draw a prominent return arrow from **Step 6 → Step 3** to emphasize the iterative cycle. Steps 1–2 are setup (done once or infrequently); steps 3–6 repeat until the agent meets the quality bar.

```
    ┌───────────────────────────────────────────────────┐
    │                                                   │
    ▼                                                   │
 ┌──────────┐   ┌──────────┐   ┌──────────┐            │
 │ 1. Create│──▶│ 2. Select│──▶│ 3. Run   │            │
 │ Test Set │   │ Graders  │   │ Eval     │◀───────┐   │
 └──────────┘   └──────────┘   └────┬─────┘        │   │
                                    │               │   │
                                    ▼               │   │
                               ┌──────────┐        │   │
                               │ 4. Read  │        │   │
                               │ Results  │        │   │
                               └────┬─────┘        │   │
                                    │               │   │
                                    ▼               │   │
                               ┌──────────┐        │   │
                               │ 5. Diag- │  🔍    │   │
                               │ nose     │ Activity│   │
                               │ Failures │  Map    │   │
                               └────┬─────┘        │   │
                                    │               │   │
                                    ▼               │   │
                               ┌──────────┐        │   │
                               │ 6. Fix & │────────┘   │
                               │ Rerun    │            │
                               └──────────┘            │
                                                       │
                  (First-time setup path) ─────────────┘
```

**Key visual cues:**

- Highlight the **Activity Map** diagnostic at Step 5 with a magnifying-glass icon (🔍) or a "deep dive" callout box. This is the critical insight tool that most participants will encounter for the first time during Lab 24.
- Visually separate the **setup phase** (Steps 1–2, lighter background) from the **iteration phase** (Steps 3–6, stronger background) to signal that the loop starts at Step 3.
- Use a bold or colored arrow for the Step 6 → Step 3 return to make the iterative nature unmistakable.

**Teaching purpose:** Lab 24 is procedurally the most detailed lab in the workshop. Participants need to see the full cycle before starting so they understand where each step fits in the improvement process. Showing the loop visually prevents the common mistake of treating evaluation as a one-shot pass/fail rather than an iterative quality practice.

---

### Three-Zones environment diagram (Module 13b / Day 2 opener)

**Layout:** three side-by-side environment columns with a left-to-right promotion arrow underneath and a labeled gate between each pair.

```
┌──────────────────────┐   ┌──────────────────────┐   ┌──────────────────────┐
│  Zone 1              │   │  Zone 2              │   │  Zone 3              │
│  Personal Sandbox    │ → │  Team Dev            │ → │  Production          │
│  Maker exploration   │   │  Curated, shared     │   │  Managed, monitored  │
│  Ephemeral           │   │  Source-controlled   │   │  Auditable           │
│                      │   │                      │   │                      │
│  DLP: strictest      │   │  DLP: curated        │   │  DLP + Managed       │
│  No prod data        │   │  business connectors │   │  Environments on     │
└──────────────────────┘   └──────────────────────┘   └──────────────────────┘
                ▲ peer review gate ▲   ▲ security + change-mgmt gate ▲
```

**Key visual cues:**

- Title the visual **"Three Zones — a PowerCAT teaching pattern (not an official Microsoft framework)"** in the slide footer. This caption must appear on the slide itself, not only in the speaker notes.
- Color the three columns with increasing saturation from left (light) to right (dark) to signal increasing governance posture. Avoid a red/yellow/green palette — the goal is "more controlled," not "safer."
- Mark the gates between zones with a lock or signature icon and the two-word label ("peer review", "security + change-mgmt review"). Gates are the teaching point; the columns are scenery.
- Add a small footnote row mapping the workshop's environments onto the model: "Student Sandbox = Zone 1 · Facilitator demo env = Zone 2 stand-in · Real bank deployment = Zone 3".

**Teaching purpose:** Slide 99 is the slide most likely to be photographed and re-used by participants in their own internal decks. The diagram has to make the PowerCAT attribution unmissable so the pattern is not later misrepresented as an official Microsoft framework.

---

### ALM pipeline diagram (Module 13b / Day 2 opener)

**Layout:** left-to-right promotion path with three environment stages, the Connector / Connection / Connection Reference triangle inset, and an Environment Variables row that re-binds at each stage.

```
   Solution (managed)
         │
         ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  Dev        │ →  │  Test       │ →  │  Prod       │
│  (unmanaged)│    │             │    │  (managed)  │
└──────┬──────┘    └──────┬──────┘    └──────┬──────┘
       │                  │                  │
  EnvVar set A       EnvVar set B       EnvVar set C
  ConnRef → Conn 1   ConnRef → Conn 2   ConnRef → Conn 3

         Connector ──── Connection ──── Connection Reference
            (API)        (auth session)     (the indirection
                                             that makes promotion
                                             work)
```

**Key visual cues:**

- Place the Connector / Connection / Connection Reference triangle in a callout box and label it as **"the single most common reason a solution import succeeds but does not work."** This is the line participants will quote back during Day 2 troubleshooting.
- Show the Environment Variables row beneath the three stages with three different binding values to make per-environment configuration visible.
- Add a small icon (🔒) on the Test → Prod arrow with the caption **"Power Platform Pipelines — Production target only — facilitator demo"** so participants understand why they cannot run this from their student Sandbox.
- Reference the take-home artifact in the slide footer: **"Take-home: `workshop/assets/WoodgroveLending_1_0_0_0.zip` — re-run the export/import in any Production environment you later own."**

**Teaching purpose:** Slide 98 has to compress an entire ALM mental model into one image. The triangle is the conceptual anchor; the Environment Variables row is the proof that the same solution can land cleanly in different environments; the lock icon on the Pipelines arrow is the explicit reason this stays facilitator-demo in this workshop.

---

## Failure-state visuals worth capturing during a dry run

- SharePoint knowledge sign-in prompt or DLP block for Lab 06.
- Empty topic result or mis-filtered data example for Lab 07 or Lab 20.
- Safe refusal or redirect example from the Lab 18 red-team set.
- MCP catalog unavailable or permission-gated example for Lab 22.
- Failed evaluation case with grader reasoning and **Activity map** for Lab 24.
- VS Code apply conflict or stale browser session example for Lab 25.

## Visual build checklist

- Keep browser zoom consistent across Copilot Studio, Power Apps, Power Automate, and Teams captures.
- Prefer clean screenshots for happy-path instruction slides and reserve annotations for conceptual comparison slides.
- Keep environment names visible when they help orient the learner.
- Use screenshots to prove state and use custom visuals to explain relationships.
- Validate that every custom visual still matches the current product wording before final deck assembly.
