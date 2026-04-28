# Autonomous Triage Assistant — Facilitator Demo Guide

> **Status:** Facilitator demo only. **Not a hands-on student lab.** This walkthrough exists so the room can *see* an autonomous Copilot Studio trigger fire and write an internal-only artifact, then *discuss* the governance pattern that makes that pattern responsible in a regulated bank. Students do not deploy this in their own environments.

## 1. Demo objective

Show how a trigger-driven Copilot Studio agent can act on its own schedule **inside an enterprise's own four walls** to relieve human reviewers of triage drudgery — *without* taking a single action that a regulator would treat as an automated credit decision or an automated borrower communication.

The demo is built on the Day 2 **Loan Processing Agent** and the **Woodgrove Lending Hub** Dataverse data (Lab 13 baseline). It introduces one new behavior: every N hours (or whenever a new high-priority Service Request row is created), the agent reads open Service Requests, scores them by urgency and risk, and writes a single **internal-only triage memo** to a SharePoint document library. A human triage manager (e.g., `triage-manager@example.com`) reads the memo and dispatches the work.

This is intentionally framed as a **governance showcase**. The teaching moment is *what the agent must not do*, not what it does.

## 2. Why this scenario is reframed (read this before delivering)

The original v1 plan called for an "Autonomous Borrower-Watch" agent that would monitor borrower events, infer risk, and act on a portfolio. The FSI council rejected that framing as a clear violation of regulated-banking norms. The reframed Tier-2 Triage Assistant scenario keeps the autonomous-trigger teaching value while removing every regulated-decision and customer-facing action.

The relevant guardrails to cite verbatim during the demo:

- **Federal Reserve SR 11-7 — Guidance on Model Risk Management.** Banks must have effective challenge, independent validation, and human accountability over models that influence credit, capital, or risk decisions. An AI that decides credit without a documented human review step fails SR 11-7's effective-challenge standard.
- **ECOA and Regulation B (12 CFR §1002), specifically §1002.9 — Adverse Action Notices.** A denial or other adverse action against a credit applicant requires a notice with specific principal reasons. AI-only adverse-action workflows without human review create both a fair-lending and a notice-content risk.
- **OCC Bulletin 2021-39 / OCC AI guidance.** National banks are expected to apply existing model risk management, third-party risk, and governance frameworks to AI systems, including human oversight commensurate with risk.
- **EU AI Act, Annex III §5(b).** AI systems used to evaluate the creditworthiness of natural persons or to establish their credit score are classified as **high-risk** and require human oversight, risk management, logging, transparency, and post-market monitoring obligations.
- **Four-eyes / two-person review principle** (FFIEC, BCBS sound practices). Material credit and operational actions require two independent reviewers; an autonomous agent acting alone on a credit decision violates this on its face.

The Tier-2 Triage Assistant stays on the right side of every one of these because **it never decides, never communicates externally, and never closes the loop without a human**.

## 3. Prerequisites

This demo runs only against the **facilitator demo environment** — never against a student environment, never against the shared Day 1 site.

Required configuration in `workshop\automation\workshop-config.json`:

```json
{
  "Workshop": {
    "EnvironmentPurpose": "FacilitatorDemo"
  },
  "Autonomous": {
    "EnableBorrowerWatchDemo": true,
    "TriggerSchedule": "Every 4 hours",
    "DisableAfterWorkshop": true,
    "MemoLibraryUrl": "https://<tenant>.sharepoint.com/sites/WoodgroveBank/TriageMemos",
    "TriageManagerEmail": "triage-manager@example.com"
  }
}
```

Notes:

- `Autonomous.EnableBorrowerWatchDemo` is the master switch for the demo. When `false`, the trigger is not added during facilitator setup.
- `Autonomous.TriggerSchedule` is purely descriptive for documentation; the actual cadence is configured in the trigger node in the Copilot Studio maker portal.
- `Autonomous.DisableAfterWorkshop` is read by `Disable-WorkshopAutonomousTriggers.ps1` and should remain `true`.
- `Autonomous.MemoLibraryUrl` must point at a document library inside the **facilitator demo** site collection. The cadence and library are intentionally separated from any student-facing site.
- `Autonomous.TriageManagerEmail` is the recipient referenced in the memo template. Use `example.com` addresses only.

Other prerequisites:

- Day 2 base data has been imported into the facilitator demo environment via `Import-WorkshopEnterpriseAssets.ps1 -ImportSolution -ImportBaseData` (so there are real Service Requests, loan applications, and customers to triage).
- The Loan Processing Agent has at least the Lab 14 instructions in place.
- The facilitator demo environment has Copilot Credits allocated (this trigger consumes credits each time it fires — that is part of the talking point).

