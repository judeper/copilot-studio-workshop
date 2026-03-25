# Slide Deck Outline

Use this master outline with `slide-deck-delivery-notes.md`, `slide-deck-visual-plan.md`, `lab-timing-guide.md`, and `screenshot-capture-checklist.md` when building or presenting the workshop deck.

> **Companion document:** This markdown outline provides the narrative structure, speaker notes, and teaching intent for the workshop presentation decks.
>
> **Delivery artifacts:** The live presentation files live in `workshop\Copilot-Studio-Workshop-Slides\` as 13 PPTX module decks with 95 slides total.
>
> **Relationship:** The PPTX decks are the delivery-ready presentation artifacts with visual design and presentation flow. This outline is the text-first companion used for speaker notes, narrative structure, and teaching strategy review.
>
> **Alignment note:** This outline contains 92 numbered entries while the PPTX corpus contains 95 slides. The counts do not match one-for-one because the decks may split title, transition, or visual teaching moments across multiple slides while the outline combines them into fewer narrative entries.
>
> **Per-module slide counts (PPTX):**
>
> | Module | Deck | PPTX Slides | Outline Entries |
> |--------|------|-------------|-----------------|
> | 00 | Workshop Framing | 8 | 7 |
> | 01 | Agents Today | 6 | 3 |
> | 02 | Studio Foundations | 11 | 10 |
> | 03 | Reuse Patterns | 5 | 3 |
> | 04 | Custom Agent Design | 5 | 7 (+3 new) |
> | 05 | Topic Design | 8 | 7 |
> | 06 | Actions and Events | 11 | 11 |
> | 07 | Hiring Architecture | 9 | 9 |
> | 08 | Automation and Models | 8 | 8 |
> | 09 | Multimodal and Data | 10 | 10 |
> | 10 | MCP and Extensibility | 4 | 6 (+2 new) |
> | 11 | Channels and Feedback | 4 | 6 (+2 new) |
> | 12 | Evaluation and ROI | 6 | 5 |
> | | **Total** | **95** | **92** (85 + 7 new) |

## Day 1: Labs 00-12

### Slide 1: Welcome and goals
- Welcome makers, IT pros, and developers into one shared Copilot Studio learning path.
- Set the expectation that Day 1 builds foundations and Day 2 turns them into an operational Hiring Agent solution.
- Define success as building, testing, evaluating, and explaining a production-ready direction.
**Speaker note:** Open with outcomes and reassure the room that mixed roles are a strength, not a barrier.

### Slide 2: Two-day outcomes
- Explain that Day 1 covers labs 00-12, Day 2 core shared path covers labs 13-24, and Lab 25 is the optional developer branch.
- Show how the workshop moves from fundamentals into governance, extensibility, evaluation, and optional developer workflow.
- Position every lab as a reusable pattern for real customer delivery, not a one-off demo.
**Speaker note:** Use the full arc early so participants see why each lab matters beyond the classroom.

### Slide 3: Mixed-audience roles
- Call out the maker lens: design the conversation, knowledge, prompts, cards, and flows.
- Call out the IT pro lens: secure the environment, channels, data access, and operational controls.
- Call out the developer lens: structure assets, extend behavior, and optionally use the VS Code workflow on Day 2.
**Speaker note:** Frame the workshop as a shared delivery lifecycle where each role notices different risks and opportunities.

### Slide 4: GA delivery guardrails
- Keep the core workshop on generally available capabilities and avoid non-GA dependencies.
- Use GPT-5 Chat as the recommended hands-on model and mention GPT-4.1 only when comparing platform context.
- Treat MCP as GA and use the in-product onboarding wizard as the only workshop setup path.
**Speaker note:** Set these guardrails now so no later module drifts into unsupported or outdated guidance.

### Slide 5: [TRANSITION] Into setup
- Move from workshop framing into environment readiness and UI confidence-building.
- Remind learners that early access issues are cheaper to solve before any build steps begin.
- Ask participants to surface blockers immediately instead of silently falling behind.
**Speaker note:** This transition marks the shift from orientation to hands-on execution. Remind the room that this is the cheapest place to fix account drift, environment mismatch, browser issues, or missing maker access. Makers need build access, IT pros should watch for permissions and policy, and developers can note solution context, but everyone must start from the same baseline before the first build step.

### Slide 6: Lab Time: Lab 00
- Confirm everyone is signed in with the correct workshop account and environment.
- Use the timebox to verify browser readiness, maker access, and the facilitator support path.
- Tell participants that fast blocker reporting protects the rest of the day.
**Speaker note:** Pause here until the room is truly ready to build from the same baseline.

### Slide 7: Lab 00: Environment setup
- Open Copilot Studio, confirm the target environment, and review the landing experience.
- Verify that core menus, agent creation, and settings are visible for the workshop account.
- Capture any licensing or permission issues before moving on.
**Speaker note:** Treat this lab as a go or no-go check for self-paced progress later in the day.

### Slide 8: Module 1: Agents today
- Explain how Copilot Studio combines grounded answers, actions, channels, and operational controls.
- Distinguish lightweight question answering from true task completion and business process support.
- Connect platform value to the mixed audience in the room: adoption, governance, and extensibility.
**Speaker note:** Keep the explanation practical and tied to business outcomes rather than product marketing language.

### Slide 9: Lab Time: Lab 01
- Set the goal: explore the interface with a purpose instead of clicking every menu randomly.
- Ask learners to locate the surfaces they will reuse all workshop long.
- Encourage quick peer help so the room develops a common vocabulary.
**Speaker note:** This lab reduces hesitation later by building shared UI familiarity now.

### Slide 10: Lab 01: Intro to agents
- Open the main navigation, agent list, and starter creation path.
- Identify where overview, knowledge, topics, actions, publish, and test experiences live.
- Practice moving between those surfaces without losing orientation.
**Speaker note:** Keep the lab lightweight so confidence rises before deeper authoring work begins.

### Slide 11: Module 2: Studio foundations
- Map the key authoring surfaces to the agent lifecycle: define, ground, automate, test, publish, improve.
- Introduce the **Activity** page as the diagnostic habit participants should use throughout the workshop.
- Frame maintainability as a design choice that starts with structure, naming, and evidence.
**Speaker note:** Give participants a mental model for how the workspace, diagnostics, and lifecycle fit together.

### Slide 12: Activity page
- Use the **Activity** page to inspect what the agent saw, decided, and returned.
- Show how the view helps diagnose routing, grounding, and tool-selection issues without guesswork.
- Connect this practice to later evaluation, transcript analysis, and release decisions.
**Speaker note:** Normalize evidence-based troubleshooting early so participants do not rely on intuition alone.

### Slide 13: Diagnostics and maintainability
- Use the Microsoft architecture guidance to emphasize maintainable topics, clear ownership, and production diagnostics.
- Keep tool and knowledge names precise so orchestration decisions remain understandable over time.
- Design every workshop artifact as something a teammate could support after handoff.
**Speaker note:** Tie well-architected thinking to everyday build choices instead of treating it as a separate review step.

### Slide 14: Lab Time: Lab 02
- Set the objective: capture the core Copilot Studio fundamentals in the live UI.
- Ask learners to note which surface controls instructions, knowledge, actions, and publishing.
- Keep the room synchronized on one common baseline before branching into later patterns.
**Speaker note:** Use this checkpoint to make sure foundational navigation is clear before more nuanced labs start.

### Slide 15: Lab 02: Studio fundamentals
- Create or open a starter agent and review the core authoring surfaces in context.
- Confirm the overview, knowledge, action, publish, and diagnostic areas are easy to revisit.
- Record where the **Activity** page is accessed.
**Speaker note:** The win condition is confident orientation, not exhaustive feature discovery.

### Slide 16: Solution-aware delivery
- Explain why solutions matter for packaging assets, dependencies, and future lifecycle management.
- Separate workshop experimentation from the more durable structures teams need for reuse.
- Prepare participants to think in change sets and ownership boundaries, not isolated clicks.
**Speaker note:** This framing helps mixed audiences see where delivery discipline starts to matter.

### Slide 17: Lab Time: Lab 03
- Compare the speed of declarative agents with the control of more tailored designs.
- Ask learners to judge which scenarios fit a lighter approach and which do not.
- Keep the discussion anchored to business outcomes and governance needs.
**Speaker note:** This lab works best when participants compare trade-offs, not winners.

### Slide 18: Lab 03: Declarative agents
- Review a declarative agent pattern and note what can be delivered quickly.
- Compare the authoring effort with the limits on custom behavior, diagnostics, and extensibility.
- Capture one scenario where declarative design is enough and one where it is not.
**Speaker note:** Use the exercise to sharpen judgment, not to create unnecessary complexity.

### Slide 19: Lab Time: Lab 04
- Move the conversation from individual assets to solution packaging and lifecycle discipline.
- Tell learners to focus on structure, naming consistency, and what needs to travel together.
- Define success as understanding the delivery container, not just opening another screen.
**Speaker note:** Keep the lab tightly scoped so it supports later operational thinking without slowing momentum.

### Slide 20: Lab 04: Solutions
- Open or create a solution and review how related workshop artifacts are organized together.
- Confirm that the agent and its supporting assets can be reasoned about as a single deliverable.
- Note any environment dependencies that would matter in a real handoff or deployment.
**Speaker note:** This lab introduces the packaging mindset participants will need once the prototype becomes shared work.

<!-- Progress: 20/92 slides complete -->

### Slide 21: Module 3: Reuse patterns
- Use prebuilt and reusable patterns to accelerate delivery without sacrificing clarity.
- Stress that reuse is valuable only when scenario fit, controls, and maintainability stay visible.
- Encourage teams to borrow proven structures rather than reinventing basics under time pressure.
**Speaker note:** Position reuse as disciplined acceleration rather than shortcut-driven customization.

### Slide 22: Lab Time: Lab 05
- Ask learners to inspect a prebuilt pattern quickly and judge what is portable to their scenario.
- Keep the focus on reusable ideas such as instructions, cards, topics, or flows.
- Discourage overcustomizing starter content during the workshop.
**Speaker note:** The fastest way to learn here is to identify what should be reused and what should be rewritten.

### Slide 23: Lab 05: Prebuilt agents
- Review a prebuilt agent or starter pattern and identify its strongest reusable pieces.
- Separate transferable structure from scenario-specific content that would need replacement.
- Capture one idea worth carrying forward and one gap that still requires custom design.
**Speaker note:** Use the lab to build pattern recognition, not dependency on canned content.

### Slide 24: Module 4: Custom agent design
- Shift from samples into owned design decisions around purpose, audience, and boundaries.
- Show that good custom agents feel intentional before they feel feature-rich.
- Keep maintainability visible by writing for future editors as well as current learners.
**Speaker note:** This module marks the move from learning the product to designing with it.

### Slide 25: Grounding strategy comparison <!-- NEW -->
- Compare public websites, SharePoint, uploaded files, and Dataverse as knowledge sources across freshness, structure, ownership, and retrieval quality.
- Explain why "Use information from the Web" must be turned off for enterprise agents: uncontrolled sourcing undermines trust and compliance.
- Position each source type in the grounding ladder so participants can make informed design choices.
**Speaker note:** Use this as the conceptual frame before Lab 06 builds the actual grounding stack.

### Slide 26: Metadata filtering and retrieval quality <!-- NEW -->
- Explain how SharePoint OData metadata filters improve retrieval precision by narrowing the document set before the model reads.
- Show the pattern: column-level filtering targets specific list views or library metadata, reducing noise in the retrieval window.
- Contrast filtered vs. unfiltered retrieval to illustrate why structured metadata matters for enterprise accuracy.
**Speaker note:** This is the concept that separates a demo agent from an enterprise agent — Lab 06 makes it concrete.

### Slide 27: Model selection for custom agents <!-- NEW -->
- Explain GPT-5 Chat vs. GPT-4.1 (labeled "Default" in the picker) and when to override the default.
- Describe how model choice affects grounding quality, latency, and token cost.
- Position model selection as a design decision tied to scenario complexity and retrieval depth.
**Speaker note:** Participants will make this choice in Lab 06 — set the decision framework here.

### Slide 28: Architecture for grounded agents
- Align instructions with the actual tools and knowledge the agent can use so behavior stays trustworthy.
- Prefer smaller maintainable building blocks over giant monolithic topics or prompts.
- Plan diagnostics, support ownership, and production readiness alongside the first build.
**Speaker note:** Use the architecture references to reinforce that grounded, supportable agents are designed deliberately. This is the right place to name the grounding ladder the workshop uses: instructions define scope, public websites add broad trusted guidance, SharePoint adds enterprise content and lists, files add narrow operational references, and Day 2 Dataverse adds structured business records. Each choice changes freshness, permissions, and who owns the source after handoff.

### Slide 29: Lab Time: Lab 06
- Set the deliverable: a clearly named custom agent with a crisp purpose statement.
- Ask learners to keep the first version simple, testable, and easy to explain.
- Use consistent naming so facilitator support stays efficient.
**Speaker note:** The right outcome here is a strong foundation, not maximum scope.

### Slide 30: Lab 06: Custom agent
- Create or refine the workshop custom agent in the target environment.
- Add initial instructions and connect the first knowledge source or placeholder.
- Test whether the agent purpose is immediately understandable in the UI and chat.
**Speaker note:** Coach participants to make the first version understandable before they make it sophisticated. The win condition here is a named, grounded agent that can cite trusted sources, not a feature-complete solution. Ask Makers to focus on clarity, IT pros to watch SharePoint access and DLP behavior, and developers to notice naming, reuse, and support boundaries. If the room stalls, use starter instructions or preselected knowledge sources and protect the rest of Day 1.

### Slide 31: Module 5: Topic design
- Use topic guidance to keep entry points clear, reusable, and low overlap.
- Explain how bite-size topics and redirects improve maintainability over time.
- Warn that ambiguous triggers create support cost long before they create visible bugs.
**Speaker note:** Bring the topic authoring best practices into the room as a maintainability story, not just a design preference.

### Slide 32: Bite-size reusable topics
- Split large conversation logic into smaller reusable topics with clear intent.
- Watch multiple-topic matches as a signal that trigger phrases overlap too much.
- Use redirects and shared endings instead of copying the same logic repeatedly.
**Speaker note:** Show that topic structure is one of the simplest ways to improve both quality and maintenance.

### Slide 33: Lab Time: Lab 07
- Set the task: build one focused topic path before adding optional branches.
- Ask learners to test realistic trigger wording instead of idealized commands.
- Make the done state a clean start, middle, and exit that others can follow.
**Speaker note:** A small reliable topic teaches more than a large unfinished one.

### Slide 34: Lab 07: Topics and triggers
- Create a topic with clear trigger phrases, required variables, and a clean exit.
- Test the trigger against realistic phrasing and watch for overlap or confusion.
- Record one improvement that would make the topic easier to maintain later.
**Speaker note:** Keep the exercise grounded in clarity, because clarity is what scales.

### Slide 35: Adaptive cards that travel
- Use Adaptive Cards to validate input, gather structured data, and enrich the conversation experience.
- Design cards with host compatibility, accessibility, and simple support expectations in mind.
- Keep cards purposeful so they improve the workflow instead of becoming decoration.
**Speaker note:** Anchor card design to supported host behavior so the workshop stays realistic and reusable.

### Slide 36: Lab Time: Lab 08
- Ask learners to add one card only where it genuinely improves data quality or clarity.
- Collect only the inputs needed by the next business step.
- Keep the implementation simple enough to test within the timebox.
**Speaker note:** Use the lab to show how UI can strengthen a conversation without overwhelming it.

### Slide 37: Lab 08: Adaptive cards
- Add or refine an Adaptive Card interaction inside the workshop agent.
- Test the card in the supported host context and verify the values are captured cleanly.
- Confirm the next prompt, topic, or action benefits from the structured input.
**Speaker note:** Treat the card as a precision tool for the workflow, not as a generic form.

### Slide 38: Module 6: Actions and events
- Connect conversation to business process only when the scenario needs a side effect or follow-up action.
- Explain why actions and events should be explicit, auditable, and easy to diagnose.
- Prepare the room to think about orchestration as workflow design rather than freeform prompting.
**Speaker note:** This module is where the agent starts to become part of a business system.

### Slide 39: Generative orchestration rules
- Write instructions that constrain outputs, tool choices, and response format for business use.
- Keep prompts grounded in configured tools and knowledge rather than wishful instructions.
- Prefer repeatable, useful outputs over creative variance when the workflow needs consistency.
**Speaker note:** Use the generative-mode guidance to show that better instructions reduce ambiguity everywhere else.

### Slide 40: Lab Time: Lab 09
- Set the goal: wire one meaningful action with visible inputs and outputs.
- Tell learners to start with the smallest useful scope before adding branches or exceptions.
- Define success as a testable business step, not just a connected flow icon.
**Speaker note:** Slow down slightly here because action wiring is a common confidence dip.

### Slide 41: Lab 09: Agent flows
- Connect the agent to a flow or action that uses captured context.
- Inspect what is passed in, what returns, and what the user sees on success or failure.
- Note any permission or dependency concerns that would matter after the workshop.
**Speaker note:** Use the lab to show why automation design needs both technical and business clarity.

### Slide 42: Lab Time: Lab 10
- Move from user-initiated chat into event-driven automation patterns.
- Ask learners to decide what evidence proves the trigger fired correctly.
- Keep the scenario small enough that the room can reason about the outcome quickly.
**Speaker note:** This lab helps participants think beyond the test pane and into operational workflows.

### Slide 43: Lab 10: Event triggers
- Configure or review an event-triggered path in the workshop scenario.
- Validate the trigger condition, downstream action, and user-facing evidence.
- Capture what would need monitoring or admin review before broader rollout.
**Speaker note:** Tie the trigger path back to observable operations rather than invisible automation magic.

<!-- Progress: 40/92 slides complete -->

### Slide 44: [TRANSITION] From build to publish
- Shift from building the prototype to reviewing release readiness and ownership.
- Bring together naming, access, diagnostics, channels, and governance in one conversation.
- Set the expectation that publish readiness is broader than a single button.
**Speaker note:** Use this transition to refocus the room on operational credibility. Summarize what the room has already proven: grounded answers, structured inputs, flow handoff, and event behavior. Then pivot the language from `can it work?` to `can we own, publish, and support it?` If time slips, shorten channel comparison first and protect the Day 1 licensing and ROI close.

### Slide 45: Lab Time: Lab 11
- Set the task: inspect publish readiness, supported channels, and likely admin dependencies.
- Ask learners to note questions about audience, branding, and support ownership.
- Keep the room aligned on readiness signals instead of forcing identical publish outcomes.
**Speaker note:** This checkpoint works best when participants think like future owners, not just workshop attendees.

### Slide 46: Lab 11: Publish agent
- Review the publish flow and channel options that matter for enterprise rollout.
- Compare readiness considerations for Teams, Microsoft 365 Copilot, website, and later channel expansion.
- Capture any policy, branding, or support blockers that would delay go-live.
**Speaker note:** Reinforce that publishing is a coordination task across makers, admins, and business owners.

### Slide 47: Lab Time: Lab 12
- Close Day 1 by switching from technical readiness into commercial and adoption readiness.
- Ask learners to connect workshop actions to credits, licensing, and value measurement.
- Invite IT pros and sponsors to listen for post-launch planning signals.
**Speaker note:** This lab gives the room the vocabulary to talk about scale, cost, and value responsibly.

### Slide 48: Lab 12: Licensing and ROI
- Map workshop scenarios to Copilot Studio usage, licensing decisions, and operational planning.
- Explain when advanced actions, external channels, or automation consume Copilot Studio capacity.
- Introduce ROI analytics as part of post-launch measurement, not an afterthought.
**Speaker note:** End Day 1 by linking technical progress to commercial credibility and Day 2 readiness. Tie each example back to a capacity story: simple grounded answers, advanced actions, triggers, external channels, and evaluation all affect the commercial conversation differently. Tell the room that Day 2 quality evidence and evaluation results are what make this licensing discussion credible to sponsors and delivery leaders.


## Day 2: Core Labs 13-24 + Optional Lab 25

### Slide 49: [TRANSITION] Day 2 restart
- Reconnect the room to the Day 1 baseline and carry the strongest practices forward.
- Explain that Day 2 adds orchestration, safety, enterprise data, evaluation, and an optional developer workflow after the core path.
- Set the expectation that every module now emphasizes production readiness more explicitly.
**Speaker note:** Use the restart to create momentum without replaying the entire previous day. Day 2 is not a reset: reuse the Day 1 habits of scoped instructions, grounded sources, clean diagnostics, and disciplined naming, then show how orchestration, governed data, MCP, and evaluation extend the same operating model. Participants should feel that the scenario is getting deeper, not unrelated.

### Slide 50: Module 7: Hiring architecture
- Anchor the day around a Hiring Agent solution that feels closer to real operational complexity.
- Show the maintainable architecture: core agent, delegated capabilities, governed data, actions, and diagnostics.
- Align makers, IT pros, and developers around shared delivery responsibilities.
**Speaker note:** Position the Hiring Agent as a structured solution, not a larger prompt.

### Slide 51: Multi-agent operating model
- Use clear boundaries so each agent or capability owns a focused responsibility.
- Explain how handoffs, escalation, and ownership reduce confusion when workflows expand.
- Prefer coordinated components over one oversized agent that is hard to test or support.
**Speaker note:** This framing helps the room understand why structured orchestration improves maintainability. Use the Application Intake and Interview Prep split to explain delegation boundaries, escalation, and ownership. Call out that the Activity map becomes the operating view for debugging handoffs, and that the same boundary-setting later makes flows, MCP tools, and evaluation results easier to reason about.

### Slide 52: Lab Time: Lab 13
- Set up the Hiring Agent baseline with the correct environment, naming, and scenario context.
- Ask learners to confirm data and knowledge prerequisites before changing behavior.
- Define success as a reliable starting point for the rest of Day 2.
**Speaker note:** A stable baseline now prevents compounded confusion in later connected labs.

### Slide 53: Lab 13: Hiring setup
- Create or open the Hiring Agent and confirm the main authoring surfaces are ready.
- Review the scenario goals, dependencies, and any pre-staged assets the class will reuse.
- Capture what must stay consistent across later labs for testing to remain meaningful.
**Speaker note:** Use the setup lab to align expectations before the day becomes more complex.

### Slide 54: Lab Time: Lab 14
- Strengthen the instructions before adding more tools, data, or automation.
- Ask learners to write for maintainability, scope clarity, and recruiter-safe outputs.
- Keep the first improvement easy to test in the chat experience.
**Speaker note:** Instructions are the control plane for later behavior, so invest here before extending further.

### Slide 55: Lab 14: Agent instructions
- Refine the Hiring Agent instructions with clear scope, tone, escalation, and formatting guidance.
- Align the instructions to configured tools and knowledge instead of asking the model to invent capability.
- Test one direct request and one ambiguous request to see whether the guidance holds.
**Speaker note:** This lab is most valuable when participants connect instruction quality to predictable outcomes.

### Slide 56: Lab Time: Lab 15
- Move into multi-agent collaboration with a clear purpose for each delegated capability.
- Ask teams to keep each role narrow enough that ownership stays understandable.
- Define success as a handoff model that is easy to explain and support.
**Speaker note:** Keep the collaboration pattern simple so the operating model stays visible.

### Slide 57: Lab 15: Multi-agent team
- Configure or review a multi-agent hiring pattern with clear delegation boundaries.
- Confirm each specialized capability has a purpose, entry point, and expected outcome.
- Validate that the coordination logic stays understandable in the UI and test flow.
**Speaker note:** The main lesson is disciplined orchestration, not maximum branching.

### Slide 58: Module 8: Automation and models
- Add automation and model choices without losing operational control.
- Compare models by task fit, response shape, cost, and consistency rather than trend.
- Keep the workshop baseline on GA capabilities so the room can reproduce outcomes later.
**Speaker note:** Frame model choice as an implementation decision that should stay tied to task quality. Connect Labs 16 and 17 explicitly: automation determines when the agent acts, while model selection influences how reliably it reasons once it acts. Ask the room to compare speed, structure, safety, and cost in business language rather than model hype.

### Slide 59: Lab Time: Lab 16
- Automate one useful hiring workflow step with a clear trigger and outcome.
- Tell learners to keep the scenario observable and explainable to nontechnical stakeholders.
- Capture what success evidence should appear if the automation works.
**Speaker note:** Use the timebox to keep automation grounded in one measurable business step.

### Slide 60: Lab 16: Trigger automation
- Configure trigger-based behavior tied to a concrete hiring event or process step.
- Confirm the event path, connection state, and resulting action are visible in the UI.
- Record any dependency that would matter for tenant readiness after the workshop.
**Speaker note:** This lab teaches participants to treat automation as an operational commitment, not just a feature.

### Slide 61: Lab Time: Lab 17
- Compare models using the same hiring task so the differences stay meaningful.
- Use GPT-5 Chat as the recommended hands-on baseline for the workshop.
- Mention GPT-4.1 only as platform context when participants need a comparison point.
**Speaker note:** Keep the comparison lightweight so the room focuses on fit, not benchmarking theater.

### Slide 62: Lab 17: Model selection
- Run the comparison in the UI and judge structure, speed, and usefulness for hiring tasks.
- Select the model that best balances reliable output with the workshop scenario needs.
- Save the chosen baseline so later labs evaluate against the same model.
**Speaker note:** Model selection matters most when the room can explain why a choice was made. Keep the scorecard simple but explicit. If GPT-5 Chat is available, use it as the baseline, then explain any fallback in terms of recruiter trust, latency, and cost. Do not switch models casually after this point because Lab 24 evaluation needs a stable baseline.

### Slide 63: Safety by layered controls
- Combine AI disclosure, instructions, moderation, error handling, and testing into one safety model.
- Use per-prompt content moderation (Low/Moderate/High slider) where a specific prompt or tool needs tighter moderation than the rest of the agent.
- Treat safety as something to validate with evidence, not something to assume after configuration.
**Speaker note:** This slide sets up content moderation as a layered operational control rather than a toggle. Place it immediately after model selection on purpose: models can change refusal style and consistency, but they never replace explicit guardrails. Connect the layers here to the red-team prompts in Lab 18 and the failing-case review in Lab 24.

<!-- Progress: 60/92 slides complete -->

### Slide 64: Lab Time: Lab 18
- Harden the Hiring Agent with realistic safe-use guardrails.
- Ask learners to note which protection layer responds to each risky prompt.
- Keep one clean in-scope prompt as a control so safe behavior remains useful behavior.
**Speaker note:** Red-team style testing works best when the room compares outcomes across the same prompt set.

### Slide 65: Lab 18: Content moderation
- Set the moderation posture and review how refusal or redirect messaging appears to users.
- Inspect prompt-level or tool-level sensitivity only where targeted tightening is justified.
- Verify the agent refuses unsafe, irrelevant, or policy-breaking requests while staying helpful in scope.
**Speaker note:** Emphasize that precise controls beat blanket loosening or blanket blocking. Make the room identify which layer fired in each example: agent moderation, prompt sensitivity, instructions, or error handling. Safe behavior still has to be useful, so compare one blocked prompt with one clean in-scope prompt. This is where Makers, IT pros, and developers see the same control stack from different angles.

### Slide 66: Module 9: Multimodal and data
- Add richer inputs only when they improve the hiring workflow and decision quality.
- Connect the conversation to governed business data without losing traceability.
- Keep every output reviewable, role-appropriate, and easy to justify.
**Speaker note:** This module keeps capability growth tied to business value and control.

### Slide 67: Multimodal prompt framing
- Decide what a document or image should contribute to the hiring workflow before prompting on it.
- Constrain extraction and summarization to job-related outcomes the room can validate.
- Use clarifying follow-up when the input is incomplete or ambiguous.
**Speaker note:** Well-framed multimodal prompts stay useful because they are scoped to a real decision.

### Slide 68: Lab Time: Lab 19
- Test one multimodal path with a controlled document or image input.
- Ask learners to verify both usefulness and the need for human review.
- Keep the exercise grounded in the Hiring Agent scenario rather than novelty.
**Speaker note:** Use the lab to show where multimodal input helps and where human judgment still matters.

### Slide 69: Lab 19: Multimodal prompts
- Run a multimodal prompt workflow in the UI and inspect the returned summary or extraction.
- Confirm the output remains recruiter-friendly, job-related, and easy to review.
- Note one improvement that would make the workflow safer or more maintainable.
**Speaker note:** The value here comes from controlled usefulness, not from using every possible input type.

### Slide 70: Dataverse grounding patterns
- Use Dataverse when the scenario needs governed operational data, structured records, and role-based access.
- Align table visibility, permissions, and traceability before trusting the experience in front of users.
- Connect data-grounded behavior to later diagnostics, transcript analysis, and improvement cycles.
**Speaker note:** Tie Dataverse readiness to both business value and operational accountability. Contrast Dataverse with Day 1 grounding choices: public sites give breadth, SharePoint gives enterprise content and lists, files give narrow references, and Dataverse gives structured operational records with stronger filtering and permissions. Stress that schema quality and access control now matter as much as prompt wording.

### Slide 71: Lab Time: Lab 20
- Connect the Hiring Agent to Dataverse safely and verify only the needed data is in scope.
- Ask learners to validate permissions early so the room does not mistake access issues for design issues.
- Define success as visible, relevant, governed data access in the UI.
**Speaker note:** Treat this as a readiness checkpoint because data access variability is common across tenants.

### Slide 72: Lab 20: Dataverse grounding
- Open or configure the Dataverse grounding path and confirm the target data is visible.
- Test a hiring question that benefits from governed business data instead of general knowledge only.
- Capture any mismatch between scenario needs, data quality, and available permissions.
**Speaker note:** Keep the lab focused on governed usefulness rather than deep schema exploration. Treat missing tables, empty results, or permission errors as data-readiness problems first, not model problems. This helps facilitators troubleshoot faster and teaches participants to separate AI behavior from data access.

### Slide 73: Document outputs with guardrails
- Generated documents need clear inputs, approved templates, and obvious review points.
- Focus on repeatable hiring artifacts such as interview packs, summaries, or recruiter briefs.
- Make output quality measurable before anyone treats the result as production-ready.
**Speaker note:** This framing helps document generation feel operational rather than magical.

### Slide 74: Lab Time: Lab 21
- Generate one document-oriented output only after the required context is present.
- Ask learners to review the result for structure, policy fit, and next-step usefulness.
- Use the timebox to document one improvement instead of endlessly polishing wording.
**Speaker note:** A good first output teaches more than a perfect tenth revision.

### Slide 75: Lab 21: Document generation
- Create or review the document-generation step tied to the Hiring Agent scenario.
- Validate the produced artifact against the expected structure, tone, and job-related scope.
- Record one guardrail or template improvement before considering wider use.
**Speaker note:** Keep the result tied to a business artifact someone could actually review or use.

### Slide 76: [TRANSITION] Into MCP
- Move from internal orchestration into governed extensibility with external tools.
- Keep access narrow, auditable, and easy to explain to admins and sponsors.
- Use only the supported GA setup path so the workshop remains reproducible.
**Speaker note:** This transition sets the expectation that extensibility must stay governed to stay credible. Frame MCP as governed extensibility rather than open-ended plugin growth. If the wizard or catalog is unavailable, switch to demo mode quickly, protect the concept, and keep the message on narrow, auditable tool scope.

### Slide 77: Module 10: MCP and extensibility
- Treat MCP as a generally available capability in this workshop.
- Use the in-product onboarding wizard to add or review MCP servers inside Copilot Studio.
- Keep tool scope narrow, auditable, and explainable to admins; avoid non-GA detours.
- Avoid fallback branching, manual secret editing, or any non-wizard setup path.
**Speaker note:** State the supported path clearly so the room does not anchor on outdated guidance and extensibility stays governed.

### Slide 78: MCP architecture: protocol, not connector <!-- NEW -->
- Explain how MCP differs from classic connectors: one server exposes multiple tools vs. one action per capability.
- Describe the Agent 365 tooling server dependency and how the MCP catalog works as a governed marketplace.
- Show that MCP enables richer, composable tool integration while maintaining admin-controlled boundaries.
**Speaker note:** Participants need this mental model before Lab 22 — without it, MCP looks like "just another connector."

### Slide 79: MCP consent and governance <!-- NEW -->
- Walk through the consent flow: server selection → connection → per-tool consent card → Allow/Deny.
- Explain what governance controls the admin has over MCP server availability and tool approval.
- Position the consent model as the mechanism that keeps extensibility auditable and reversible.
**Speaker note:** The consent flow is new to most participants. Demo it live if possible before they hit it in Lab 22.

### Slide 80: Lab Time: Lab 22
- Add MCP through the supported UI path and keep the scope limited to one useful hiring task.
- Ask learners to validate why the server belongs in the scenario before they enable it.
- Define success as a governed tool connection that is visible and explainable.
**Speaker note:** Use this lab to connect extensibility to security and supportability, not just capability.

### Slide 81: Lab 22: MCP integration
- Open the MCP onboarding wizard and add or review a supported server in the agent.
- Confirm the tool appears with the right connection state and purpose in the UI.
- Test one safe, auditable MCP-assisted task that fits the Hiring Agent scenario.
**Speaker note:** Keep the example small so the room learns the pattern without overextending scope.

### Slide 82: Module 11: Channels and feedback
- Close the operational loop by pairing publishing readiness with user feedback and support expectations.
- Match channel choices to audience, policy, and ownership rather than novelty.
- Turn feedback into evidence that can influence backlog, evaluation, and release decisions.
**Speaker note:** This module connects user reach with the quality loop that keeps the agent improving.

### Slide 83: Publish and deploy workflow <!-- NEW -->
- Walk through the publish → Channels tab → Microsoft channels → Add channel → Teams installation → availability options sequence.
- Explain Copy link, Show to teammates, and Show to my organization as distinct availability levels.
- Highlight where participants commonly lose orientation and how to recover at each step.
**Speaker note:** This sequence has 5+ clicks and participants lose orientation at the availability step — walk through it visually before Lab 11.

### Slide 84: WhatsApp and external channels <!-- NEW -->
- Position WhatsApp and other external channels in the broader channel strategy alongside Teams and web.
- Explain where they appear in the UI ("Other channels" section) and what the preview/GA readiness looks like.
- Connect external channel availability to compliance, branding, and support ownership decisions.
**Speaker note:** Lab 11 asks participants to identify WhatsApp in the channel inventory — give them context on why it matters for multi-channel rollout.

### Slide 85: Channel overview: Teams and more
- Compare Teams, Microsoft 365 Copilot, WhatsApp, and web experiences from a readiness and governance perspective.
- Call out how branding, support, compliance, and channel policy affect rollout decisions.
- Explain why channel choice changes monitoring, adoption, and change-control expectations.
**Speaker note:** Use the channel overview to broaden the conversation from publishing mechanics to operating reality.

### Slide 86: Lab Time: Lab 23
- Capture user feedback intentionally instead of treating comments as informal noise.
- Ask learners to decide who reviews feedback, how often, and what action follows.
- Keep the feedback path tied to quality improvement and adoption learning.
**Speaker note:** This lab turns user reaction into something the team can operationalize.

### Slide 87: Lab 23: User feedback
- Enable or review the feedback capture path and verify where feedback lands.
- Test how a user can submit feedback after a conversation or outcome.
- Connect feedback signals to future tuning, release decisions, and support processes.
**Speaker note:** Show that feedback is most useful when it has an owner and a follow-up path.

<!-- Progress: 87/92 slides complete -->

### Slide 88: Module 12: Evaluation and ROI
- Use evaluation as a repeatable release gate instead of relying on ad hoc chat testing.
- Pair evaluation evidence with transcript analytics and ROI analytics to tell a fuller value story.
- Connect quality results to rollout, staffing, and investment decisions after the workshop.
**Speaker note:** This final module brings quality, insight, and business value into one decision framework. Bring Lab 12 back into the conversation here: ROI analytics tells the value story, while evaluation tells the quality and release-readiness story. Together they answer whether the agent is worth scaling and safe enough to scale.

### Slide 89: Lab Time: Lab 24
- Run a repeatable quality review with scored evidence instead of intuition alone.
- Ask learners to compare pass rate, failure reasons, and next-step fixes.
- Use the activity map and transcript evidence to prepare one improvement loop.
**Speaker note:** This lab matters most when participants leave with a reusable QA habit, not just one run.

### Slide 90: Lab 24: Evaluation and QA
- Create or run an evaluation test set in the UI using realistic hiring prompts.
- Inspect pass rate, grader reasoning, and activity-map evidence for at least one failing case.
- Use the findings to refine the agent before calling it release-ready.
**Speaker note:** Connect the workflow back to the transcript-analysis architecture so quality improvement feels operational and repeatable. Show what makes a failing case useful: clear expected behavior, grader reasoning, and an activity map that points to the real fix. Leave the room with the idea that evaluation is a reusable release gate, not a one-time workshop artifact.

### Slide 91: Lab Time: Lab 25
- Start the optional developer branch while the main room stays on wrap-up, QA review, and rollout planning.
- Direct developers to the VS Code workflow only if they are caught up on the core path.
- Keep nondevelopers focused on evaluation findings, ROI framing, and next actions.
**Speaker note:** This structure keeps the core workshop complete while still giving developers a relevant extension path.

### Slide 92: Lab 25: VS Code workflow
- Optionally clone and sync the agent with the VS Code extension using the supported GA workflow.
- Validate that local edits flow back into Copilot Studio without changing the workshop baseline or bypassing in-product controls.
- Use this branch only for developers while the main room closes on evaluation, ROI, and rollout actions.
**Speaker note:** End by making the developer add-on feel optional, useful, and safely separated from the core path. Reassure nondevelopers that the core delivery story is already complete. For developers, stress that local editing complements, not replaces, the governed in-product flow and later release controls.
