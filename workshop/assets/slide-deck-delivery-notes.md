# Slide Deck Delivery Notes

## How to use this source set

- Use `slide-deck-outline.md` as the master slide-by-slide narrative.
- Use `slide-deck-visual-plan.md` to pick screenshots, diagrams, and custom visuals.
- Use `lab-timing-guide.md` to preserve the intended demo-to-hands-on balance and recovery options.
- Use `screenshot-capture-checklist.md` to source workshop UI captures that prove the learner is on the right screen.
- Use `../tests/validation-checklist.md` and `../tests/environment-smoke-tests.md` to turn slide claims into live checks and facilitator fallback decisions.
- Use the lab `README.md` files when a speaker note needs exact prompt text, setup details, troubleshooting paths, or validation wording.

## Transition bridges

### Slide 5 - Into setup

- Move from workshop value to execution.
- Tell the room that every later module depends on correct account, environment, and browser state.
- Ask participants to surface blockers immediately instead of trying to catch up silently.

### Slide 41 - From build to publish

- Summarize what the room has already proven: grounded answers, structured inputs, flows, and event behavior.
- Shift the language from `can it work?` to `can we own, support, and publish it?`
- If the day is running long, shorten channel commentary before cutting the licensing and ROI close.

### Slide 46 - Day 2 restart

- Reframe Day 2 as the enterprise extension of Day 1, not a new scenario with new rules.
- Carry forward the Day 1 habits: scoped instructions, grounded sources, evidence in **Activity**, and disciplined naming.
- Tell the room that every Day 2 module increases the production-readiness pressure.

### Slide 73 - Into MCP

- Introduce MCP as governed extensibility, not open-ended plugin sprawl.
- Keep the message on supported setup, auditable tool scope, and admin trust.
- If the wizard or catalog is unavailable, switch to demo mode quickly and protect the concept.

### Slides 84-85 - Optional developer branch

- Keep the main room on evaluation, ROI, and rollout actions.
- Direct only caught-up developers to the VS Code branch.
- Reinforce that the core workshop is complete without Lab 25.

## Module delivery map

| Slides | Labs | Module focus | Speaker emphasis | Validation cue | If time slips |
| --- | --- | --- | --- | --- | --- |
| 1-7 | 00 | Workshop framing and setup | Mixed-audience value, GA guardrails, shared baseline | Correct environment, access, and visible UI readiness | Skip long introductions before you skip setup checks |
| 8-20 | 01-04 | Concepts, fundamentals, declarative patterns, solutions | Shared vocabulary, diagnostics, packaging, delivery discipline | Participants can locate major surfaces and explain solution purpose | Compress comparisons before cutting fundamentals |
| 21-34 | 05-08 | Reuse, custom agent, grounding, topics, cards | Trustworthy grounding, maintainable design, purposeful interaction | Grounded response quality, clear topic behavior, card usability | Protect Lab 06 before deeper pattern discussion |
| 35-45 | 09-12 | Actions, events, publish, licensing, ROI | Observable business outcomes, ownership, rollout credibility | Flows and triggers behave visibly; publish and licensing questions are concrete | Switch publish to checklist review if tenant variability is high |
| 46-54 | 13-15 | Hiring setup, instructions, multi-agent architecture | Day 2 progression, orchestration boundaries, specialist ownership | Hiring Agent baseline is stable and delegation behavior is visible | Pre-stage the connected agent if time is short |
| 55-62 | 16-18 | Automation, model choice, safety | Automation as commitment, model choice as trade-off, safety as layered control | Trigger evidence, stable baseline model, safe refusal behavior | Compare only two models if the room is behind |
| 63-72 | 19-21 | Multimodal, Dataverse, document generation | Controlled usefulness, governed data, reviewable outputs | Prompt output is job-related and grounded; documents are review-ready | Demo one multimodal or document path centrally if needed |
| 73-76 | 22 | MCP and governed extensibility | Supported wizard path, narrow tool scope, admin trust | MCP tool appears, authenticates, and fits the scenario | Switch early to facilitator demo if the catalog is unavailable |
| 77-80 | 23 | Channels and feedback | Reach, ownership, backlog inputs, adoption signals | Feedback path exists and someone owns follow-up | Use one shared feedback submission if time is tight |
| 81-85 | 24-25 | Evaluation, ROI, optional developer branch | Release gates, evidence-based improvement, optional local workflow | Evaluation shows pass/fail evidence and one improvement loop | Protect Lab 24; move Lab 25 to follow-up if needed |