## 4. Walkthrough

### 4.1 Set up the trigger (do this before the session, not live)

1. In the facilitator demo environment, open the **Loan Processing Agent** in Copilot Studio.
2. Add a new **Topic** named `Internal Triage Memo`.
3. Add a **trigger** of type **On Schedule** (or **On record created** for Service Requests of priority `High`). Configure cadence per `Autonomous.TriggerSchedule`.
4. In the topic, add the following internal-only steps:
   - Query Dataverse for Service Requests in the Woodgrove Lending Hub where `statuscode = Open` and `priority in (High, Critical)`.
   - Use a **Generative answers** node grounded on the agent instructions to draft a triage memo summarizing: which case IDs need senior underwriter attention, why (one-line risk rationale per case from the Service Request body), and a *suggested* next step (e.g., "route to senior underwriter," "request additional income docs," "second review for fair-lending sensitivity").
   - Use a **Send file to SharePoint** action (or a Power Automate flow) to write the memo as a Markdown or PDF file to `Autonomous.MemoLibraryUrl`. Filename pattern: `triage-memo-yyyyMMdd-HHmm.md`.
   - The topic ends. **There is no email send. There is no message to a customer. There is no Dataverse update on the Service Request itself.**
5. Save and publish to the **demo channel only** (not Teams, not the production-style web channel).

### 4.2 Show the trigger in the maker portal (live, ~5 min)

- Open the **Triggers** view of the Loan Processing Agent.
- Show the schedule and the lack of any external-channel send action in the topic.
- Walk the room through the four boundary checks they should look for in any autonomous topic: *no outbound channel*, *no Dataverse write to the borrower record*, *no decision row written to the credit decisioning table*, *no third-party API call*.

### 4.3 Show a memo that has already fired (live, ~10 min)

- Open the SharePoint document library at `Autonomous.MemoLibraryUrl` and open the most recent `triage-memo-*.md`.
- Walk through a memo that looks like this (use a memo from a real prior demo run; do not generate one live unless the room asks):

```markdown
# Tier-2 Triage Memo — 2026-04-15 08:00 UTC

Recipient: triage-manager@example.com
Source: Loan Processing Agent (autonomous trigger, schedule=Every 4 hours)
Cases reviewed: 14 open Service Requests, priority High or Critical

## Recommended for senior underwriter today

1. **Case SR-2041** — applicant submitted updated tax docs; original denial reason
   was income verification. Suggested next step: senior underwriter re-review of
   updated 1040 evidence. *Not a re-decision; a re-review request.*

2. **Case SR-2058** — flagged by the maker as a fair-lending sensitivity check
   (geography + product-mix pattern). Suggested next step: route to second
   reviewer per four-eyes policy before any adverse action notice is drafted.

3. **Case SR-2071** — incomplete file, applicant non-responsive 14 days.
   Suggested next step: triage manager to decide between extension request and
   withdrawal-for-incompleteness per branch policy.

## Items the agent declined to recommend

- One case (SR-2063) involves a request that resembles credit-decision logic.
  The agent did not score it. Triage manager must handle directly.

## Audit
- Trigger fired at: 2026-04-15T08:00:12Z
- Cases read: 14. Cases summarized: 11. Cases declined: 3.
- No external messages sent. No borrower contacted. No Dataverse write to any
  loan-application or credit-decision row.
```

- Read the **"Items the agent declined to recommend"** and **"Audit"** sections aloud. These two sections are the demo's most important teaching moments.

### 4.4 Show the activity / transcript view (live, ~5 min)

- In Copilot Studio, open the unified activity and transcript view for the most recent autonomous run.
- Show the room: every step is logged, every Dataverse query is recorded, the memo write is recorded, and there is no row indicating an outbound message or a credit-decision write. This is the *evidence* a model risk manager would ask for.

### 4.5 Discussion prompt (~10 min)

Pose the following to the room and let small groups answer before you do:

> "Your bank's risk committee asks: what would have to be true before you would let *this same trigger* deliver its memo to the customer instead of to your triage manager? List the controls."

Expected good answers from the room: explicit human review step before send, an adverse-action review workflow, model validation and challenger model, transcript retention and supervisory review, fair-lending impact testing, complaint-handling integration, opt-in/opt-out for digital communication, ECOA notice-content review, and so on. The point is to make participants articulate the *very long list* of controls that separates "internal triage memo" from "customer-facing decision."

## 5. What we are NOT doing — call this out explicitly

