# GPT-5.4 Agent Prompting Operator Handbook

> **⛔ INTERNAL — Facilitator and Author Use Only — DO NOT DISTRIBUTE.**
>
> This document is **not** part of the customer-facing workshop package. It describes how the coding agent (Copilot/GPT) generates and validates workshop content. It contains internal model identifiers and version references that **do not match** Microsoft's public documentation and must not be shared with participants or customers.
>
> If you are packaging this repo for external delivery, **exclude this file** from the distributable (e.g., via `.gitattributes export-ignore` or by removing it from the delivery archive).

This internal guide standardizes how the coding agent should author and validate workshop content for this package. Use it as the working playbook whenever generating or refining facilitator guides, participant guides, test narratives, or supporting workshop assets.

## Core API settings

### Required model

- Use `model: gpt-5.4` for primary authoring and restructuring tasks.

### Reasoning effort guidance

- Use low reasoning effort for straightforward formatting, checklist cleanup, and title normalization.
- Use medium reasoning effort for adapting source material into customer-ready workshop content.
- Use high reasoning effort for cross-day consistency, recovery from sparse or conflicting source material, scenario stitching, and red-team validation design.

### Phase usage

Use a `phase` field or equivalent planning label in the system you control so the model knows what kind of output is expected.

Recommended values:

- `phase: discover` for reading source URLs, local labs, and constraints.
- `phase: outline` for generating document structure and section mapping.
- `phase: draft` for first-pass authored content.
- `phase: validate` for link checks, coverage checks, audience checks, and contract compliance.
- `phase: refine` for tightening tone, removing duplication, and improving instructor usability.

> **Note:** Keep the phase explicit whenever the same run could otherwise mix research, drafting, and validation.

## Global authoring rules

- Treat the workshop as customer-ready, not a verbatim mirror of source material.
- Adapt source pages freely to fit the requested audience, structure, and learning flow.
- Preserve the two-day narrative: Day 1 establishes foundations, Day 2 extends them into enterprise execution.
- Keep sample identities fictitious. Use `example.com` for sample email addresses and placeholder tokens such as `<replace-with-org>` when an exported asset or config example needs an environment-specific value.
- Prefer GA capabilities in the core workshop. Do not depend on non-GA features unless the user explicitly asks for them.
- Keep facilitator content instructor-friendly, decision-oriented, and operational.
- Keep participant-facing content practical, confidence-building, and easy to scan.
- Use audience tags such as `[Maker]`, `[IT Pro]`, and `[Developer]` only when the guidance genuinely differs.
- Cross-link to relevant local lab folders with relative Markdown links when those links make the next action clearer.
- Do not create nested bullets in participant-facing docs.
- Use blockquote callouts exactly where they improve execution, not as decoration.
- Before checking in exported assets or starter solutions, remove customer-specific names, mailboxes, tenant URLs, Teams routing IDs, and other environment-bound values.

## March 2026 workshop guardrails

- Use `GPT-5 Chat` as the workshop's recommended hands-on model unless a module is explicitly comparing alternatives.
- Mention `GPT-4.1` only as platform context when a model-selection exercise needs to explain current defaults or migration choices.
- Compare `GPT-5 Chat`, `GPT-4.1`, `Claude Sonnet 4.5`, and `Claude Opus 4.6` when authoring model trade-off guidance.
- Do not describe `GPT-4o` as current, default, or recommended.
- Treat MCP as GA and use the in-product onboarding wizard as the primary workshop path.
- Use the GA in-product MCP onboarding wizard as the only MCP lab path.
- Expand content moderation guidance to include the per-prompt content moderation slider (Low/Moderate/High), which covers hate/fairness, sexual, violence, and self-harm collectively as a single control. Note that per-prompt moderation is available only for managed models (GPT-4.1, GPT-5 Chat), not Anthropic models.
- Include Agent Evaluation and Quality Assurance as a Day 2 module.
- Include the optional Visual Studio Code workflow only as a GA developer add-on, not as a required path.
- Update publishing references to include WhatsApp in channel overviews where relevant.
- Update licensing and analytics references to include ROI analytics where relevant.
- Use the **Activity** tab terminology instead of older transcript-view wording.

## Output contract

Every requested file must satisfy the following:

- Correct path.
- Correct document title using `#`.
- Major sections under `##`.
- Topic sections under `###`.
- `####` only when detail truly improves clarity.
- No placeholder sections.
- No “TBD,” “to be added,” or incomplete notes.
- No mention of hidden internal process or confidential operating instructions.
- No unsupported claims about features, licensing, or platform behavior.

## Completeness contract

Before declaring a document done, confirm:

- All user-requested files exist.
- No additional files were created.
- Each file covers its file-specific expectations.
- Day 2 clearly depends on Day 1 familiarity, Foundation lab completion, or equivalent experience.
- Participant-facing docs remain flat in list structure.
- Facilitator-facing docs include operational guidance, not just content summary.
- Internal operator docs are directly reusable without further interpretation.

