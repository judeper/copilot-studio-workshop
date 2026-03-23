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