## Pre-lab facilitator guidance by module

Modules below have thin concept coverage relative to their lab time. The facilitator should compensate with the whiteboard activities, live demos, and orientation walkthroughs described here. Each item is designed to run during the slide portion of the module, before participants begin the hands-on lab.

### Module 04 — Custom Agent Design (slides 21-25, Labs 06)

- **Whiteboard: grounding source ladder.** Before Lab 06, draw the four-rung grounding ladder on a whiteboard or shared canvas: public web → SharePoint sites/libraries → uploaded files → Dataverse tables. Walk the room through each rung, explain the trust and governance trade-offs (public web is broadest but least controlled; Dataverse is narrowest but fully governed), and ask participants to identify which source type their own organization would use first. This sets the mental model for why Lab 06 starts with SharePoint grounding rather than a simpler but less realistic source.
- **Demo: SharePoint knowledge source metadata filters.** Open Copilot Studio, navigate to an existing agent's knowledge sources, and show the metadata filter configuration pane for a SharePoint knowledge source. Highlight how site-level versus library-level scoping affects answer quality and how metadata filters (content type, column values) narrow grounding to relevant documents. Participants who see this configuration before Lab 06 will understand the setup steps instead of clicking through them blindly.
- **Demo: model picker and selection trade-off.** Open the model picker in the agent settings and demonstrate switching from the "Default" label (GPT-4.1) to GPT-5 Chat. Explain the trade-off: GPT-5 Chat delivers stronger reasoning and richer completions but consumes more capacity credits per message; GPT-4.1 is faster and cheaper for high-volume, lower-complexity scenarios. Tell participants they will revisit model selection formally in Module 08 (Lab 17), but they should be aware of the picker location now so they can experiment during Lab 06 if they finish early.

### Module 05 — Topic Design (slides 26-33, Labs 07+08)