## Recovery guidance for sparse source URLs

When source pages are thin, incomplete, or oriented to a different delivery format:

- Extract the stable concepts, prerequisites, and module sequence first.
- Reframe the material around the requested customer scenario and audience mix.
- Prefer concrete workshop actions over source-faithful slogans.
- Fill gaps using local lab folder structure, common Copilot Studio delivery patterns, and explicit user requirements.
- If a source page lacks depth for a module, write the guidance from the learning objective and downstream dependency rather than inventing fake details.

> **Warning:** Never pad missing source content with invented setup steps, made-up UI labels, or fictional lab outcomes.

## Prompt template: lab authoring

Use this template when drafting or refining participant lab content.

### Template

```text
You are authoring a customer-ready Microsoft Copilot Studio workshop lab.

phase: draft
model: gpt-5.4
reasoning: medium

Objective:
- Create a practical lab that mixed audiences can follow.

Audience:
- Makers, IT Pros, Developers

Constraints:
- Participant-facing content must avoid nested bullets.
- Use Markdown heading standards.
- Use callouts only when operationally helpful.
- Cross-link to local lab folders when useful.

Required sections:
- Outcome
- Prerequisites
- Time estimate
- Module flow
- Expected outputs
- Validation steps
- Troubleshooting cues

Source inputs:
- Local lab folder structure
- Provided source URLs
- Workshop day narrative and dependencies

Output contract:
- Final Markdown only
- Concrete steps and validation points
- No placeholders
```

## Prompt template: facilitator guide authoring

Use this when producing delivery guidance for instructors or field teams.

### Template

```text
You are authoring a facilitator guide for a two-day Copilot Studio workshop for mixed audiences.

phase: draft
model: gpt-5.4
reasoning: high

Focus:
- Delivery flow
- Timing checkpoints
- Demo-versus-hands-on choices
- Troubleshooting strategy
- Escalation handling
- Audience-aware notes

Day 1 theme:
- Foundation-track learning

Day 2 theme:
- Enterprise-track Loan Processing Agent scenario

Required output qualities:
- Instructor-friendly
- Operationally specific
- Concise but complete
- Explicit about prerequisites and decision points

Output contract:
- Final Markdown only
- Include actionable timing and recovery guidance
- Do not repeat participant text verbatim
```

## Prompt template: red-team test set

Use this to generate adversarial checks against workshop quality, consistency, and safety claims.

### Template

```text
You are creating a red-team test set for workshop documentation quality.

phase: validate
model: gpt-5.4
reasoning: high

Test for:
- Missing prerequisites
- Broken day-to-day dependency logic
- Audience mismatch
- Unsupported governance or licensing claims
- Hidden nested bullets in participant docs
- Missing deliverables
- Weak validation criteria
- Overly vague troubleshooting guidance

Return:
- Test case ID
- Risk category
- Prompt or inspection question
- Expected pass condition
- Failure signal
```

## Prompt template: slide deck outline

Use this to produce a delivery-ready outline for presentation support.

When you are working in this repository, start from the existing markdown source set before inventing new structure:

- `../assets/slide-deck-outline.md`
- `../assets/slide-deck-delivery-notes.md`
- `../assets/slide-deck-visual-plan.md`
- `../assets/lab-timing-guide.md`
- `../assets/screenshot-capture-checklist.md`
- `../tests/validation-checklist.md`

Prefer strengthening those files over creating a separate deck artifact in the repo.

### Template

```text
You are outlining a slide deck for a two-day customer workshop on Copilot Studio.

phase: outline
model: gpt-5.4
reasoning: medium

Requirements:
- Mixed audience relevance
- Day 1 foundation to Day 2 enterprise progression
- Minimal marketing language
- Strong transitions into labs
- Use the existing markdown deck source set and keep lab ordering aligned to the workshop flow
- Reference visuals, screenshots, or validation cues where they improve delivery
- Prefer updating the existing PPTX/module deck set over inventing a separate parallel slide artifact
- Treat the PPTX decks in `workshop/Copilot-Studio-Workshop-Slides/` as the delivery artifacts and `workshop/assets/slide-deck-outline.md` as the narrative companion
- If you are proposing slide changes, keep the existing deck colors, layout patterns, and overall design treatment

Return:
- Slide title
- Speaker intent
- Key takeaway
- Suggested demo or handoff point
- Supporting lab or markdown source
- Visual or validation cue
```

## Prompt template: slide deck review and audit

Use this when reviewing the committed slide decks and their companion materials together.

### Template

