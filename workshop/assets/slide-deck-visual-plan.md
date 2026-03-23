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
| Slides 50, 54 | Hiring setup and multi-agent topology | `../labs/lab-13-hiring-agent-setup/assets/lab-13-agent-details.png`, `../labs/lab-15-multi-agent/assets/lab-15-agent-topology.png` |
| Slides 57, 59 | Trigger automation and model comparison | `../labs/lab-16-trigger-automation/assets/lab-16-trigger-flow.png`, `../labs/lab-17-model-selection/assets/lab-17-model-comparison.png` |
| Slides 62, 66 | Safety controls and multimodal results | `../labs/lab-18-content-moderation/assets/lab-18-prompt-sensitivity.png`, `../labs/lab-19-multimodal-prompts/assets/lab-19-json-output.png` |
| Slides 69, 72 | Dataverse grounding and generated artifact | `../labs/lab-20-dataverse-grounding/assets/lab-20-grounded-prompt.png`, `../labs/lab-21-document-generation/assets/lab-21-offer-template.png` |
| Slides 76, 80 | MCP tools and feedback view | `../labs/lab-22-mcp-integration/assets/lab-22-mcp-tools.png`, `../labs/lab-23-user-feedback/assets/lab-23-feedback-review.png` |
| Slides 83, 85 | Evaluation evidence and VS Code branch | `../labs/lab-24-agent-evaluation/assets/lab-24-evaluation-results.png`, `../labs/lab-25-vscode-extension/assets/lab-25-vscode-apply.png` |

## Custom visuals to create before final deck assembly

| Visual | Why it matters | Build from |
| --- | --- | --- |
| Two-day journey and role map | The opening deck needs one clean view of Day 1 foundation to Day 2 enterprise progression for makers, IT pros, and developers | `../participant-guide/welcome-and-overview.md`, `../participant-guide/day1-recruit-guide.md`, `../participant-guide/day2-operative-guide.md` |
| Grounding strategy comparison | The deck needs one visual that contrasts public websites, SharePoint, files, and Dataverse across freshness, structure, and ownership | `../labs/lab-06-custom-agent/README.md`, `../labs/lab-20-dataverse-grounding/README.md`, `../tests/validation-checklist.md` |
| Multi-agent responsibility view | The room needs a clearer mental model for orchestrator, child agent, connected agent, tools, and data | `../labs/lab-15-multi-agent/README.md` |
| Model trade-off comparison | Lab 17 is stronger with a simple side-by-side view for quality, latency, relative cost, and workshop fit | `../labs/lab-17-model-selection/README.md` |
| Licensing and ROI decision flow | Day 1 close and Day 2 evaluation are easier to connect if one visual shows credits, capacity, ROI analytics, and release readiness together | `../labs/lab-12-licensing/README.md`, `../labs/lab-24-agent-evaluation/README.md` |
| Channel readiness comparison | The publish section benefits from a single view that compares Teams, Microsoft 365 Copilot, web, and WhatsApp by ownership and governance | `lab-timing-guide.md`, `../facilitator-guide/facilitator-guide.md` |
| Evaluation improvement loop | Lab 24 should show a repeatable loop: test set, result, activity map, fix, rerun | `../labs/lab-24-agent-evaluation/README.md` |

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
