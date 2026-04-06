# Session Splitting Guide

Use this guide when delivering the workshop as multiple 2–3 hour sessions instead of the standard two-day format.

## Data Sources

- **README estimates**: Per-lab `⏱ Estimated time` from each lab's README (self-paced participant time)
- **Timing guide**: Facilitator-led allocations from `lab-timing-guide.md` (compressed by demo/guidance)
- **Effective time**: README estimate × 1.15 (adds 15% for session intro, recap, Q&A, transitions)

## Raw Timing Summary

| Day | Labs | README Total | Effective Total |
|-----|------|-------------|----------------|
| Day 1 (Labs 00–12) | 13 labs | 530 min (8.8 hrs) | 610 min (10.2 hrs) |
| Day 2 (Labs 13–24) | 12 labs | 460 min (7.7 hrs) | 531 min (8.9 hrs) |
| Lab 25 (optional) | 1 lab | 30 min (0.5 hrs) | 35 min (0.6 hrs) |
| **Core total** | **25 labs** | **990 min (16.5 hrs)** | **~1,141 min (19 hrs)** |

> **Note:** The standard two-day format compresses this to ~12 hours of instruction time (6 hrs/day) by using facilitator demos, tighter pacing, and parallel troubleshooting. Multi-session delivery restores closer to full README time because participants work more independently between sessions.

## Per-Lab Breakdown

| Lab | Title | README Min | Effective Min |
|-----|-------|-----------|--------------|
| 00 | Environment Setup | 45 | 52 |
| 01 | Intro to Agents | 20 | 23 |
| 02 | Copilot Studio Fundamentals | 30 | 35 |
| 03 | Declarative Agents | 60 | 69 |
| 04 | Solutions | 45 | 52 |
| 05 | Prebuilt Agents | 30 | 35 |
| 06 | Custom Agent | 75 | 86 |
| 07 | Topics and Triggers | 60 | 69 |
| 08 | Adaptive Cards | 45 | 52 |
| 09 | Agent Flows | 45 | 52 |
| 10 | Event Triggers | 25 | 29 |
| 11 | Publish Agent | 30 | 35 |
| 12 | Licensing | 20 | 23 |
| 13 | Loan Processing Agent Setup | 45 | 52 |
| 14 | Agent Instructions | 25 | 29 |
| 15 | Multi-Agent | 40 | 46 |
| 16 | Trigger Automation | 40 | 46 |
| 17 | Model Selection | 30 | 35 |
| 18 | Content Moderation | 40 | 46 |
| 19 | Multimodal Prompts | 35 | 40 |
| 20 | Dataverse Grounding | 40 | 46 |
| 21 | Document Generation | 45 | 52 |
| 22 | MCP Integration | 45 | 52 |
| 23 | User Feedback | 30 | 35 |
| 24 | Agent Evaluation | 45 | 52 |
| 25 | VS Code Extension *(optional)* | 30 | 35 |

---

## Recommended: 8 Sessions (2–3 hrs each)

Each session includes 10 min for session intro/recap + 5 min wrap-up. Sessions over 2 hrs include a 10 min break.

### Session 1 — Getting Started (2 hrs)

| Lab | Title | Time |
|-----|-------|------|
| 00 | Environment Setup | 45 min |
| 01 | Intro to Agents | 20 min |
| 02 | Copilot Studio Fundamentals | 30 min |
| — | Session overhead | 15 min |
| — | **Total** | **110 min (~2 hrs)** |

**Theme:** Get everyone signed in, oriented, and navigating Copilot Studio.

### Session 2 — Agent Patterns and Reuse (2.5 hrs)

| Lab | Title | Time |
|-----|-------|------|
| 03 | Declarative Agents | 60 min |
| 04 | Solutions | 45 min |
| 05 | Prebuilt Agents | 30 min |
| — | Break | 10 min |
| — | Session overhead | 15 min |
| — | **Total** | **160 min (~2.5 hrs)** |

**Theme:** Explore declarative agents, solution packaging, and template reuse before building from scratch.

### Session 3 — Build Your Agent (2.5 hrs)

| Lab | Title | Time |
|-----|-------|------|
| 06 | Custom Agent | 75 min |
| 07 | Topics and Triggers | 60 min |
| — | Break | 10 min |
| — | Session overhead | 15 min |
| — | **Total** | **160 min (~2.5 hrs)** |

**Theme:** Create the Woodgrove Customer Service Agent with grounding, then add structured topic routing.

### Session 4 — Interaction and Automation (2.5 hrs)

| Lab | Title | Time |
|-----|-------|------|
| 08 | Adaptive Cards | 45 min |
| 09 | Agent Flows | 45 min |
| 10 | Event Triggers | 25 min |
| — | Break | 10 min |
| — | Session overhead | 15 min |
| — | **Total** | **140 min (~2.5 hrs)** |

