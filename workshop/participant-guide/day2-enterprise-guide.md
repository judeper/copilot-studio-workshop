# Day 2 Enterprise Guide

Day 2 builds on the skills from Day 1 and applies them to an enterprise-style Loan Processing Agent scenario. You will move beyond a single agent and work through patterns that matter when a solution needs structure, safety, and operational discipline in a financial services context.

## Scenario summary

The Loan Processing Agent scenario represents a realistic lending workflow where multiple responsibilities must come together. Instead of treating the agent as a single prompt box, you will explore how instructions, connected agents, automation, data grounding, safety controls, and document generation combine into a coordinated experience for loan officers and applicants.

## Prerequisites

Before you begin Day 2, make sure:

- You completed Day 1 or have equivalent Copilot Studio experience.
- You can access the correct Power Platform environment.
- Dataverse is available in the target environment.
- You can access any required SharePoint or financial documents.
- You understand that Day 2 focuses on GA capabilities and production-oriented practices.

For MCP and the optional developer workflow, also confirm:

- The Copilot Studio MCP onboarding wizard is available in your environment.
- You have an M365 Copilot license if you plan to use the Work IQ MCP server for Microsoft 365 data integration.
- Visual Studio Code is available on your machine if you are following the optional developer module.
- The Copilot Studio extension for Visual Studio Code is available if your facilitator is including that workflow.

## Delivery paths

- **Core shared path (Labs 13–24):** Everyone follows the Loan Processing Agent setup, orchestration, automation, safety, grounding, feedback, and evaluation sequence.
- **Optional/stretch path (Lab 25):** Developers who finish the core path can branch into the Visual Studio Code workflow while the main room stays on evaluation recap, ROI analytics, and next-step planning.

## Module flow

Use this sequence as your guide through the day.

### Core shared path

1. Set up or review the Loan Processing Agent foundation using the Woodgrove Lending Hub.
2. Improve agent behavior through stronger instructions.
3. Connect agents for multi-agent orchestration (Document Review Agent, Loan Advisory Agent).
4. Add automation and trigger-based behavior.
5. Compare model and response-formatting choices.
6. Apply safety and content moderation practices for lending decisions and financial data.
7. Process financial documents with multimodal prompts.
8. Ground agent behavior with Dataverse data (loan applications and applicant records).
9. Generate a loan assessment report.
10. Configure MCP integration with the in-product wizard, including Work IQ MCP for M365 data.
11. Capture user feedback and review next steps.
12. Evaluate the Loan Processing Agent with test sets and activity maps.

### Optional/stretch path

13. [Developer] Optionally edit and sync the agent from Visual Studio Code after you are caught up on the core shared path.

Helpful lab links:

Core shared path:

- [Lab 13 - Loan Processing Agent Setup](../labs/lab-13-hiring-agent-setup/)
- [Lab 14 - Agent Instructions](../labs/lab-14-agent-instructions/)
- [Lab 15 - Multi-Agent Orchestration](../labs/lab-15-multi-agent/)
- [Lab 16 - Trigger Automation](../labs/lab-16-trigger-automation/)
- [Lab 17 - Model Selection](../labs/lab-17-model-selection/)
- [Lab 18 - Content Moderation](../labs/lab-18-content-moderation/)
- [Lab 19 - Multimodal Prompts](../labs/lab-19-multimodal-prompts/)
- [Lab 20 - Dataverse Grounding](../labs/lab-20-dataverse-grounding/)
- [Lab 21 - Document Generation](../labs/lab-21-document-generation/)
- [Lab 22 - MCP Integration](../labs/lab-22-mcp-integration/)
- [Lab 23 - User Feedback](../labs/lab-23-user-feedback/)
- [Lab 24 - Agent Evaluation](../labs/lab-24-agent-evaluation/)

Optional/stretch path:

- [Lab 25 - VS Code Extension](../labs/lab-25-vscode-extension/)

## Deliverables

By the end of Day 2, you should have:

- A clear picture of the Loan Processing Agent architecture and the role of each component.
- Practical experience with instruction tuning and multi-agent design for lending workflows.
- Exposure to automation, model selection, and safety controls appropriate for financial services.
- An example of enterprise grounding through Dataverse with loan applications and applicant data.
- A clear understanding of where MCP (including Work IQ MCP) can extend the Loan Processing Agent with governed tools.
- A repeatable evaluation workflow that can be reused on future agents.
- A final solution story you can explain back to your team.

## Safety and governance emphasis

Day 2 is where governance becomes visible in the build. In a financial services context, pay attention to:

- Who can access the environment, applicant PII, and financial data sources.
- How prompt and instruction choices affect output quality and risk, especially for lending decisions and financial advice.
- How content moderation and safety checks should be tested, not assumed, including per-prompt content moderation levels where needed.
- How financial document processing and generated outputs (such as loan assessment reports) should be reviewed before broader rollout.
- How MCP access should be scoped to the minimum useful tool set, with particular care around financial data exposure.

> **Warning:** A working demo is not the same as a production-ready implementation. Use each module to identify controls your organization would need before launch, especially regulatory and compliance requirements for lending workflows.

## MCP and evaluation expectations

MCP is included as a GA capability that can be configured directly inside Copilot Studio. In this workshop, treat MCP as part of the governed toolset for the Loan Processing Agent. The Work IQ MCP server enables integration with Microsoft 365 data and requires an M365 Copilot license.

If you are following along hands-on, expect to validate:

- You can open the MCP onboarding wizard in Copilot Studio.
- You can add or review at least one MCP server in the target environment.
- You can explain which tools should and should not be exposed to an AI assistant handling financial data.
- You can review an evaluation run, inspect activity maps, and identify at least one improvement opportunity.

> **Note:** The optional Visual Studio Code workflow is reserved for participants who want a developer-centric authoring loop. It is not required for the main Day 2 path.

## Audience notes

- [Maker] Focus on instruction quality, user journey, and feedback capture for lending scenarios.
- [IT Pro] Focus on safety, permissions, environment controls, financial data governance, and operational readiness.
- [Developer] Focus on orchestration, grounding strategy, extensibility, MCP tooling, and the optional VS Code workflow.

## Wrap-up guidance

At the end of Day 2, make sure you can explain:

- Why the Loan Processing Agent is structured as a coordinated solution instead of a single prompt.
- Which controls are required for safe and governed enterprise use in financial services.
- Which modules you would prioritize first in your own organization.
- What additional validation would be needed before production rollout, including regulatory and compliance considerations.

Use your completed modules as the basis for Day 2 completion and post-workshop follow-through.

