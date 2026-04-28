# Module 13b — ALM and Governance for Copilot Studio Agents

> **Status:** Concept module (Markdown source). No PPTX deck yet — future work to convert.
> **Position:** Day 2 opening, ~30 minutes, between Lab 13 (solution import) and Lab 14 (instructions).
> **Format:** Concept lecture + facilitator-led demo. **No hands-on student exercise** (Sandbox-only student environments cannot exercise Pipelines or three separate governance zones).
> **Companion script:** `workshop\automation\Initialize-FacilitatorGovernanceZones.ps1` validates the facilitator's three-zone demo environments before class.

---

## Why this module exists

Day 1 builds an agent. Day 2 makes it enterprise-ready. Before participants extend the Loan Processing Agent, they need a shared mental model for two questions every regulated bank will ask:

1. **How does this agent move from a maker's hands into production safely?** (ALM)
2. **What controls are in place between exploration, team development, and production?** (Governance)

This module is intentionally concept-heavy. The hands-on muscle memory for export/import sits inside Lab 13 (solution import) and the take-home `WoodgroveLending_1_0_0_0.zip`; the policy and zone discussion sits here so Day 2 labs can focus on building.

---

## Slide 1: Why ALM matters for agents

- An agent is a **versioned application**: instructions, topics, knowledge sources, connections, environment variables, child agents — every one is a deployable artifact, not a setting.
- Treat agents the same way the bank treats any other production code path: **source of truth, peer review, traceable promotion, rollback path**.
- Without ALM, agent changes are made directly in production by whoever has access. That is a finding under **NYDFS Part 500 §500.11** (third-party / change controls) and **OCC AI guidance** (model change management).
- Day 1 you built in one Sandbox environment because the workshop is teaching the *agent*. Day 2 we widen the lens to the *delivery system around the agent*.

**Speaker note:** Open with one sentence — "Anything you cannot redeploy from source is anything you cannot defend in audit." This frames the rest of the module.

---

## Slide 2: The ALM building blocks (Solutions, Connections, Environment Variables, Pipelines)

- **Solutions** are the unit of packaging. Managed solutions in Production are immutable; unmanaged in Dev let you edit. The `WoodgroveLending` solution participants imported in Lab 13 is the canonical example.
- **Connector / Connection / Connection Reference triangle** — a **connector** is the API surface, a **connection** is one user's authenticated session, and a **connection reference** is the indirection that lets the same solution bind to a different connection in each environment. Without connection references, a solution cannot promote.
- **Environment Variables** are the configuration story — different SharePoint URLs, Dataverse environment IDs, or service endpoints per environment. The **Key Vault secret type** is the right home for any secret that would otherwise leak into solution XML.
- **Power Platform Pipelines** automates the promotion: Dev → Test → Production with optional approvers. Pipelines requires **Production** environments at the target side, which is why students cannot exercise it from a Sandbox.

**Speaker note:** Reinforce that the triangle (Connector / Connection / Connection Reference) is the single most common reason a solution import "succeeds but doesn't work" — the connection didn't bind.

---

## Slide 3: Three Zones — a PowerCAT teaching pattern (NOT an official Microsoft framework)

> **Important framing:** "Three Zones" is a **PowerCAT teaching pattern** for organizing Copilot Studio and Power Platform environments by governance posture. It is **not** a published Microsoft framework. Cite it that way when you reuse it with a customer. Microsoft Cloud Adoption Framework "landing zones" is a different concept and should not be conflated.

| Zone | Purpose | Who owns it | Governance posture |
|---|---|---|---|
| **Zone 1 — Personal Sandbox** | Maker exploration, throwaway prototypes | Individual maker | Ungoverned, ephemeral, **DLP at its strictest** (no production data connectors) |
| **Zone 2 — Team Dev** | Curated, source-controlled, shared with the team | Team / line of business | Solution-aware, peer review on import, **DLP allows curated business connectors** |
| **Zone 3 — Production** | Managed, monitored, auditable | Central platform team | Managed Environments on, **sharing limits, weekly digest, solution checker enforcement, tenant-level monitoring** |

- Promotion between zones is a **gate**, not a copy: peer review on Zone 1 → Zone 2; security and change-management review on Zone 2 → Zone 3.
- The Loan Processing Agent in this workshop lives in Zone 1 (your student Sandbox). The facilitator demo environment is the Zone 2 stand-in. A real bank deployment lives in Zone 3.

**Speaker note:** Always say "PowerCAT pattern" out loud the first time you use the term. Customers who go searching for "Microsoft Three Zones" and find nothing will lose trust in everything else you said.

---

## Slide 4: Governance overlay — DLP, Managed Environments, isolation, monitoring