**Theme:** Connect conversation to action — cards capture input, flows write back to SharePoint, triggers run autonomously.

### Session 5 — Publish, Plan, and Loan Processing Agent Setup (2 hrs)

| Lab | Title | Time |
|-----|-------|------|
| 11 | Publish Agent | 30 min |
| 12 | Licensing | 20 min |
| 13 | Loan Processing Agent Setup | 45 min |
| — | Session overhead | 15 min |
| — | **Total** | **110 min (~2 hrs)** |

**Theme:** Close Day 1 content (publish, licensing) and bridge into Day 2 by importing the Loan Processing Agent solution. This session can run shorter or be padded with Q&A.

### Session 6 — Instructions, Multi-Agent, and Safety (3 hrs)

| Lab | Title | Time |
|-----|-------|------|
| 14 | Agent Instructions | 25 min |
| 15 | Multi-Agent | 40 min |
| 16 | Trigger Automation | 40 min |
| 17 | Model Selection | 30 min |
| 18 | Content Moderation | 40 min |
| — | Break | 10 min |
| — | Session overhead | 15 min |
| — | **Total** | **200 min (~3 hrs)** |

**Theme:** The full orchestration-to-safety arc — instruction quality, multi-agent delegation, automation, model choice, and red-team testing.

### Session 7 — Enterprise AI: Grounding, Documents, and MCP (3 hrs)

| Lab | Title | Time |
|-----|-------|------|
| 19 | Multimodal Prompts | 35 min |
| 20 | Dataverse Grounding | 40 min |
| 21 | Document Generation | 45 min |
| 22 | MCP Integration | 45 min |
| — | Break | 10 min |
| — | Session overhead | 15 min |
| — | **Total** | **190 min (~3 hrs)** |

**Theme:** Enterprise-grade capabilities — read documents, ground in live data, generate business artifacts, extend with MCP tools.

### Session 8 — Quality, Feedback, and Wrap-up (2 hrs)

| Lab | Title | Time |
|-----|-------|------|
| 23 | User Feedback | 30 min |
| 24 | Agent Evaluation | 45 min |
| 25 | VS Code Extension *(optional)* | 30 min |
| — | Session overhead | 15 min |
| — | **Total** | **120 min (~2 hrs)** |

**Theme:** Close the loop — feedback capture, evaluation-driven quality, and the optional developer workflow. Lab 25 can be dropped or assigned as self-paced homework if the session runs long.

---

## Session Summary

| Session | Theme | Labs | Duration |
|---------|-------|------|----------|
| 1 | Getting Started | 00–02 | ~2 hrs |
| 2 | Agent Patterns and Reuse | 03–05 | ~2.5 hrs |
| 3 | Build Your Agent | 06–07 | ~2.5 hrs |
| 4 | Interaction and Automation | 08–10 | ~2.5 hrs |
| 5 | Publish and Lending Setup | 11–13 | ~2 hrs |
| 6 | Instructions, Multi-Agent, and Safety | 14–18 | ~3 hrs |
| 7 | Enterprise AI | 19–22 | ~3 hrs |
| 8 | Quality and Wrap-up | 23–25 | ~2 hrs |
| **Total** | | **26 labs** | **~19.5 hrs** |

---

## Alternative: Compressed 6-Session Option (3 hrs each)

| Session | Labs | Duration | Theme |
|---------|------|----------|-------|
| 1 | 00–05 | 3 hrs | Foundation: Setup through prebuilt agents |
| 2 | 06–09 | 3 hrs | Build: Custom agent, topics, cards, flows |
| 3 | 10–14 | 3 hrs | Bridge: Events, publish, licensing, Loan Processing Agent setup, instructions |
| 4 | 15–18 | 3 hrs | Orchestrate: Multi-agent, automation, model selection, safety |
| 5 | 19–22 | 3 hrs | Enterprise: Multimodal, grounding, doc gen, MCP |
| 6 | 23–25 | 2 hrs | Close: Feedback, evaluation, VS Code |
| **Total** | | **~17 hrs** | |

---

## Delivery Notes

- **Breaks:** Sessions over 2 hours should include at least one 10 min break.
- **Buffer:** The 15% overhead accounts for session start/stop, recap, and Q&A. Increase to 20% if participants are less experienced.
- **Lab 25:** Optional in all formats. Can be assigned as self-paced homework.
- **Session 5** bridges Day 1 close into Day 2 start. This is the natural pivot point between the Foundation and Enterprise tracks.
- **Thematic grouping** ensures each session has a clear learning outcome, not just a time-based split.
- **Between sessions:** Remind participants to keep their environment, SharePoint site, and agent intact. Each session builds on the previous one.
