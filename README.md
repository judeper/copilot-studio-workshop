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

Setup scripts live in [`workshop/automation/`](workshop/automation/). Copy `workshop-config.example.json` to `workshop-config.json` and fill in your tenant details before running:

```powershell
# Install local prerequisites
powershell -File .\workshop\automation\Install-WorkshopPrerequisites.ps1

# Validate configuration
powershell -File .\workshop\automation\Invoke-WorkshopPrereqCheck.ps1

# Pre-stage Day 1 environment
powershell -File .\workshop\automation\Invoke-WorkshopLabSetup.ps1 -Mode StudentReady
```

See the [Facilitator Guide](workshop/facilitator-guide/facilitator-guide.md) for the full delivery checklist.

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