- **Orientation: Adaptive Cards designer.** Before Lab 08, open [adaptivecards.io/designer](https://adaptivecards.io/designer) in the browser and walk the room through the interface: the card payload editor on the left, the live preview in the center, and the host-app selector at the top. Load one built-in template (for example, the "Weather" or "Input Form" sample), point out the `TextBlock`, `Input.Text`, and `Action.Submit` elements, and show how editing JSON on the left updates the preview immediately. Participants who have never used the external designer need this 3-minute orientation so they can troubleshoot card JSON independently during Lab 08.
- **Demo: Power Fx formula mode and ForAll().** In Copilot Studio's topic editor, open a message node that uses an Adaptive Card, switch from the JSON view to Formula mode using the JSON-to-Formula toggle, and show the resulting Power Fx expression. Then write or paste one `ForAll()` expression that iterates over a table variable and builds a repeated card element (for example, `ForAll(Devices, {title: ThisRecord.Name, value: ThisRecord.Status})`). Explain that Formula mode lets makers use familiar Power Fx instead of raw JSON, but the two views are interchangeable — edits in one appear in the other. Run the topic in a test session so participants see the rendered output before they attempt their own card in Lab 08.

### Module 07 — Hiring Architecture (slides 46-54, Labs 13-15)

- **Whiteboard: orchestrator → child/connected agent topology.** Before Lab 15, draw the multi-agent topology on a whiteboard: a central orchestrator agent at the top, with arrows pointing down to one or more child or connected specialist agents. Label the orchestrator as the "Hiring Agent" and one child as a specialist (for example, "Resume Screener"). Explain the routing: the orchestrator receives the user message, evaluates delegation instructions, and forwards to the appropriate specialist. The specialist completes its task and returns control to the orchestrator. Emphasize that each agent owns its own instructions, knowledge sources, and topic set — the orchestrator does not duplicate them.
- **Demo: "Let other agents connect" toggle.** Open a specialist agent's settings in Copilot Studio and show the "Let other agents connect to and use this one" toggle. Explain that enabling this toggle is what makes the agent available as a connected agent in the orchestrator's agent list. Without this toggle, the agent is standalone and invisible to other agents. Show where the toggle appears and what the confirmation message looks like.
- **Demo: delegation wiring in instructions.** Open the orchestrator agent's instructions pane and show one example of delegation wording — for example, `When the user asks about resume screening, delegate to the Resume Screener agent.` Explain that the instruction text is what the orchestrator's language model uses to decide when to route; vague instructions produce unreliable delegation. Point out that the connected agent must already be toggled on and listed in the orchestrator's agent references before the instruction can reference it.

### Module 09 — Multimodal and Data (slides 63-72, Labs 19-21)

- **Walkthrough: Dataverse tables readiness check.** Before Lab 20, open the Power Apps maker portal, navigate to the Dataverse tables view, and verify that the Hiring Hub tables are visible: `Job Role`, `Evaluation Criteria`, `Candidate`, `Resume`, and `Job Application`. Walk the room through one table's columns and a few sample rows so participants know what correct data looks like. Emphasize that if any of these tables are missing or empty, the problem is data readiness (the Operative solution import or base data load did not complete), not a model or prompt problem. This single check prevents the most common Lab 20 support escalation.
- **Demo: completed Word template and merge field pattern.** Before Lab 21, open a completed Word template (`.docx`) that contains merge fields and show it on screen. Point out the merge field syntax (for example, `<<CandidateName>>`, `<<JobTitle>>`, `<<InterviewDate>>`), explain that these placeholders are replaced by Dataverse column values at generation time, and show the resulting generated document side by side with the template. Participants who see the before-and-after understand the pattern immediately and spend less time debugging field-name mismatches during Lab 21.

### Module 10 — MCP and Extensibility (slides 73-76, Lab 22)

- **Whiteboard: classic connectors vs MCP mental model.** Draw two diagrams side by side. On the left, draw the classic connector model: one connector corresponds to one action, and the agent must be wired to each action individually (for example, "Get items from SharePoint list" is one connector action, "Send email" is another). On the right, draw the MCP model: one MCP server exposes many tools, and the agent discovers and invokes them dynamically through a single server connection. Label the MCP side with the Work IQ MCP server as the concrete example. Explain that the MCP model reduces per-action wiring but requires the server to be registered, consented, and governed — the agent cannot call arbitrary endpoints.
- **Live demo: MCP server catalog → connection → consent flow.** Before Lab 22, walk through the full MCP onboarding sequence live on screen: open Copilot Studio → navigate to the MCP server catalog → select the Work IQ server → create the connection → walk through the consent card that appears (explain what permissions are being granted and why) → confirm the server appears in the agent's tool list. Participants who see this end-to-end flow before Lab 22 will recognize each step when they perform it and will not stall at the consent card, which is the most common point of confusion.

### Module 11 — Channels and Feedback (slides 77-80, Labs 11+23)

- **Live demo: publish-to-Teams workflow.** Before Lab 11, walk through the full publish and channel activation sequence on screen: click **Publish** → wait for the publish confirmation → navigate to **Channels** → select **Microsoft channels** → click **Add channel** → choose **Teams** → review the availability options (show in Teams app store, share via link, or install for specific users/groups). Explain that publishing makes a new version available but does not automatically push it to any channel — the channel step is a separate, explicit action. This walkthrough prevents the most common Lab 11 confusion where participants publish but cannot find their agent in Teams.
- **Contextual mention: WhatsApp and multi-channel reach.** Briefly navigate to the **Other channels** section in the Channels pane and show where WhatsApp appears in the list. Do not configure it — just show its location and explain in one or two sentences why multi-channel matters: the same agent logic can serve Teams users internally and WhatsApp users externally, and the channel choice affects authentication, card rendering, and message formatting. This 60-second mention gives participants awareness of the breadth without consuming lab time.

### Module 12 — Evaluation and ROI (slides 81-85, Lab 24)

- **Live demo: Evaluation tab orientation.** Before Lab 24, open the **Evaluation** tab in Copilot Studio and walk the room through the three main areas: the **Test sets** list (where CSV-based test cases are uploaded), the **Graders** list (where evaluation criteria are configured), and the **Run results** panel (where completed evaluation runs show pass/fail counts and individual case outcomes). Point out the "New evaluation run" button and explain the workflow: upload test set → select graders → run → review results. Participants who see this layout before Lab 24 will orient themselves immediately instead of searching for the right tab.
- **Explanation: grader types.** Briefly describe the grader types available in the evaluation surface so participants understand what each one measures before they configure their own:
  - **General quality** — assesses whether the agent's response is helpful, accurate, and well-formed relative to the test case's expected answer.
  - **Compare meaning** — checks whether the agent's response preserves the semantic meaning of the expected answer, even if the wording differs.
  - **Tool use** — verifies that the agent invoked the correct tools (actions, connectors, MCP servers) during the conversation, not just that the final text was correct.
  - **Keyword match** — confirms that specific required keywords or phrases appear in the agent's response, useful for compliance or branding checks.
  - **Text similarity** — measures how closely the agent's response text matches the expected answer at a string level.
  - **Exact match** — checks whether the agent's response is an exact match to the expected answer.
  - **Custom Graders** — a Classification method that lets organizations encode their own policies, quality standards, or rules directly into the evaluation.
- **Demo: Activity map on a failed test case.** After showing the evaluation tab, open one failed test case from a previous run (or trigger one intentionally) and click **Show activity map**. Walk through the activity map view: show the sequence of nodes the agent traversed, highlight where the conversation diverged from the expected path, and explain how the map helps diagnose whether the failure was a grounding problem (wrong knowledge source), a routing problem (wrong topic or delegation), or a generation problem (correct data but poor completion). This diagnostic view is new to most participants and is the single most useful tool for improving evaluation scores after Lab 24.

## Audience emphasis by recurring theme

- [Maker] Watch instruction quality, conversation design, grounding behavior, and feedback usefulness.
- [IT Pro] Watch environment readiness, permissions, connectors, channels, DLP, capacity, and governed rollout.
- [Developer] Watch solution structure, orchestration boundaries, grounded data strategy, MCP scope, and the optional VS Code path.

## Pacing and recovery guardrails

- Protect Labs `06`, `18`, `22`, and `24` before optional depth.
- If Day 1 runs long before Lab 06, compress declarative and prebuilt comparison rather than cutting the custom-agent build.
- If Day 1 runs long after Lab 10, switch publish to facilitator-led readiness review and preserve the licensing and ROI close.
- If Day 2 runs long before Lab 17, compare only the workshop baseline model and one fallback.
- If Day 2 runs long before Lab 22, move MCP to demo mode quickly and protect Lab 24.
- If Lab 24 finishes early, run a second evaluation iteration instead of moving to Lab 25 early.
- Put the current lab number and restart point on screen before every break.

## Parallel tasks while building the deck

- Confirm screenshot availability and decide which visuals need annotation versus a clean raw capture.
- Create custom visuals for the concepts the screenshots cannot explain well, especially grounding strategy, orchestration, licensing or ROI, channels, and evaluation loops.
- Capture a small failure-state library during a dry run so the deck can teach recovery paths, not only happy paths.
- Rehearse timing with a real clock and mark which sections are safe to compress when the room is behind.
- Validate that model names, GA terminology, and MCP setup guidance still match the current product experience before finalizing the deck.

## Recommended dry-run focus areas

- Lab 06 for SharePoint grounding readiness and DLP behavior.
- Lab 15 for delegation clarity and **Activity map** interpretation.
- Lab 18 for safe classroom red-team prompts and layered-control explanation.
- Lab 20 for Dataverse data readiness versus prompt issues.
- Lab 22 for MCP catalog availability and consent behavior.
- Lab 24 for evaluation account setup, grader interpretation, and comparison workflow.