- **Data Loss Prevention (DLP) policies** classify each connector as **Business**, **Non-Business**, or **Blocked**. The same agent in Zone 1 vs Zone 3 may legitimately have *different* DLP postures.
- **Environment isolation** prevents cross-environment data movement (for example, a maker in Zone 1 cannot pull production Dataverse rows into a personal flow).
- **Managed Environments** features for Zone 3:
  - **Sharing limits** — cap how many users an agent can be shared with without admin approval.
  - **Weekly digest** — admins get a rollup of new resources, sharing changes, and inactive resources.
  - **Solution checker enforcement** — block solution import if the checker finds critical issues.
  - **Maker welcome content** — set expectations the moment a maker enters the environment.
- **Tenant-level monitoring** — the Power Platform admin center surfaces capacity, license, and AI Builder / Copilot Studio credit consumption across the tenant.

**Speaker note:** This slide is where the IT Pro audience leans in. Acknowledge them and mention that the slide is intentionally heavier on platform controls than maker UX.

---

## Slide 5: FSI regulatory anchors

- **GLBA Safeguards Rule** — written information security program, access controls, and ongoing monitoring of service providers. Applies to any agent that touches non-public personal information. The Three-Zones boundary between Zone 1 and Zones 2/3 is partly *how you implement* this rule for low-code agents.
- **NYDFS Part 500 §500.11** — third-party service provider security policies. Copilot Studio plus the connectors you bind into a solution are third-party services; the bank's CISO must sign off on the connector inventory and DLP posture.
- **OCC AI guidance** (2024 principles) — model risk management, change management, and human oversight for AI/ML systems. Agent prompts and instructions are model artifacts; ALM is how you give the model-risk-management team something to validate.
- **EU AI Act Annex III §5(b)** — banking systems that affect a person's access to credit, insurance, or essential services are **high-risk AI**. The Loan Processing Agent's adjacent flows fall in scope. High-risk systems require documented risk management, data governance, transparency, human oversight, and post-market monitoring — every one of which is an ALM and Governance practice, not an agent-design practice.
- **SR 11-7** (US Federal Reserve, "Guidance on Model Risk Management") — already cited explicitly in Lab 09. Independent validation, ongoing monitoring, and a defined human-review point before customer impact. Lab 16 (autonomous triage demo) returns to this and adds the four-eyes pattern.

**Speaker note:** End with one line: "Every Day 2 lab from this point forward is, implicitly, a control you would defend in one of these reviews."

---

## Facilitator demo references

- **Three-Zones environment validation:** run `pwsh -File .\workshop\automation\Initialize-FacilitatorGovernanceZones.ps1` before class. The script reads `Governance.PersonalSandboxEnvironmentUrl`, `TeamDevEnvironmentUrl`, and `ProductionEnvironmentUrl` from `workshop-config.json` and prints a per-zone state table. Use the live console output as the demo visual for Slide 3.
- **Pipelines demo (concept only):** if a Production environment is available in the facilitator demo tenant, walk through the Power Platform Pipelines deployment stage UI — show **Dev → Test → Prod** with one approver gate. Do not attempt to run a pipeline from a student Sandbox; it will fail by design.
- **Take-home solution.zip:** point participants at `workshop\assets\WoodgroveLending_1_0_0_0.zip`. They can import the same artifact into any Production environment they later have access to and re-run the export/import muscle memory there.
- **Closing the governance loop after class:** `workshop\automation\Disable-WorkshopAutonomousTriggers.ps1` is the cleanup tool that disables the autonomous triggers introduced in the Lab 16 facilitator demo. Reference it here so the IT Pro audience sees that "build" and "decommission" are both first-class operations.

---

## Audience emphasis

- **[Maker]** — focus on Slides 1–3. Why your agent needs to look like a versioned application, what a solution actually contains, and what changes when you cross from Zone 1 to Zone 2.
- **[IT Pro]** — focus on Slides 3–5. Governance overlay, Managed Environments, and the regulatory anchors are your daily work.
- **[Developer]** — focus on Slides 2 and 5. The Connector / Connection / Connection Reference triangle and the high-risk-AI obligations under EU AI Act Annex III §5(b) are what you will be asked about in design review. Lab 25 (VS Code) is the natural follow-up for source-control workflows.

---

## Pacing

- **Total runtime:** ~30 minutes (5 slides at 5–6 minutes each, including the facilitator demo of `Initialize-FacilitatorGovernanceZones.ps1` output).
- **If running long:** compress Slide 4 to a single sentence per Managed Environments feature and skip the live console demo — the regulatory anchors on Slide 5 are the most defensible cut to *protect*, not the easiest to drop.
- **If running short:** open the floor for one customer story per zone (which environments do you have today, what would change?) — most rooms produce two or three rich exchanges.
