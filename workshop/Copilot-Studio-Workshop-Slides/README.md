# Copilot Studio Workshop — Slide Decks

This folder contains the 13 PPTX module decks used for live workshop delivery (98 slides total) plus one Markdown-only concept module (`Module-13b-ALM-and-Governance.md`) that opens Day 2 with no PPTX deck yet.

## Module-to-Lab Mapping

### Day 1 — Foundation Track (Modules 00–06)

| Module | Deck | Labs | Slides |
|--------|------|------|--------|
| 00 | `Module-00-Workshop-Framing.pptx` | Lab 00 (Setup) | 8 |
| 01 | `Module-01-Agents-Today.pptx` | Lab 01 | 6 |
| 02 | `Module-02-Studio-Foundations.pptx` | Labs 02–03 | 11 |
| 03 | `Module-03-Reuse-Patterns.pptx` | Labs 04–05 | 5 |
| 04 | `Module-04-Custom-Agent-Design.pptx` | Lab 06 | 5 |
| 05 | `Module-05-Topic-Design.pptx` | Labs 07–09 | 8 |
| 06 | `Module-06-Actions-and-Events.pptx` | Labs 10–12 | 11 |

### Day 2 — Enterprise Track (Modules 07–12)

| Module | Deck | Labs | Slides |
|--------|------|------|--------|
| 07 | `Module-07-Lending-Architecture.pptx` | Labs 13–15 | 10 |
| 08 | `Module-08-Automation-and-Models.pptx` | Labs 16–17 | 8 |
| 09 | `Module-09-Multimodal-and-Data.pptx` | Labs 18–19 | 11 |
| 10 | `Module-10-MCP-and-Extensibility.pptx` | Labs 20–21 | 4 |
| 11 | `Module-11-Channels-and-Feedback.pptx` | Labs 22–23 | 4 |
| 12 | `Module-12-Evaluation-and-ROI.pptx` | Lab 24 | 7 |
| 13b | `Module-13b-ALM-and-Governance.md` (Markdown only — opens Day 2, between Lab 13 and Lab 14) | Concept + facilitator demos: references Lab 13 (solution import muscle memory), Lab 16 (autonomous-triage governance moment), Lab 25 (developer source-control follow-up). No dedicated lab. | 5 (Markdown source) |

Lab 25 is an optional developer stretch lab with no dedicated module deck.

Module 13b is a concept module delivered from a Markdown source (not a PPTX deck yet — future work to convert). It runs ~30 minutes at the start of Day 2 as a lecture plus one facilitator-driven demo. There is no hands-on student exercise: student Sandbox environments cannot exercise Power Platform Pipelines or three separate governance zones. The companion facilitator script `workshop\automation\Initialize-FacilitatorGovernanceZones.ps1` validates the Three-Zones demo environments before class. The cleanup script `workshop\automation\Disable-WorkshopAutonomousTriggers.ps1` is referenced in the closing slide as the tool that closes the governance loop after the Lab 16 demo.

## Companion Sources

The PPTX decks are the delivery-ready artifacts. For speaker notes, narrative structure, and text-first review, see:

- [`../assets/slide-deck-outline.md`](../assets/slide-deck-outline.md) — 101 numbered entries (96 baseline + 5 for Module 13b) with speaker notes and teaching intent
- [`../assets/slide-deck-delivery-notes.md`](../assets/slide-deck-delivery-notes.md) — transition cues and pacing guardrails
- [`../assets/slide-deck-visual-plan.md`](../assets/slide-deck-visual-plan.md) — visual planning for slide layout and design

## Outline Expansion Note

The markdown outline (`slide-deck-outline.md`) contains **101 entries** — 16 more than the original 85 baseline. The 10 new entries (marked `<!-- NEW -->` in the outline) are concept slides for Modules 04 (+3), 07 (+1), 09 (+1), 10 (+2), 11 (+2), and 12 (+1) that extend conceptual coverage before key labs. The PPTX corpus contains 98 slides, with the 3 newest outline entries (Day 1 carryover checklist, Dataverse readiness checkpoint, and evaluation grader types) now having corresponding PPTX slides in their respective module decks.