Read this list to the room before opening the maker portal. Do not soften it.

- **We are NOT making credit decisions.** No approval. No denial. No counter-offer. No interest-rate suggestion to the borrower.
- **We are NOT sending adverse action notices.** ECOA Reg B §1002.9 requires specific principal reasons and a documented human-reviewed process. This agent does not send them and does not draft them.
- **We are NOT contacting borrowers.** No email, no SMS, no chat message to any customer-facing channel. The memo lands in a private internal library.
- **We are NOT updating loan application records.** The agent only reads from Dataverse. It does not flip a Service Request from Open to Resolved. It does not edit the loan application status. It does not write to any credit-decision table.
- **We are NOT calling external APIs.** No bureau pull, no third-party scoring, no broker notification.
- **We are NOT replacing the four-eyes principle.** The triage manager still reads the memo, exercises judgment, and dispatches the work to a second human reviewer for any material action.
- **We are NOT claiming SR 11-7 compliance for the agent itself.** SR 11-7 obligations attach to the bank that *operates* the agent in production. The demo shows a pattern that is *compatible* with SR 11-7, not a turnkey compliant solution.

## 6. Cleanup

The autonomous trigger continues to fire after the workshop ends and continues to consume Copilot Credits in the facilitator demo environment. Run cleanup the same day the workshop closes.

```powershell
# Dry run first — confirms which trigger components will be disabled
pwsh -File .\workshop\automation\Disable-WorkshopAutonomousTriggers.ps1 -ListOnly

# Disable autonomous triggers in the configured facilitator demo environment
pwsh -File .\workshop\automation\Disable-WorkshopAutonomousTriggers.ps1
```

Notes:

- The script refuses to run unless `Workshop.EnvironmentPurpose` identifies the target as a facilitator demo or fallback environment. It will not touch a student environment.
- `Autonomous.DisableAfterWorkshop` is read for intent confirmation. Leave it at `true`.
- After running, optionally archive the SharePoint library at `Autonomous.MemoLibraryUrl` so the memos are preserved as a teaching artifact for future cohorts.
- For full environment teardown, follow the existing `Remove-WorkshopFacilitatorEnvironment.ps1` flow documented in `facilitator-guide.md`.

## 7. Talking points for student Q&A

These are the questions a banking-tech audience always asks. Have answers ready.

- **"Could we run this in production?"** Only after model validation per SR 11-7, fair-lending impact testing, transcript retention review, change-management approval per FFIEC and (where applicable) NYDFS Part 500 §500.11, and a documented human-in-the-loop policy. The demo shows a *pattern that is compatible with those controls*, not a finished production system.
- **"Could we let it write to the loan application record?"** Only as a *recommendation field* with no downstream automated effect, and only with audit trail and reviewer sign-off. As soon as a Dataverse write influences a decision, you are inside SR 11-7's model scope and must validate the model accordingly.
- **"What about EU customers?"** EU AI Act Annex III §5(b) treats credit-scoring systems as high-risk. Even an internal triage memo can pull you into Annex III scope if it materially influences a creditworthiness decision. Document the human review step that breaks the chain.
- **"Could we have it call a customer?"** No. Customer outreach attached to a credit context is high-risk under multiple regimes (ECOA, UDAAP, EU AI Act, telecom rules). Use a human in the loop and a separate, validated communications channel.
- **"How do we test this for bias?"** Same way you test any underwriting model: disparate-impact analysis on the recommendations, comparison of agent-flagged versus human-flagged populations, and ongoing post-market monitoring. The Lab 24 Evaluation patterns (Capability, Regression, **Safety**) extend naturally — Safety cases here include "do not score a borrower-decision-shaped Service Request."
- **"What if the model hallucinates a recommendation?"** That is exactly why the memo is internal-only and why the triage manager is required. Hallucinations become operational noise, not customer harm. The activity / transcript view is the evidence trail for any post-incident review.
- **"What happens if we forget to disable the trigger?"** It keeps firing on schedule and keeps burning Copilot Credits in the demo environment. That is why `Disable-WorkshopAutonomousTriggers.ps1` is part of the closeout checklist.

## 8. Related references

- `workshop\automation\Disable-WorkshopAutonomousTriggers.ps1` — cleanup script.
- `workshop\facilitator-guide\facilitator-guide.md` — main facilitator guide; the autonomous demo is referenced from the demo and closeout sections.
- `workshop\assets\slide-deck-outline.md` — Module 13b autonomous demo slide entries.
- `workshop\assets\slide-deck-delivery-notes.md` — facilitator pre-demo notes with the regulatory guardrails callout.
