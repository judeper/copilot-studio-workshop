# Day 2 Operative Guide

Day 2 builds on the skills from Day 1 and applies them to an enterprise-style Hiring Agent scenario. You will move beyond a single agent and work through patterns that matter when a solution needs structure, safety, and operational discipline.

## Scenario summary

The Hiring Agent scenario represents a realistic business workflow where multiple responsibilities must come together. Instead of treating the agent as a single prompt box, you will explore how instructions, connected agents, automation, data grounding, safety controls, and document generation combine into a coordinated experience.

## Prerequisites

Before you begin Day 2, make sure:

- You completed Day 1, earned the Recruit badge, or have equivalent Copilot Studio experience.
- You can access the correct Power Platform environment.
- Dataverse is available in the target environment.
- You can access any required SharePoint or source documents.
- You understand that Day 2 focuses on GA capabilities and production-oriented practices.

For MCP and the optional developer workflow, also confirm:

- The Copilot Studio MCP onboarding wizard is available in your environment.
- Visual Studio Code is available on your machine if you are following the optional developer module.
- The Copilot Studio extension for Visual Studio Code is available if your facilitator is including that workflow.

## Delivery paths

- **Core shared path (Labs 13–24):** Everyone follows the Hiring Agent setup, orchestration, automation, safety, grounding, feedback, and evaluation sequence.
- **Optional/stretch path (Lab 25):** Developers who finish the core path can branch into the Visual Studio Code workflow while the main room stays on evaluation recap, ROI analytics, and next-step planning.

## Module flow

Use this sequence as your guide through the day.

### Core shared path

1. Set up or review the Hiring Agent foundation.
2. Improve agent behavior through stronger instructions.
3. Connect agents for multi-agent orchestration.
4. Add automation and trigger-based behavior.
5. Compare model and response-formatting choices.
6. Apply safety and content moderation practices.
7. Process documents with multimodal prompts.
8. Ground agent behavior with Dataverse data.
9. Generate an interview-prep style document.
10. Configure MCP integration with the in-product wizard.
11. Capture user feedback and review next steps.
12. Evaluate the Hiring Agent with test sets and activity maps.

### Optional/stretch path

13. [Developer] Optionally edit and sync the agent from Visual Studio Code after you are caught up on the core shared path.

Helpful lab links:

Core shared path:

- [Lab 13 - Hiring Agent Setup](../labs/lab-13-hiring-agent-setup/)
- [Lab 14 - Agent Instructions](../labs/lab-14-agent-instructions/)
- [Lab 15 - Multi-Agent](../labs/lab-15-multi-agent/)
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

- A clear picture of the Hiring Agent architecture and role of each component.
- Practical experience with instruction tuning and multi-agent design.
- Exposure to automation, model selection, and safety controls.
- An example of enterprise grounding through Dataverse or equivalent business data.
- A clear understanding of where MCP can extend the Hiring Agent with governed tools.
- A repeatable evaluation workflow that can be reused on future agents.
- A final solution story you can explain back to your team.

## Safety and governance emphasis

Day 2 is where governance becomes visible in the build. Pay attention to:

- Who can access the environment and data sources.
- How prompt and instruction choices affect output quality and risk.
- How content moderation and safety checks should be tested, not assumed, including per-prompt content moderation levels where needed.
- How document processing and generated outputs should be reviewed before broader rollout.
- How MCP access should be scoped to the minimum useful tool set.

> **Warning:** A working demo is not the same as a production-ready implementation. Use each module to identify controls your organization would need before launch.

## MCP and evaluation expectations

MCP is included as a GA capability that can be configured directly inside Copilot Studio. In this workshop, treat MCP as part of the governed toolset for the Hiring Agent.

If you are following along hands-on, expect to validate:

- You can open the MCP onboarding wizard in Copilot Studio.
- You can add or review at least one MCP server in the target environment.
- You can explain which tools should and should not be exposed to an AI assistant.
- You can review an evaluation run, inspect activity maps, and identify at least one improvement opportunity.

> **Note:** The optional Visual Studio Code workflow is reserved for participants who want a developer-centric authoring loop. It is not required for the main Day 2 path.

## Audience notes

- [Maker] Focus on instruction quality, user journey, and feedback capture.
- [IT Pro] Focus on safety, permissions, environment controls, and operational readiness.
- [Developer] Focus on orchestration, grounding strategy, extensibility, MCP tooling, and the optional VS Code workflow.

## Wrap-up guidance

At the end of Day 2, make sure you can explain:

- Why the Hiring Agent is structured as a coordinated solution instead of a single prompt.
- Which controls are required for safe and governed enterprise use.
- Which modules you would prioritize first in your own organization.
- What additional validation would be needed before production rollout.

If your facilitator is mapping the day to the Operative path, use your completed modules as the basis for post-workshop follow-through and badge completion.

