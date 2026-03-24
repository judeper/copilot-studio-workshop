# Copilot Studio Workshop

A two-day, hands-on workshop for building, extending, and governing AI agents with [Microsoft Copilot Studio](https://copilotstudio.microsoft.com).

## Workshop Overview

| | Day 1 — Recruit Track | Day 2 — Operative Track |
|---|---|---|
| **Theme** | Foundation-building | Governed enterprise extension |
| **Scenario** | Contoso IT Helpdesk Agent | Hiring Agent & Operative solution |
| **Labs** | 00–12 | 13–25 |
| **Audience** | Makers, IT Pros, Developers | Same — building on Day 1 skills |

## Quick Start

1. **Prerequisites** — A work or school Microsoft 365 account, Copilot Studio access, and a Power Platform environment. See [Lab 00](workshop/labs/lab-00-environment-setup/) for full setup.
2. **Participant guide** — Start with [Welcome and Overview](workshop/participant-guide/welcome-and-overview.md).
3. **Facilitator guide** — See [Facilitator Guide](workshop/facilitator-guide/facilitator-guide.md) for delivery flow, environment readiness, and automation.

## Workshop Materials

### Presentation Slides

The workshop includes 13 committed PowerPoint presentation decks covering the full two-day curriculum.

- **Location:** `workshop\Copilot-Studio-Workshop-Slides\`
- **Format:** Delivery-ready PPTX files for instructor-led presentation and screen sharing
- **Size:** 95 slides total across 13 module decks

| Module | File | Focus area |
|---|---|---|
| 00 | `Module-00-Workshop-Framing.pptx` | Workshop introduction and objectives |
| 01 | `Module-01-Agents-Today.pptx` | Current state of AI agents |
| 02 | `Module-02-Studio-Foundations.pptx` | Copilot Studio basics |
| 03 | `Module-03-Reuse-Patterns.pptx` | Template and pattern reuse |
| 04 | `Module-04-Custom-Agent-Design.pptx` | Custom agent architecture |
| 05 | `Module-05-Topic-Design.pptx` | Conversational topic patterns |
| 06 | `Module-06-Actions-and-Events.pptx` | Actions and event-driven design |
| 07 | `Module-07-Hiring-Architecture.pptx` | Enterprise hiring scenario |
| 08 | `Module-08-Automation-and-Models.pptx` | Automation and model strategy |
| 09 | `Module-09-Multimodal-and-Data.pptx` | Multimodal capabilities and data grounding |
| 10 | `Module-10-MCP-and-Extensibility.pptx` | MCP and extensibility patterns |
| 11 | `Module-11-Channels-and-Feedback.pptx` | Channel rollout and feedback loops |
| 12 | `Module-12-Evaluation-and-ROI.pptx` | Evaluation and ROI measurement |

### Companion Materials

- **Markdown outline:** `workshop\assets\slide-deck-outline.md` — 85 numbered entries with speaker notes, narrative structure, and teaching intent
- **Lab timing guide:** `workshop\assets\lab-timing-guide.md` — detailed pacing and delivery guidance for labs
- **Session splitting guide:** `workshop\assets\session-splitting-guide.md` — alternative multi-session delivery formats
- **Facilitator guide:** `workshop\facilitator-guide\facilitator-guide.md` — complete delivery flow, readiness guidance, and recovery notes

The repository maintains slides in two parallel formats:

- **PPTX decks** are the authoritative delivery artifacts with visual design and live presentation flow.
- **The markdown outline** is the narrative companion used for speaker notes, teaching intent, and text-first review.

When slide structure, sequencing, or teaching intent changes, keep both assets aligned.

### For Facilitators

Before live delivery, review these materials together:

1. The PPTX decks in `workshop\Copilot-Studio-Workshop-Slides\`
2. The markdown outline in `workshop\assets\slide-deck-outline.md`
3. The facilitator guide in `workshop\facilitator-guide\facilitator-guide.md`
4. The lab timing guide in `workshop\assets\lab-timing-guide.md`
5. The session splitting guide in `workshop\assets\session-splitting-guide.md`

Use the PPTX decks for presentation and screen sharing, then use the markdown outline when you need detailed speaker notes or a text-first review of the teaching flow.

## Lab Index

### Day 1 — Recruit Track

| Lab | Title | Time |
|-----|-------|------|
| [00](workshop/labs/lab-00-environment-setup/) | Environment Setup | 45 min |
| [01](workshop/labs/lab-01-intro-to-agents/) | Intro to Agents | 20 min |
| [02](workshop/labs/lab-02-copilot-studio-fundamentals/) | Copilot Studio Fundamentals | 30 min |
| [03](workshop/labs/lab-03-declarative-agents/) | Declarative Agents | 60 min |
| [04](workshop/labs/lab-04-solutions/) | Solutions | 45 min |
| [05](workshop/labs/lab-05-prebuilt-agents/) | Prebuilt Agents | 30 min |
| [06](workshop/labs/lab-06-custom-agent/) | Custom Agent | 75 min |
| [07](workshop/labs/lab-07-topics-triggers/) | Topics & Triggers | 60 min |
| [08](workshop/labs/lab-08-adaptive-cards/) | Adaptive Cards | 45 min |
| [09](workshop/labs/lab-09-agent-flows/) | Agent Flows | 45 min |
| [10](workshop/labs/lab-10-event-triggers/) | Event Triggers | 25 min |
| [11](workshop/labs/lab-11-publish-agent/) | Publish Agent | 30 min |
| [12](workshop/labs/lab-12-licensing/) | Licensing | 20 min |

### Day 2 — Operative Track

| Lab | Title | Time |
|-----|-------|------|
| [13](workshop/labs/lab-13-hiring-agent-setup/) | Hiring Agent Setup | 45 min |
| [14](workshop/labs/lab-14-agent-instructions/) | Agent Instructions | 25 min |
| [15](workshop/labs/lab-15-multi-agent/) | Multi-Agent Hiring Team | 40 min |
| [16](workshop/labs/lab-16-trigger-automation/) | Trigger Automation | 40 min |
| [17](workshop/labs/lab-17-model-selection/) | Model Selection | 30 min |
| [18](workshop/labs/lab-18-content-moderation/) | Content Moderation | 40 min |
| [19](workshop/labs/lab-19-multimodal-prompts/) | Multimodal Prompts | 35 min |
| [20](workshop/labs/lab-20-dataverse-grounding/) | Dataverse Grounding | 40 min |
| [21](workshop/labs/lab-21-document-generation/) | Document Generation | 45 min |
| [22](workshop/labs/lab-22-mcp-integration/) | MCP Integration | 45 min |
| [23](workshop/labs/lab-23-user-feedback/) | User Feedback | 30 min |
| [24](workshop/labs/lab-24-agent-evaluation/) | Agent Evaluation | 45 min |
| [25](workshop/labs/lab-25-vscode-extension/) | VS Code Extension (Optional) | 30 min |

## Facilitator Automation

On a fresh Windows 11 machine, open PowerShell and run:

```powershell
mkdir C:\workshop; cd C:\workshop
irm https://raw.githubusercontent.com/judeper/copilot-studio-workshop/master/workshop/automation/Invoke-WorkshopBootstrap.ps1 -OutFile .\Bootstrap.ps1
.\Bootstrap.ps1
```

This downloads and runs the interactive bootstrap wizard, which:
- Installs PowerShell 7 (if running PS 5.1), then re-launches itself
- Installs git, Power Platform CLI, and Node.js (via winget) if missing
- Clones this repository if not already on disk
- Installs required PowerShell modules (PnP.PowerShell, Microsoft.Graph, PowerApps Admin)
- Auto-creates an Entra app registration with required API permissions
- Walks through config setup interactively (tenant name → auto-derives all URLs)
- Sets up pac CLI authentication
- Downloads all workshop assets
- Validates every prerequisite and shows a readiness dashboard

If you already have the repo cloned, run the wizard directly:

```powershell
pwsh -File .\workshop\automation\Invoke-WorkshopBootstrap.ps1
```

After the wizard completes:

```powershell
# 1. Pre-stage shared Day 1 prerequisites (Contoso IT site, lists, schema, and sample data)
powershell -File .\workshop\automation\Invoke-WorkshopLabSetup.ps1 -Mode StudentReady

# 2. Optional: create or reserve a separate facilitator demo environment
powershell -File .\workshop\automation\Initialize-WorkshopPowerPlatformEnvironment.ps1 -CreateEnvironment

# 3. Optional: pre-import Operative solution in the facilitator demo environment only
powershell -File .\workshop\automation\Import-WorkshopOperativeAssets.ps1 -ImportSolution

# 4. Optional: batch-provision per-student environments for hands-on
powershell -File .\workshop\automation\Invoke-StudentEnvironmentProvisioning.ps1

# 5. Reset the shared environment for re-testing (deletes ContosoIT site + purges recycle bin)
pwsh -File .\workshop\automation\Reset-WorkshopEnvironment.ps1 -HardDelete

# 6. Post-workshop: tear down all student environments
powershell -File .\workshop\automation\Remove-StudentEnvironments.ps1 -HardDelete
```

Treat setup as three separate readiness tracks:

- **Shared prerequisites** — bootstrap, the shared Day 1 SharePoint site, and Day 2 assets.
- **Facilitator demo base** — a separate demo environment used only for facilitator fallback demos and optional Day 2 solution imports.
- **Student hands-on environments** — either the shared `StudentReady` path or the optional per-student provisioning path.

The current automation is optimized for a **clean validated facilitator demo base**, not a fully prebuilt “all labs completed” demo environment. If you need completed end-state artifacts for rescue demos, keep separate checkpoints, screenshots, or demo snapshots in addition to the automated setup above.

See the [Facilitator Guide](workshop/facilitator-guide/facilitator-guide.md) for the quick facilitator runbook and the full delivery checklist.

## PDF Workbooks

Generate printable PDF files for students and facilitators:

```powershell
cd workshop\automation
npm install
node Generate-WorkshopPDFs.js
```

Output lands in `workshop/pdf-output/`:

| # | Student PDFs | Facilitator PDFs |
|---|---|---|
| 01 | Welcome & Overview | Facilitator Guide |
| 02 | Day 1 Workbook (Labs 00–12) | Environment Readiness Pack |
| 03 | Day 2 Workbook (Labs 13–24) | Session Splitting Guide |
| 04 | Optional Developer Lab (Lab 25) | Lab Timing Guide |
| 05 | | Slide Deck Outline |
| 06 | | Lab Validation Reference |

Generate a subset with `--only`: `node Generate-WorkshopPDFs.js --only S2,F1`

## Key Scenario Names

| Name | Purpose |
|------|---------|
| Contoso IT | SharePoint site for Day 1 grounding |
| Contoso Helpdesk Agent | Day 1 custom agent |
| Hiring Agent | Day 2 orchestrator agent |
| Operative | Day 2 Dataverse solution |
| Hiring Hub | Day 2 model-driven app |
| AgentCreators | Security group for authoring permissions |

## License

This workshop content is provided for educational use. See the repository license for details.