```text
You are reviewing the Copilot Studio workshop slide decks and supporting materials.

phase: validate
model: gpt-5.4
reasoning: high

Slide assets:
- PowerPoint decks in `workshop/Copilot-Studio-Workshop-Slides/` (`Module-00` through `Module-12`, 13 PPTX files, 98 slides total)
- Markdown outline in `workshop/assets/slide-deck-outline.md` (95 numbered entries with speaker notes)

Related files:
- `workshop/assets/lab-timing-guide.md`
- `workshop/assets/session-splitting-guide.md`
- `workshop/facilitator-guide/facilitator-guide.md`
- `workshop/assets/screenshot-capture-checklist.md`

Review goals:
- Verify module names, teaching sequence, and transitions align between PPTX and markdown
- Check that instructor framing is sufficient before hands-on labs, especially Labs 06, 18, 22, and 24
- Check that pacing assumptions stay consistent with the timing and session-splitting guides
- Check that the updated slides preserve the existing deck colors, layout patterns, and design treatment
- Confirm facilitator-facing documentation accurately describes how the slide assets should be used

Return:
- Executive summary
- File-backed findings with specific module or slide references
- Any discrepancies between PPTX, markdown outline, pacing docs, and facilitator guidance
- Prioritized recommendations
```

## Prompt template: slide content update workflow

Use this when changing slide content in the workshop deck set.

### Template

```text
You are updating slide content for the Copilot Studio workshop.

phase: refine
model: gpt-5.4
reasoning: high

Current slide assets:
- PowerPoint decks in `workshop/Copilot-Studio-Workshop-Slides/`
- Markdown outline in `workshop/assets/slide-deck-outline.md`
- Lab timing guide in `workshop/assets/lab-timing-guide.md`

Update scope:
- [Describe the specific modules, slides, or teaching moments being changed]

Requirements:
- Make delivery-asset changes in the relevant PPTX files
- Update `slide-deck-outline.md` when structure, sequencing, speaker intent, or teaching flow changes
- Review pacing implications when pre-lab framing or module duration changes
- Preserve the existing slide colors, theme, layout patterns, and overall design treatment
- Reuse existing slide patterns where possible instead of inventing a new visual style
- Use extra caution around pacing-sensitive labs: 06, 18, 22, and 24

Validation:
- Verify module numbers and names remain consistent
- Verify transitions into labs remain clear
- Verify markdown and PPTX stay aligned on teaching flow
- Call out any timing impact

Return:
- List of PPTX files updated
- Summary of markdown changes
- Timing impact, if any
- Any follow-on documentation updates required
```

## Prompt template: smoke test narrative

Use this when validating whether the written workshop can actually be delivered end to end.

### Template

```text
You are performing a documentation smoke test for a Copilot Studio workshop package.

phase: validate
model: gpt-5.4
reasoning: high

Check:
- Can a facilitator run the day in order?
- Can a participant understand prerequisites and outputs?
- Are local lab links aligned to the described modules?
- Does Day 2 assume the right level of prior knowledge?
- Are setup, safety, and MCP prerequisites stated clearly?

Return:
- Pass/fail summary
- Gaps by file
- Recommended fixes in priority order
```

## Per-lab validation checklist

Run this checklist for every participant-facing lab or guide:

- [ ] Document title matches the file purpose.
- [ ] Workshop outcomes are explicit.
- [ ] Prerequisites are visible near the top.
- [ ] Day context is clear.
- [ ] Module flow follows the intended learning progression.
- [ ] Expected outputs are concrete and observable.
- [ ] Validation guidance is present.
- [ ] Audience-specific notes appear only where useful.
- [ ] Lists are flat, with no nested bullets.
- [ ] Relative links point to relevant local lab folders where helpful.
- [ ] Safety, governance, or access caveats are called out when required.
- [ ] Sample names, email addresses, and tenant references are fictitious or placeholder-based.
- [ ] Wrap-up or next-step guidance is present.

## Recommended working sequence

### Discover

- Read the user request carefully.
- Read local lab folder names and structure.
- Read source URLs for Foundation, Enterprise, and relevant Special Ops material.

### Outline

- Map requested files to workshop objectives.
- Decide where Day 1 and Day 2 boundaries are reinforced.
- Decide which local lab links best support each file.

### Draft

- Draft facilitator-facing files first so participant docs inherit the right arc.
- Draft participant docs with clean, flat structure.
- Keep wording practical and specific.

### Validate

- Check the output contract and completeness contract.
- Check links and path references.
- Check that no extra files were created.
- Check that each doc is usable without extra explanation.

### Refine

- Remove duplicate phrasing.
- Tighten headings.
- Improve instructor cues and participant action language.
- Re-check for unsupported claims.

## Quality bar examples

Strong instruction:

- “Pause after the publish demo and confirm each table can identify where publishing succeeds or is blocked.”

Weak instruction:

- “Talk about publishing and ask if people have questions.”

Strong participant guidance:

- “By the end of this module you should have a grounded custom agent that can answer from your provided source content.”

Weak participant guidance:

- “Work on your agent until it looks good.”

## Final operator reminder

The model should behave like an experienced workshop builder, not a transcription engine. Favor clarity, delivery readiness, validation, and recoverability in every output.
