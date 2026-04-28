# Slide Deck Outline

Use this master outline with `slide-deck-delivery-notes.md`, `slide-deck-visual-plan.md`, `lab-timing-guide.md`, and `screenshot-capture-checklist.md` when building or presenting the workshop deck.

> **Companion document:** This markdown outline provides the narrative structure, speaker notes, and teaching intent for the workshop presentation decks.
>
> **Delivery artifacts:** The live presentation files live in `workshop\Copilot-Studio-Workshop-Slides\` as 13 PPTX module decks with 98 slides total.
>
> **Relationship:** The PPTX decks are the delivery-ready presentation artifacts with visual design and presentation flow. This outline is the text-first companion used for speaker notes, narrative structure, and teaching strategy review.
>
> **Alignment note:** This outline contains 102 numbered entries (97 baseline Day 1/Day 2 entries plus 5 new Module 13b entries) while the PPTX corpus contains 98 slides. The counts do not match one-for-one because the decks may split title, transition, or visual teaching moments across multiple slides while the outline combines them into fewer narrative entries, and Module 13b is a Markdown-only concept module with no PPTX deck yet.
>
> **Day 2 timing alignment (v2):** To keep the 2-day cap, Day 2 absorbs the new Module 13b (~30 min) and the optional Lab 14 Component Collections extension (~10 min) by compressing Lab 23 to a ~20 min core (Parts 1–4 only) and treating Lab 25 as fully optional. Slides for Lab 23 should mirror the compressed scope; Slide content for Lab 25 should frame it as a skip-if-time-constrained developer stretch.
>
> **Per-module slide counts (PPTX):**
>
> | Module | Deck | PPTX Slides | Outline Entries |
> |--------|------|-------------|-----------------|
> | 00 | Workshop Framing | 8 | 7 |
> | 01 | Agents Today | 6 | 3 |
> | 02 | Studio Foundations | 11 | 10 |
> | 03 | Reuse Patterns | 5 | 4 (+1 new) |
> | 04 | Custom Agent Design | 5 | 7 (+3 new) |
> | 05 | Topic Design | 8 | 7 |
> | 06 | Actions and Events | 11 | 11 |
> | 07 | Lending Architecture | 10 | 10 |
> | 08 | Automation and Models | 8 | 8 |
> | 09 | Multimodal and Data | 11 | 11 |
> | 10 | MCP and Extensibility | 4 | 6 (+2 new) |
> | 11 | Channels and Feedback | 4 | 6 (+2 new) |
> | 12 | Evaluation and ROI | 7 | 7 (+1 new) |
> | 13b | ALM and Governance (concept module, Markdown only) | 0 | 5 (+5 new) |
> | | **Total** | **98** | **102** (85 + 17 new) |
>
> **Module 13b note:** Module 13b is a concept module delivered from a Markdown source (`workshop\Copilot-Studio-Workshop-Slides\Module-13b-ALM-and-Governance.md`). It has no PPTX deck yet — future work to convert. It opens Day 2 between Lab 13 and Lab 14 and is concept + facilitator demo only (no hands-on student exercise).

## Day 1: Labs 00-12

### Slide 1: Welcome and goals
- Welcome makers, IT pros, and developers into one shared Copilot Studio learning path.
- Set the expectation that Day 1 builds foundations and Day 2 turns them into an operational Loan Processing Agent solution.
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

<!-- Progress: 20/95 slides complete -->

### Slide 21: Module 3: Reuse patterns
- Use prebuilt and reusable patterns to accelerate delivery without sacrificing clarity.
- Stress that reuse is valuable only when scenario fit, controls, and maintainability stay visible.
- Encourage teams to borrow proven structures rather than reinventing basics under time pressure.
**Speaker note:** Position reuse as disciplined acceleration rather than shortcut-driven customization.

### Slide 21a: M365 Agent Builder vs Copilot Studio <!-- NEW -->
- Position M365 Agent Builder (inside Microsoft 365 Copilot) as the lightweight, natural-language authoring surface many business users will reach for first.
- Walk the contrast table covering audience reach, authoring depth, governance, knowledge sources, and best-fit scenarios so participants can recommend the right tool per use case.
- Anchor the Woodgrove framing: the Customer Service Agent lives in Copilot Studio because the bank needs governed ALM, Dataverse, multi-channel reach, and orchestration — Agent Builder is complementary, not competitive.
**Speaker note:** This slide supports the optional Lab 03 Agent Builder walkthrough, which is gated on participants having a Microsoft 365 Copilot license. If license coverage in the room is thin (per the prereq check), keep the hands-on lab on Copilot Studio and use this slide as a 3-minute teaching moment with a licensed tenant demo. The teaching goal is the contrast, not the click-through.

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

### Slide 30a: Looking ahead — Component Collections (Day 1 sidebar) <!-- NEW -->
- One agent grounded on SharePoint is enough for Lab 06; multiple agents needing the **same** curated knowledge is a different problem.
- Component Collections bundle topics, knowledge, and actions into a reusable package owned by a primary agent and referenced by others.
- Day 2 (Lab 14) will reference the **Woodgrove Product & Fee Disclosures** collection from the **Loan Processing Agent** so it stays aligned with the **Customer Service Agent**.
- FSI guardrail: disclosures are Compliance-owned in production; **KYC is intentionally excluded** and stays a system-of-record connector lookup.
**Speaker note:** Keep this to ~5 minutes — concept only, no clicks. The point is to plant the cross-day callback so Lab 14's optional extension lands as a payoff, not a surprise. Reference the `ComponentCollections.ProductDisclosuresCollectionName` and `ComponentCollections.DisclosureSourceUrls` keys in `workshop-config.example.json` so facilitators know where the collection is configured.

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

### Slide 39a: Multistage human approvals for high-stakes workflows <!-- NEW -->
- Frame the AI agent as a **summarizer and router**, never the approver, for credit decisions, KYC reviews, large-payment release, and exception handling.
- Walk through the canonical FSI loan-approval pattern: AI extracts fields → AI summarizes for the reviewer → Tier-1 underwriter approves → conditional escalation above a policy threshold (for example $250K) to a Tier-2 senior underwriter → decision written back to system of record → user notified.
- Anchor the pattern in supervisory guidance: **SR 11-7 Model Risk Management**, **OCC AI/ML model risk principles**, **ECOA Reg B §1002.9** adverse-action notices, and the **four-eyes** principle for material credit decisions; mention **EU AI Act Article 14** human oversight for non-US audiences.
- Emphasize the technical boundary: the Power Automate Approvals action must always be assigned to a real human mailbox — never to the agent identity or an AI Builder step.
**Speaker note:** This is the slide where banking-specific governance lands on top of generic Power Automate. Read the one-liner aloud: "AI proposes, humans approve — and on loans above the policy threshold, two humans approve." Lab 09 Part 2 builds exactly this flow.

### Slide 40: Lab Time: Lab 09
- Set the goal: wire one meaningful action with visible inputs and outputs.
- Tell learners to start with the smallest useful scope before adding branches or exceptions.
- Define success as a testable business step, not just a connected flow icon.
**Speaker note:** Slow down slightly here because action wiring is a common confidence dip.

### Slide 41: Lab 09: Agent flows
- Connect the agent to a flow or action that uses captured context.
- Inspect what is passed in, what returns, and what the user sees on success or failure.
- Note any permission or dependency concerns that would matter after the workshop.
- Call out the optional **Part 2 — Multistage AI-assisted Loan Approval** as the FSI-native extension for facilitators who have time; the core lab still satisfies the workshop requirement.
**Speaker note:** Use the lab to show why automation design needs both technical and business clarity. If you run Part 2, the teaching point is the four-eyes governance boundary, not the wiring.

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

<!-- Progress: 40/95 slides complete -->

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
- Show how knowledge prioritization, suggested prompts, and the Microsoft 365 Copilot channel turn a published agent into a discoverable, on-brand experience.
- Compare readiness considerations for Teams, Microsoft 365 Copilot, website, and later channel expansion.
- Capture any policy, branding, or support blockers that would delay go-live.
**Speaker note:** Reinforce that publishing is a coordination task across makers, admins, and business owners. Call out that the Microsoft 365 Copilot channel requires end users to hold a Microsoft 365 Copilot license, while a Copilot Studio maker license alone is enough to ship the channel.

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

<!-- NEW -->
### Slide 50: Day 1 carryover checklist
- Display a self-service reference of the Day 1 practices participants should carry into every Day 2 lab: agent instructions aligned to configured tools and knowledge, web search turned off, Activity page used for diagnostics, SharePoint sources with metadata filters applied, model selected explicitly (GPT-5 Chat baseline), and solution packaging in place.
- Ask the room to confirm each item before continuing. Participants who missed parts of Day 1 or are joining fresh can use this slide as a troubleshooting starting point.
- Frame the checklist as operational hygiene that makes Day 2 orchestration, governed data, and evaluation trustworthy rather than a compliance gate.
**Speaker note:** Pause on this slide long enough for participants to self-check. Anyone who cannot confirm an item should raise it now rather than discovering the gap during Lab 14 or Lab 20. For facilitators: if several participants are missing a baseline item (for example, web search is still on or solution packaging was skipped), fix it as a group before proceeding. This two-minute checkpoint prevents the most common Day 2 compounding errors and gives late joiners a concrete catch-up reference.

### Slide 51: Module 7: Lending architecture
- Anchor the day around a Loan Processing Agent solution that feels closer to real operational complexity.
- Show the maintainable architecture: core agent, delegated capabilities, governed data, actions, and diagnostics.
- Align makers, IT pros, and developers around shared delivery responsibilities.
**Speaker note:** Position the Loan Processing Agent as a structured solution, not a larger prompt.

### Slide 52: Multi-agent operating model
- Use clear boundaries so each agent or capability owns a focused responsibility.
- Explain how handoffs, escalation, and ownership reduce confusion when workflows expand.
- Prefer coordinated components over one oversized agent that is hard to test or support.
**Speaker note:** This framing helps the room understand why structured orchestration improves maintainability. Use the Document Review and Loan Advisory split to explain delegation boundaries, escalation, and ownership. Call out that the Activity map becomes the operating view for debugging handoffs, and that the same boundary-setting later makes flows, MCP tools, and evaluation results easier to reason about. Note that **Connected Agents are GA as of November 30, 2025**, so the orchestrator, picker, and "Let other agents connect to and use this one" toggle shown in Lab 15 are production features — strip any "preview" caveats from older decks.

### Slide 52a: Child vs connected agent — when to use which
- Child agent: lives inside the parent, single parent, inherits parent context, versioned with the parent — best for a tightly-coupled sub-task.
- Connected agent: independently published, many parents can call it, owns its own knowledge and tools, versioned independently — best for a reusable specialist (for example, a shared **Compliance Q&A** agent reused by lending, deposits, and cards).
- In Lab 15: Document Review Agent is built as a **child**; Loan Advisory Agent is built as a **connected** agent so future Woodgrove agents can reuse it without duplicating instructions or knowledge.
**Speaker note:** Show the matrix from the Lab 15 README on this slide (lifecycle, reuse, knowledge/tools, versioning, best-for). Anchor the teaching in the FSI scenario: connected agents are how a bank avoids re-implementing compliance, KYC orchestration, or product disclosure logic in every line-of-business agent. Both patterns are GA — selection is an architecture choice, not a feature gate.

### Slide 53: Lab Time: Lab 13
- Set up the Loan Processing Agent baseline with the correct environment, naming, and scenario context.
- Ask learners to confirm data and knowledge prerequisites before changing behavior.
- Define success as a reliable starting point for the rest of Day 2.
**Speaker note:** A stable baseline now prevents compounded confusion in later connected labs.

### Slide 54: Lab 13: Lending setup
- Create or open the Loan Processing Agent and confirm the main authoring surfaces are ready.
- Review the scenario goals, dependencies, and any pre-staged assets the class will reuse.
- Capture what must stay consistent across later labs for testing to remain meaningful.
**Speaker note:** Use the setup lab to align expectations before the day becomes more complex.

### Slide 55: Lab Time: Lab 14
- Strengthen the instructions before adding more tools, data, or automation.
- Ask learners to write for maintainability, scope clarity, and loan-officer-safe outputs.
- Keep the first improvement easy to test in the chat experience.
**Speaker note:** Instructions are the control plane for later behavior, so invest here before extending further.

### Slide 56: Lab 14: Agent instructions
- Refine the Loan Processing Agent instructions with clear scope, tone, escalation, and formatting guidance.
- Align the instructions to configured tools and knowledge instead of asking the model to invent capability.
- Test one direct request and one ambiguous request to see whether the guidance holds.
**Speaker note:** This lab is most valuable when participants connect instruction quality to predictable outcomes.

### Slide 56a: Lab 14 optional extension — Reference the Product & Fee Disclosures Component Collection <!-- NEW -->
- Cross-day payoff: the collection previewed on Day 1 (slide 30a) is now consumed by the **Loan Processing Agent**.
- Hands-on micro-step (~10 min): open the agent's Components view, add the pre-seeded **Woodgrove Product & Fee Disclosures** collection by reference, save, and test with two disclosure-anchored questions.
- Governance win: one curated source for both the **Customer Service Agent** and the **Loan Processing Agent** — no drift between channels.
- FSI guardrail: Compliance owns the disclosure lifecycle; KYC stays out of this collection (system-of-record only).
**Speaker note:** Skip this slide and the extension if the room is behind schedule — it is explicitly optional and gated on the facilitator having pre-created the collection in the demo environment. When you do run it, frame the "why" before the "how": the collection is the antidote to disclosure drift across customer-facing agents, which is a real audit finding in regulated lending. Emphasize that the participant is *referencing* an already-approved collection, not editing disclosure text.

### Slide 57: Lab Time: Lab 15
- Move into multi-agent collaboration with a clear purpose for each delegated capability.
- Ask teams to keep each role narrow enough that ownership stays understandable.
- Define success as a handoff model that is easy to explain and support.
**Speaker note:** Keep the collaboration pattern simple so the operating model stays visible.

### Slide 58: Lab 15: Multi-agent team
- Configure or review a multi-agent lending pattern with clear delegation boundaries.
- Build **Document Review Agent** as a child agent and **Loan Advisory Agent** as a connected agent (Connected Agents GA Nov 30 2025).
- Confirm each specialized capability has a purpose, entry point, and expected outcome.
- Validate that the coordination logic stays understandable in the UI and test flow.
**Speaker note:** The main lesson is disciplined orchestration, not maximum branching. Reinforce the child-vs-connected choice from slide 52a: Document Review is child because it is tightly coupled to loan processing; Loan Advisory is connected because future Woodgrove agents (mortgage, small-business lending) should reuse it. Both patterns are GA — no preview opt-in, no special licensing.

### Slide 59: Module 8: Automation and models
- Add automation and model choices without losing operational control.
- Compare models by task fit, response shape, cost, and consistency rather than trend.
- Keep the workshop baseline on GA capabilities so the room can reproduce outcomes later.
**Speaker note:** Frame model choice as an implementation decision that should stay tied to task quality. Connect Labs 16 and 17 explicitly: automation determines when the agent acts, while model selection influences how reliably it reasons once it acts. Ask the room to compare speed, structure, safety, and cost in business language rather than model hype.

### Slide 60: Lab Time: Lab 16
- Automate one useful lending workflow step with a clear trigger and outcome.
- Tell learners to keep the scenario observable and explainable to nontechnical stakeholders.
- Capture what success evidence should appear if the automation works.
**Speaker note:** Use the timebox to keep automation grounded in one measurable business step.

### Slide 61: Lab 16: Trigger automation
- Configure trigger-based behavior tied to a concrete lending event or process step.
- Confirm the event path, connection state, and resulting action are visible in the UI.
- Record any dependency that would matter for tenant readiness after the workshop.
**Speaker note:** This lab teaches participants to treat automation as an operational commitment, not just a feature.

### Slide 62: Lab Time: Lab 17
- Compare models using the same lending task so the differences stay meaningful.
- Use GPT-5 Chat (GA since August 7, 2025) as the recommended hands-on baseline for the workshop.
- Mention GPT-4.1 (labeled "Default" in the picker) as the GA fallback when GPT-5 Chat is not visible in the participant's tenant.
- Flag Claude Sonnet (GA March 2026, rolling and opt-in) as an optional comparison only — not available in GCC, EU, UK, or EFTA tenants at GA.
**Speaker note:** Keep the comparison lightweight so the room focuses on fit, not benchmarking theater. Deep Reasoning (powered by OpenAI o1, GA March 2025) and GPT-5 mini are valid optional data points, but the workshop baseline stays on GPT-5 Chat or its GA fallback GPT-4.1.

### Slide 63: Lab 17: Model selection
- Run the comparison in the UI and judge structure, speed, and usefulness for lending tasks.
- Select the model that best balances reliable output with the workshop scenario needs.
- Save the chosen baseline so later labs evaluate against the same model.
**Speaker note:** Model selection matters most when the room can explain why a choice was made. Keep the scorecard simple but explicit. If GPT-5 Chat is available, use it as the baseline; if not, fall back to GPT-4.1 and explain the choice in terms of loan officer trust, latency, and cost. Claude Sonnet is an optional comparison where the tenant and region allow it (not GCC/EU/UK/EFTA at GA, and the external-model toggle must be on). Do not switch models casually after this point because Lab 24 evaluation needs a stable baseline.

### Slide 64: Safety by layered controls
- Combine AI disclosure, instructions, moderation, error handling, and testing into one safety model.
- Use per-prompt content moderation (Low/Moderate/High slider) where a specific prompt or tool needs tighter moderation than the rest of the agent.
- Treat safety as something to validate with evidence, not something to assume after configuration.
**Speaker note:** This slide sets up content moderation as a layered operational control rather than a toggle. Place it immediately after model selection on purpose: models can change refusal style and consistency, but they never replace explicit guardrails. Connect the layers here to the red-team prompts in Lab 18 and the failing-case review in Lab 24.

<!-- Progress: 62/95 slides complete -->

### Slide 65: Lab Time: Lab 18
- Harden the Loan Processing Agent with realistic safe-use guardrails.
- Ask learners to note which protection layer responds to each risky prompt.
- Keep one clean in-scope prompt as a control so safe behavior remains useful behavior.
**Speaker note:** Red-team style testing works best when the room compares outcomes across the same prompt set.

### Slide 66: Lab 18: Content moderation
- Set the moderation posture and review how refusal or redirect messaging appears to users.
- Inspect prompt-level or tool-level sensitivity only where targeted tightening is justified.
- Verify the agent refuses unsafe, irrelevant, or policy-breaking requests while staying helpful in scope.
**Speaker note:** Emphasize that precise controls beat blanket loosening or blanket blocking. Make the room identify which layer fired in each example: agent moderation, prompt sensitivity, instructions, or error handling. Safe behavior still has to be useful, so compare one blocked prompt with one clean in-scope prompt. This is where Makers, IT pros, and developers see the same control stack from different angles.

### Slide 67: Module 9: Multimodal and data
- Add richer inputs only when they improve the lending workflow and decision quality.
- Connect the conversation to governed business data without losing traceability.
- Keep every output reviewable, role-appropriate, and easy to justify.
**Speaker note:** This module keeps capability growth tied to business value and control.

### Slide 68: Multimodal prompt framing
- Decide what a document or image should contribute to the lending workflow before prompting on it.
- Constrain extraction and summarization to lending-related outcomes the room can validate.
- Use clarifying follow-up when the input is incomplete or ambiguous.
**Speaker note:** Well-framed multimodal prompts stay useful because they are scoped to a real decision.

### Slide 69: Lab Time: Lab 19
- Test one multimodal path with a controlled document or image input.
- Ask learners to verify both usefulness and the need for human review.
- Keep the exercise grounded in the Loan Processing Agent scenario rather than novelty.
**Speaker note:** Use the lab to show where multimodal input helps and where human judgment still matters.

### Slide 70: Lab 19: Multimodal prompts
- Run a multimodal prompt workflow in the UI and inspect the returned summary or extraction.
- Confirm the output remains loan-officer-friendly, lending-related, and easy to review.
- Note one improvement that would make the workflow safer or more maintainable.
**Speaker note:** The value here comes from controlled usefulness, not from using every possible input type.

<!-- NEW -->
### Slide 71: Dataverse readiness checkpoint
- Before grounding the agent in Dataverse, verify that the Woodgrove Lending Hub tables are visible and populated: Loan Type, Assessment Criteria, Applicant, Financial Document, and Loan Application.
- Walk the room through one table's columns and a few sample rows so participants know what correct data looks like and can distinguish data-readiness problems from model or prompt problems.
- Provide a troubleshooting decision tree: no tables visible means the Enterprise solution import did not complete; empty tables means the base data load failed; tables present but no results means a permissions or filter issue.
**Speaker note:** This single checkpoint prevents the most common Lab 20 support escalation. Open the Power Apps maker portal, navigate to the Dataverse tables view, and show the five Woodgrove Lending Hub tables with sample data on screen. Ask the room to confirm they see the same tables before continuing. If any participant has missing or empty tables, resolve the data-readiness issue now rather than debugging it during Lab 20 when it will be mistaken for a grounding or model problem. Stress that schema quality and access control matter as much as prompt wording.

### Slide 72: Dataverse grounding patterns
- Use Dataverse when the scenario needs governed operational data, structured records, and role-based access.
- Align table visibility, permissions, and traceability before trusting the experience in front of users.
- Connect data-grounded behavior to later diagnostics, transcript analysis, and improvement cycles.
**Speaker note:** Tie Dataverse readiness to both business value and operational accountability. Contrast Dataverse with Day 1 grounding choices: public sites give breadth, SharePoint gives enterprise content and lists, files give narrow references, and Dataverse gives structured operational records with stronger filtering and permissions. Stress that schema quality and access control now matter as much as prompt wording.

### Slide 73: Lab Time: Lab 20
- Connect the Loan Processing Agent to Dataverse safely and verify only the needed data is in scope.
- Ask learners to validate permissions early so the room does not mistake access issues for design issues.
- Define success as visible, relevant, governed data access in the UI.
**Speaker note:** Treat this as a readiness checkpoint because data access variability is common across tenants.

### Slide 74: Lab 20: Dataverse grounding
- Open or configure the Dataverse grounding path and confirm the target data is visible.
- Test a lending question that benefits from governed business data instead of general knowledge only.
- Capture any mismatch between scenario needs, data quality, and available permissions.
**Speaker note:** Keep the lab focused on governed usefulness rather than deep schema exploration. Treat missing tables, empty results, or permission errors as data-readiness problems first, not model problems. This helps facilitators troubleshoot faster and teaches participants to separate AI behavior from data access.

### Slide 75: Document outputs with guardrails
- Generated documents need clear inputs, approved templates, and obvious review points.
- Focus on repeatable lending artifacts where the regulatory expectation is already known, such as the **Adverse Action Notice** sent when a credit application is denied.
- Make output quality measurable before anyone treats the result as production-ready, and keep the human reviewer (compliance officer) on the critical path.
**Speaker note:** Anchor the room on a regulated artifact. ECOA Regulation B requires lenders to notify applicants of adverse action within 30 days, and FCRA §615(a) prescribes the content when a consumer report was used. The agent's job is to draft, never to send.

### Slide 76: Lab Time: Lab 21
- Generate one **draft** Adverse Action Notice for a denied loan application from structured Dataverse fields.
- Ask learners to review the draft for structure, statutory language, and the explicit "DRAFT — for compliance review" framing.
- Use the timebox to confirm the guard branch refuses to generate a notice when the application is not denied.
**Speaker note:** The point of the lab is the governance frame: a draft for a human reviewer, never an auto-sent letter. The document-generation mechanic is the same Word template + prompt + flow + topic pattern; only the scenario changed.

### Slide 77: Lab 21: Document generation — Adverse Action Notice
- Build (or use the prebuilt) Word template with content controls for applicant, application, decision, principal reasons, credit bureau, statutory language, and reviewer.
- Use a prompt to draft the FCRA §615(a) consumer-rights and dispute-rights paragraphs in plain language for compliance review.
- Wire the agent flow with a `Denied` guard, return a `DRAFT-` prefixed Word file, and reinforce the no-auto-send rule in the chat reply.
**Speaker note:** Reinforce three governance moments: the `DRAFT` token in the file name, the chat-reply review reminder, and the Denied guard in the flow. The lab text is a simplified, illustrative draft — banks must use their own legal-approved templates and have qualified compliance and legal staff review every notice before it leaves the institution.

### Slide 78: [TRANSITION] Into MCP
- Move from internal orchestration into governed extensibility with external tools.
- Keep access narrow, auditable, and easy to explain to admins and sponsors.
- Use only the supported GA setup path so the workshop remains reproducible.
**Speaker note:** This transition sets the expectation that extensibility must stay governed to stay credible. Frame MCP as governed extensibility rather than open-ended plugin growth. If the wizard or catalog is unavailable, switch to demo mode quickly, protect the concept, and keep the message on narrow, auditable tool scope.

### Slide 79: Module 10: MCP and extensibility
- Treat MCP as a generally available capability in this workshop.
- Use the in-product onboarding wizard to add or review MCP servers inside Copilot Studio.
- Keep tool scope narrow, auditable, and explainable to admins; avoid non-GA detours.
- Avoid fallback branching, manual secret editing, or any non-wizard setup path.
- For any custom MCP servers built after the workshop, use **Streamable HTTP** as the recommended transport; **Server-Sent Events (SSE)** is deprecated for new MCP servers.
**Speaker note:** State the supported path clearly so the room does not anchor on outdated guidance and extensibility stays governed.

### Slide 80: MCP architecture: protocol, not connector <!-- NEW -->
- Explain how MCP differs from classic connectors: one server exposes multiple tools vs. one action per capability.
- Describe the Agent 365 tooling server dependency and how the MCP catalog works as a governed marketplace.
- Show that MCP enables richer, composable tool integration while maintaining admin-controlled boundaries.
- Note transport guidance for any custom MCP servers: **Streamable HTTP** is the recommended transport; **Server-Sent Events (SSE)** is deprecated for new servers and existing SSE-based servers should be migrated.
**Speaker note:** Participants need this mental model before Lab 22 — without it, MCP looks like "just another connector." Workshop labs only use pre-built Microsoft-hosted servers added through the in-product wizard, so transport choice never comes up during the lab itself; mention Streamable HTTP only as forward guidance for teams that will build their own MCP servers after the workshop.

### Slide 81: MCP consent and governance <!-- NEW -->
- Walk through the consent flow: server selection → connection → per-tool consent card → Allow/Deny.
- Explain what governance controls the admin has over MCP server availability and tool approval.
- Position the consent model as the mechanism that keeps extensibility auditable and reversible.
**Speaker note:** The consent flow is new to most participants. Demo it live if possible before they hit it in Lab 22.

### Slide 82: Lab Time: Lab 22
- Add MCP through the supported UI path and keep the scope limited to one useful lending task.
- Ask learners to validate why the server belongs in the scenario before they enable it.
- Define success as a governed tool connection that is visible and explainable.
**Speaker note:** Use this lab to connect extensibility to security and supportability, not just capability.

### Slide 83: Lab 22: MCP integration
- Open the MCP onboarding wizard and add or review a supported server in the agent.
- Confirm the tool appears with the right connection state and purpose in the UI.
- Test one safe, auditable MCP-assisted task that fits the Loan Processing Agent scenario.
**Speaker note:** Keep the example small so the room learns the pattern without overextending scope.

### Slide 84: Module 11: Channels and feedback
- Close the operational loop by pairing publishing readiness with user feedback and support expectations.
- Match channel choices to audience, policy, and ownership rather than novelty.
- Turn feedback into evidence that can influence backlog, evaluation, and release decisions.
**Speaker note:** This module connects user reach with the quality loop that keeps the agent improving.

### Slide 85: Publish and deploy workflow <!-- NEW -->
- Walk through the publish → Channels tab → Microsoft channels → Add channel → Teams installation → availability options sequence.
- Show how the same channel pane covers both **Microsoft Teams** and the **Microsoft 365 Copilot** surface, and call out the M365 Copilot license requirement for end users.
- Position **knowledge prioritization** (Loan Policy SharePoint > woodgrovebank.com > general web search) and **suggested prompts** (4 banking conversation starters) as the pre-publish steps that shape the user's first impression.
- Explain Copy link, Show to teammates, and Show to my organization as distinct availability levels.
- Highlight where participants commonly lose orientation and how to recover at each step.
**Speaker note:** This sequence has 5+ clicks and participants lose orientation at the availability step — walk through it visually before Lab 11. Set expectations that knowledge prioritization is a soft preference (orchestrator still chooses per turn) and that suggested prompts are the cheapest adoption lever in the workshop.

### Slide 86: WhatsApp and external channels <!-- NEW -->
- Position WhatsApp and other external channels in the broader channel strategy alongside Teams and web.
- Explain where they appear in the UI ("Other channels" section) and what the preview/GA readiness looks like.
- Connect external channel availability to compliance, branding, and support ownership decisions.
**Speaker note:** Lab 11 asks participants to identify WhatsApp in the channel inventory — give them context on why it matters for multi-channel rollout.

### Slide 87: Channel overview: Teams and more
- Compare Teams, Microsoft 365 Copilot, WhatsApp, and web experiences from a readiness and governance perspective.
- Call out how branding, support, compliance, and channel policy affect rollout decisions.
- Explain why channel choice changes monitoring, adoption, and change-control expectations.
**Speaker note:** Use the channel overview to broaden the conversation from publishing mechanics to operating reality.

### Slide 88: Lab Time: Lab 23
- Capture user feedback intentionally instead of treating comments as informal noise.
- Ask learners to decide who reviews feedback, how often, and what action follows.
- Keep the feedback path tied to quality improvement and adoption learning.
**Speaker note:** This lab turns user reaction into something the team can operationalize.

### Slide 89: Lab 23: User feedback
- Enable or review the feedback capture path and verify where feedback lands.
- Test how a user can submit feedback after a conversation or outcome.
- Connect feedback signals to future tuning, release decisions, and support processes.
**Speaker note:** Show that feedback is most useful when it has an owner and a follow-up path.

<!-- Progress: 90/96 slides complete -->

### Slide 90: Module 12: Evaluation and ROI
- Use evaluation as a repeatable release gate instead of relying on ad hoc chat testing — Copilot Studio Evaluation is generally available since April 2026.
- Pair evaluation evidence with transcript analytics and ROI analytics to tell a fuller value story.
- Connect quality results to rollout, staffing, and investment decisions after the workshop.
**Speaker note:** This final module brings quality, insight, and business value into one decision framework. Bring Lab 12 back into the conversation here: ROI analytics tells the value story, while evaluation tells the quality and release-readiness story. Together they answer whether the agent is worth scaling and safe enough to scale. Now that Evaluation is GA, treat it like any other release-gate practice — it belongs in your operating model, not in a "preview" sidebar.

<!-- NEW -->
### Slide 91: Evaluation grader types and multi-grader scoring
- Walk the seven GA grader types: **General response quality**, **Semantic meaning**, **Keyword presence**, **Text similarity**, **Exact match**, **Capability usage**, and **Custom Graders** (Classification).
- Explain **multi-grader**: attach more than one grader to a single test case so one run can score quality, tool use, and compliance keywords together. Per-grader pass rates appear alongside the overall pass rate.
- Guide the room on when to choose each grader: default to General response quality, add Capability usage when a tool or action must fire, add Keyword presence or Custom Graders for mandatory disclosure language, and use Semantic meaning when wording flexibility is fine.
**Speaker note:** Walk through the grader types before Lab 24 so participants can make an informed choice. Emphasize that General response quality is the safe default, but Capability usage is critical whenever the agent must invoke a specific tool or connector — a correct-sounding text response that skipped the required call is still a failure. Reinforce that multi-grader is a GA capability, not a preview, so the right pattern in production is to stack two or three graders on each case rather than picking one and hoping.

<!-- NEW -->
### Slide 92: Zones of Coverage and multi-turn evaluation
- Frame every test set with the PowerCAT **Zones of Coverage**: **Capability** (does the agent do the lending task?), **Regression** (does last week's fix still hold?), and **Safety** (does the agent refuse, redirect, or escalate?).
- Show that **multi-turn evaluation** scores a full conversation, not just the last message — critical when an ambiguous loan officer prompt should trigger a clarifying question first.
- Mention **auto-generated test inputs** as a starter: Copilot Studio can draft cases from your agent instructions, and you refine them for the lending scenario.
**Speaker note:** Zones of Coverage is the simplest way to keep a test set honest. If everything in the set is a Capability case, regressions sneak in and safety is invisible. Multi-turn matters because most real loan-officer prompts are ambiguous; single-shot evaluation hides clarifying-question failures. Use auto-gen as a draft accelerator only — every case still needs to be grounded in the lending context before it earns a place in the release-gate set.

### Slide 93: Lab Time: Lab 24
- Run a repeatable quality review with scored evidence instead of intuition alone.
- Ask learners to balance Capability, Regression, and Safety cases, attach two or more graders per case, and add at least one multi-turn case.
- Use the activity map and transcript evidence to prepare one improvement loop.
**Speaker note:** This lab matters most when participants leave with a reusable QA habit, not just one run. The new GA capabilities — multi-grader, multi-turn, auto-generated inputs — are not extras; they are the shape the test set should take from now on.

### Slide 94: Lab 24: Evaluation and QA
- Create or run an evaluation test set in the UI using realistic lending prompts across all three Zones of Coverage.
- Inspect per-grader pass rate, grader reasoning, multi-turn conversation detail, and activity-map evidence for at least one failing case.
- Use the findings to refine the agent before calling it release-ready.
- For advanced teams (IT Pro / Developer): mention the **EvalGate** CI/CD pattern (e.g., **EvalGateADO** for Azure DevOps) as a take-home for wiring evaluation into a build pipeline. Awareness only — out of scope for the workshop.
**Speaker note:** Connect the workflow back to the transcript-analysis architecture so quality improvement feels operational and repeatable. Show what makes a failing case useful: clear expected behavior, per-grader reasoning, and an activity map that points to the real fix. Close with EvalGate as the natural next step for teams that already use Azure DevOps; do not demo it.

### Slide 95: Lab Time: Lab 25
- Start the optional developer branch while the main room stays on wrap-up, QA review, and rollout planning.
- Direct developers to the VS Code workflow only if they are caught up on the core path.
- Keep nondevelopers focused on evaluation findings, ROI framing, and next actions.
**Speaker note:** This structure keeps the core workshop complete while still giving developers a relevant extension path.

### Slide 96: Lab 25: VS Code workflow
- Optionally clone and sync the agent with the VS Code extension using the supported GA workflow.
- Validate that local edits flow back into Copilot Studio without changing the workshop baseline or bypassing in-product controls.
- Use this branch only for developers while the main room closes on evaluation, ROI, and rollout actions.
**Speaker note:** End by making the developer add-on feel optional, useful, and safely separated from the core path. Reassure nondevelopers that the core delivery story is already complete. For developers, stress that local editing complements, not replaces, the governed in-product flow and later release controls.

## Module 13b: ALM and Governance for Copilot Studio Agents

Module 13b is a concept module that opens Day 2 between Lab 13 (solution import) and Lab 14 (instructions). It runs ~30 minutes as a lecture plus one facilitator-driven demo, with no hands-on student exercise — student Sandbox environments cannot exercise Power Platform Pipelines or three separate governance zones. The full slide source lives in `workshop\Copilot-Studio-Workshop-Slides\Module-13b-ALM-and-Governance.md`.

### Slide 97: Why ALM matters for agents <!-- NEW -->
- Frame an agent as a versioned application: instructions, topics, knowledge sources, connections, environment variables, and child agents are all deployable artifacts, not settings.
- Establish the bank-grade expectation: source of truth, peer review, traceable promotion, and a rollback path apply to agents the same way they apply to any production code path.
- Anchor the regulatory motivation early — direct edits in production are findings under NYDFS Part 500 §500.11 and the OCC's 2024 AI guidance, not just hygiene problems.
**Speaker note:** Open with one sentence — "Anything you cannot redeploy from source is anything you cannot defend in audit." Use it to set the tone for the rest of Day 2.

### Slide 98: ALM building blocks — Solutions, Connections, Environment Variables, Pipelines <!-- NEW -->
- Walk Solutions as the unit of packaging, using the `WoodgroveLending` solution participants imported in Lab 13 as the live example, and contrast managed (immutable, Production) versus unmanaged (editable, Dev).
- Explain the Connector / Connection / Connection Reference triangle and call it out as the single most common reason a solution import succeeds but does not work after promotion.
- Cover Environment Variables (per-environment configuration, including the Key Vault secret type for anything that would otherwise leak into solution XML) and frame Power Platform Pipelines as the promotion automation that requires Production environments — therefore facilitator-demo only in this workshop.
**Speaker note:** Reinforce the triangle visually if you have a whiteboard. Most "I imported the solution but the connector is empty" support tickets trace to a missing or unbound connection reference.

### Slide 99: Three Zones — a PowerCAT teaching pattern (not an official Microsoft framework) <!-- NEW -->
- State the framing rule out loud the first time the term appears: Three Zones is a PowerCAT teaching pattern, not a published Microsoft framework, and the Microsoft Cloud Adoption Framework "landing zones" concept is something different.
- Walk the three zones in order — Zone 1 Personal Sandbox (maker exploration, ungoverned, ephemeral), Zone 2 Team Dev (curated, source-controlled, shared with the team), Zone 3 Production (managed, monitored, auditable, fully governed) — and describe promotion as a gate, not a copy.
- Map the workshop's environments onto the model: the student Sandbox is Zone 1, the facilitator demo environment is the Zone 2 stand-in, and a real bank deployment lives in Zone 3. Run the `Initialize-FacilitatorGovernanceZones.ps1` console output as the demo visual.
**Speaker note:** Customers who later search for "Microsoft Three Zones" and find nothing will lose trust in the rest of the deck — always say "PowerCAT pattern" out loud the first time the term appears.

### Slide 100: Governance overlay — DLP, Managed Environments, isolation, monitoring <!-- NEW -->
- Cover Data Loss Prevention policy classes (Business, Non-Business, Blocked) and make the point that the same agent in Zone 1 versus Zone 3 may legitimately have different DLP postures.
- Walk the Managed Environments feature set most relevant to Zone 3: sharing limits, weekly digest, solution checker enforcement, and maker welcome content.
- Cover environment isolation as the cross-environment data-movement guard, then close with tenant-level monitoring (capacity, license, and Copilot Studio credit consumption surfaced in the Power Platform admin center).
**Speaker note:** This is the slide where the IT Pro audience leans in — acknowledge them by name and note that the slide is intentionally heavier on platform controls than maker UX.

### Slide 101: FSI regulatory anchors <!-- NEW -->
- Map the module to the five regulatory anchors students will be asked about in design review: GLBA Safeguards Rule (data protection and access controls), NYDFS Part 500 §500.11 (third-party service provider security policies), OCC AI guidance (model risk management for LLM-based agents), EU AI Act Annex III §5(b) (banking systems affecting access to credit are high-risk AI), and SR 11-7 (US Federal Reserve model risk management — already cited in Lab 09).
- For each anchor, explicitly tie the regulation to a Three-Zones or ALM practice already on the prior slides — the GLBA Safeguards boundary is partly how Zone 1 versus Zones 2/3 is enforced; SR 11-7 ties to Lab 09's four-eyes pattern and Lab 16's autonomous-triage demo.
- Close by referencing `workshop\automation\Disable-WorkshopAutonomousTriggers.ps1` as the cleanup tool that completes the governance loop after the Lab 16 demo, so the IT Pro audience sees "build" and "decommission" as equally first-class operations.
**Speaker note:** End with one line — "Every Day 2 lab from this point forward is, implicitly, a control you would defend in one of these reviews." That sentence is the bridge into Lab 14 instructions.

<!-- NEW -->
### Slide 97: Module 13b: Autonomous Triage Assistant — facilitator demo
- Show one trigger-driven Copilot Studio agent firing on its own schedule against the facilitator demo Loan Processing Agent and writing an **internal-only triage memo** to a SharePoint library — no borrower contact, no credit decision, no Dataverse write to any application or decision row.
- Frame the demo as a **governance showcase**, not a productivity demo: the teaching value is in what the agent is *forbidden* to do.
- Anchor the pattern to the regulatory guardrails the room already cares about: **SR 11-7 model risk management**, **ECOA / Regulation B §1002.9 adverse-action notices**, **OCC AI guidance (Bulletin 2021-39)**, **EU AI Act Annex III §5(b) high-risk credit scoring**, and the **four-eyes principle**.
**Speaker note:** This is intentionally facilitator-demo only — students do not deploy this in their environments. The original "Autonomous Borrower-Watch" idea was reframed after the FSI council flagged it as a clear violation of SR 11-7 effective-challenge expectations and ECOA fair-lending norms. The reframed Tier-2 Triage Assistant keeps the autonomous-trigger teaching value while removing every regulated-decision and customer-facing action. Open the maker portal, show the trigger, then open the SharePoint memo library and walk a real prior memo. Read the memo's "Items the agent declined to recommend" and "Audit" sections aloud — those two sections are the demo. Do not soften the "what we are NOT doing" list; that is the governance teaching moment, not a footnote.

<!-- NEW -->
### Slide 98: Autonomous demo — discussion and closeout
- Pose the discussion prompt: *"What would have to be true before you would let this same trigger deliver its memo to the customer instead of to your triage manager? List the controls."* Let small groups answer before you do.
- Capture the room's controls list — explicit human review, adverse-action workflow, model validation and challenger model, transcript retention and supervisory review, fair-lending impact testing, complaint handling, opt-in/opt-out — and reinforce that this is the *long list* that separates an internal triage memo from a customer-facing decision.
- Close on cleanup: the autonomous trigger keeps firing and keeps burning Copilot Credits after the workshop ends. Run `Disable-WorkshopAutonomousTriggers.ps1` against the facilitator demo environment the same day the workshop closes, then optionally archive the SharePoint memo library as a teaching artifact.
**Speaker note:** Do not skip the discussion prompt. The point of the entire demo is the conversation it produces, not the memo. End with the cleanup callout on screen so the next facilitator inheriting the demo environment has the script name in front of them. See `workshop/facilitator-guide/autonomous-triage-demo.md` for the full demo script, the prerequisites, the regulatory citations, and the Q&A talking points.
