# Squad Multi-Repository Deployment Strategy

**Your Three Repositories. One Unified AI Development Workflow.**

---

## Executive Summary

This document provides a comprehensive deployment strategy for running the Squad AI agent framework across your three interconnected repositories. Based on deep research into Squad's architecture, upstream inheritance model, and concurrent execution capabilities, the recommendation is a **Hub-and-Spoke topology** using Squad's built-in Upstream Inheritance feature.

| Decision | Recommendation | Rationale |
|----------|---------------|-----------|
| **Topology** | Hub-and-Spoke (Personal Global Squad + 3 repo squads) | Shared knowledge with repo-specific specialization |
| **Concurrency** | Yes, run all three simultaneously | Each `.squad/` is independent state; no conflicts |
| **IDE** | VS Code with GitHub Copilot Chat | Visual agent interaction, multi-root workspace support |
| **Model** | Claude Opus 4.6 as default (quality over cost) | Your stated preference for accuracy over speed |
| **Autonomous Mode** | `squad watch --execute` per repo | Issue-driven, parallel, unattended execution |

---

## Part 1: Architecture Recommendation

### Why Hub-and-Spoke (Not Three Isolated Squads)

Your three repositories are not independent projects. They form an ecosystem where knowledge flows between them: a control defined in FSI-AgentGov must be accurately referenced by a solution in FSI-AgentGov-Solutions, and may be taught in a lab in copilot-studio-workshop. If you install three completely isolated Squads, each team starts from zero with no awareness of the others. You would have to repeat directives, re-explain relationships, and manually synchronize decisions across all three.

Squad's **Upstream Inheritance** feature solves this problem architecturally [1]. It allows a "child" squad to inherit decisions, skills, and team context from a "parent" squad. When the parent's decisions change, a `squad upstream sync` command propagates those changes downward. This is the same pattern used by Tamir Dresher in his multi-repo Squad deployment, where he maintains a personal squad that feeds knowledge into multiple project-specific squads [2].

### The Topology Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    PERSONAL GLOBAL SQUAD                         │
│                   %APPDATA%\squad\                               │
│                                                                 │
│  decisions.md:  Global coding standards, model preferences      │
│  skills/:       Markdown formatting, PowerShell patterns,       │
│                 MkDocs conventions, control-to-solution mapping  │
│  team.md:       Lead Architect (always present)                 │
└───────────┬─────────────────────┬───────────────────┬───────────┘
            │ upstream sync       │ upstream sync     │ upstream sync
            ▼                     ▼                   ▼
┌───────────────────┐ ┌─────────────────────┐ ┌──────────────────────┐
│  FSI-AgentGov     │ │ FSI-AgentGov-       │ │ copilot-studio-      │
│  c:\dev\...\      │ │ Solutions           │ │ workshop             │
│  .squad/          │ │ c:\dev\...\.squad/  │ │ c:\dev\...\.squad/   │
│                   │ │                     │ │                      │
│ Agents:           │ │ Agents:             │ │ Agents:              │
│ - Compliance      │ │ - PowerShell Expert │ │ - Instructional      │
│   Analyst         │ │ - Solution          │ │   Designer           │
│ - Tech Writer     │ │   Architect         │ │ - Lab QA Tester      │
│ - Assessment Dev  │ │ - Integration       │ │ - Slide Author       │
│ - Scribe          │ │   Tester            │ │ - Scribe             │
│                   │ │ - Scribe            │ │                      │
│ Routing:          │ │                     │ │ Routing:             │
│ docs/controls/** →│ │ Routing:            │ │ workshop/labs/** →   │
│   Compliance      │ │ */.ps1 → PS Expert  │ │   Inst. Designer     │
│ docs/framework/**→│ │ manifest.yaml →     │ │ workshop/tests/** →  │
│   Tech Writer     │ │   Sol. Architect    │ │   Lab QA Tester      │
│ assessment/** →   │ │ */tests/** →        │ │ *.pptx → Slide Auth  │
│   Assessment Dev  │ │   Int. Tester       │ │                      │
└───────────────────┘ └─────────────────────┘ └──────────────────────┘
```

### Can You Run Multiple Squads Simultaneously?

**Yes, absolutely.** Each repository's `.squad/` directory is a self-contained state machine [3]. Squad instances in different repositories do not share processes, memory, or locks. You can run three concurrent Squad sessions without any interference. The approaches for concurrent execution are:

| Method | How It Works | Best For |
|--------|-------------|----------|
| **VS Code Multi-Root Workspace** | One VS Code window with all three repos; Copilot Chat routes to the correct squad based on active file context | Interactive work where you direct agents conversationally |
| **Three Terminal Tabs** | Each tab runs `copilot --agent squad` in a different repo directory | Hands-on CLI work, one repo at a time per tab |
| **Ralph Watch (Autonomous)** | Each tab runs `squad watch --execute`; agents poll GitHub Issues and work unattended | Background autonomous execution while you do other things |
| **Squad Loop** | Each repo has a `loop.md` defining recurring tasks; `squad loop` runs them on a timer | Recurring maintenance (e.g., check for stale docs every hour) |

---

## Part 2: Development Environment Recommendation

### VS Code vs. CLI: Which Should You Use?

**Use VS Code as your primary environment, with CLI for autonomous/background operations.** Here is why:

Squad's documentation explicitly states that VS Code integration works through GitHub Copilot, and the `.squad/` directory works identically in both CLI and VS Code [4]. The advantage of VS Code is that you get:

1. **Visual context switching** between repos in a multi-root workspace.
2. **GitHub Copilot Chat** with the Squad agent selected, giving you a conversational interface to direct your team.
3. **File diff views** when agents propose changes, making review easier.
4. **Integrated terminal** for running `squad watch` or `squad loop` in the background.
5. **Extension ecosystem** for Markdown preview, PowerShell linting, and YAML validation that your agents can leverage.

The CLI remains essential for two scenarios: (a) running `squad watch --execute` as an autonomous background process, and (b) running `squad init`, `squad upstream sync`, `squad doctor`, and other administrative commands.

### Recommended VS Code Setup

Create a workspace file at `c:\dev\FSI-Master.code-workspace`:

```json
{
  "folders": [
    { "path": "FSI-AgentGov", "name": "Framework (Controls)" },
    { "path": "FSI-AgentGov-Solutions", "name": "Solutions (Automation)" },
    { "path": "copilot-studio-workshop", "name": "Workshop (Training)" }
  ],
  "settings": {
    "github.copilot.chat.agent.squad.enabled": true
  }
}
```

When you open this workspace, you can switch between repos by clicking on files in the Explorer panel. GitHub Copilot Chat will automatically detect which `.squad/` context to use based on the active file.

---

## Part 3: Step-by-Step Implementation

### Phase 1: Software Installation

Run these commands in PowerShell (Administrator):

```powershell
# Step 1: Verify Node.js (install from https://nodejs.org if missing)
node --version   # Must be 18+

# Step 2: Install Squad CLI globally
npm install -g @bradygaster/squad-cli

# Step 3: Verify installation
squad --version

# Step 4: Verify GitHub CLI authentication
gh auth status
```

**Checkpoint:** Running `squad --version` should return `0.9.1` or later. If you see "command not found," your npm global bin directory is not in your PATH. Fix with:
```powershell
$env:PATH += ";$(npm config get prefix)"
```

### Phase 2: Create the Personal Global Squad (Hub)

```powershell
# Initialize the global squad
squad init --global
```

This creates your personal squad at `%APPDATA%\squad\`. Now configure it with your cross-repo knowledge:

**Open a Copilot session in the global squad context:**
```powershell
cd $env:APPDATA\squad
copilot --agent squad
```

**Issue these directives to establish your global standards:**

```
Always use Claude Opus for architecture decisions and code generation. Quality is paramount.
```

```
I maintain three interconnected repositories:
1. FSI-AgentGov — A governance framework with 78 controls across 4 pillars for Microsoft 365 AI agents in financial services. Uses MkDocs for documentation.
2. FSI-AgentGov-Solutions — Companion automation solutions (36 solutions) that implement the controls from FSI-AgentGov. Uses PowerShell, Python, and YAML manifests.
3. copilot-studio-workshop — A two-day hands-on workshop (26 labs) for building AI agents with Microsoft Copilot Studio.

When a control changes in FSI-AgentGov, the corresponding solution in FSI-AgentGov-Solutions must be updated. When either changes, the workshop may need updating if it teaches that control or solution.
```

```
Always use PowerShell 7+ syntax. Never use legacy Windows PowerShell patterns.
```

```
All Markdown files must use reference-style links. Never use inline links in documentation.
```

```
Never commit directly to main. Always create a feature branch and submit a PR.
```

**Checkpoint:** Run `cat %APPDATA%\squad\decisions.md` and verify your directives appear.

### Phase 3: Initialize FSI-AgentGov Squad

```powershell
cd c:\dev\FSI-AgentGov
squad init
```

When Squad proposes a team, guide it with this description:

```
This is a governance framework documentation repository. It contains 78 controls
across 4 pillars (Security, Management, Reporting, SharePoint) for Microsoft 365
AI agents in US financial services. The primary work is:
- Writing and updating control documentation in docs/controls/
- Maintaining the MkDocs site structure (mkdocs.yml, docs/)
- Building assessment scripts in assessment/ (PowerShell collectors, Python scoring)
- Mapping controls to regulatory requirements (FINRA, SEC, OCC, CFTC)

I need specialists in: regulatory compliance writing, MkDocs documentation,
Python/PowerShell assessment tooling, and technical architecture.
```

**After the team is proposed and confirmed, link to the global upstream:**

```powershell
squad upstream add global
```

**Set repo-specific directives:**

```
All control files follow the naming pattern: {pillar-number}.{control-number}-{slug}.md
Example: 1.14-data-minimization-and-agent-scope-control.md
```

```
The MkDocs nav structure in mkdocs.yml must always match the actual file structure in docs/.
Never add a nav entry without creating the corresponding file.
```

```
Assessment scripts in assessment/collectors/ use the naming pattern Collect-{Source}.ps1.
The scoring engine in assessment/engine/ uses Python. Never mix languages within a single module.
```

**Configure routing rules** by editing `.squad/routing.md`:

```markdown
# Routing Rules

**Control documentation** (docs/controls/**) → Compliance Analyst
**Framework documentation** (docs/framework/**) → Tech Writer
**MkDocs configuration** (mkdocs.yml, overrides/**) → Tech Writer
**Assessment collectors** (assessment/collectors/*.ps1) → Assessment Dev
**Assessment engine** (assessment/engine/*.py) → Assessment Dev
**Assessment tests** (assessment/tests/**) → Assessment Dev
**Architecture decisions** → Lead
**Cross-repo alignment** → Lead
```

**Checkpoint:** Run `squad doctor` to validate the setup integrity.

### Phase 4: Initialize FSI-AgentGov-Solutions Squad

```powershell
cd c:\dev\FSI-AgentGov-Solutions
squad init
```

Guide the team proposal with:

```
This repository contains 36 automation solutions that implement governance controls
from the companion FSI-AgentGov framework. Each solution is a self-contained directory
with a manifest.yaml, README.md, CHANGELOG.md, and PowerShell/Python implementation scripts.

The primary work is:
- Building new solution implementations (PowerShell, Python)
- Maintaining manifest.yaml files that map solutions to control IDs
- Writing deployment guides and changelogs
- Running integration tests

I need specialists in: PowerShell automation, solution architecture/manifest design,
integration testing, and deployment documentation.
```

**Link to global upstream:**

```powershell
squad upstream add global
```

**Set repo-specific directives:**

```
Every solution directory must contain: manifest.yaml, README.md, CHANGELOG.md, and at least one implementation script.
```

```
The manifest.yaml must include: name, version, controlIds (array), description, and prerequisites.
Always validate that controlIds reference valid controls from the FSI-AgentGov framework.
```

```
When creating a new solution, always check the companion FSI-AgentGov repository's
docs/controls/ directory to ensure the control documentation exists and is current.
```

```
Version numbers follow semantic versioning. Increment patch for bug fixes,
minor for new features, major for breaking changes.
```

**Configure routing rules** in `.squad/routing.md`:

```markdown
# Routing Rules

**PowerShell scripts** (*/*.ps1) → PowerShell Expert
**Python scripts** (*/*.py) → PowerShell Expert
**Manifest files** (*/manifest.yaml) → Solution Architect
**README and docs** (*/README.md, */DEPLOYMENT-GUIDE.md) → Solution Architect
**Changelog updates** (*/CHANGELOG.md) → Solution Architect
**Test files** (*/tests/**) → Integration Tester
**Cross-solution wiring** (cross-solution-integration/**) → Lead
**New solution scaffolding** → Solution Architect
```

**Checkpoint:** Run `squad doctor` and verify all agents are registered.

### Phase 5: Initialize copilot-studio-workshop Squad

```powershell
cd c:\dev\copilot-studio-workshop
squad init
```

Guide the team proposal with:

```
This is a two-day hands-on workshop repository for Microsoft Copilot Studio.
It contains 26 labs (lab-00 through lab-25), facilitator guides, participant guides,
PowerPoint slide decks, PDF outputs, and validation tests.

The primary work is:
- Writing and updating lab instructions in workshop/labs/lab-*/README.md
- Maintaining facilitator and participant guides
- Creating and updating PowerPoint presentations
- Running smoke tests and validation checklists
- Ensuring labs follow a consistent format and terminology

I need specialists in: instructional design (lab writing), presentation/slide authoring,
quality assurance (test validation), and workshop facilitation content.
```

**Link to global upstream:**

```powershell
squad upstream add global
```

**Set repo-specific directives:**

```
All lab files must follow the structure: Goal, Prerequisites, Steps (numbered), Checkpoint, Summary.
Never skip the Checkpoint section — participants must be able to verify their progress.
```

```
Lab numbering is sequential and zero-padded: lab-00, lab-01, ... lab-25.
Never renumber existing labs. If inserting a lab, use a suffix like lab-15b.
```

```
The workshop uses the Woodgrove Bank scenario for Day 1 and Woodgrove Lending Hub for Day 2.
All lab examples must reference these fictional organizations, never real companies.
```

```
PowerPoint slides in workshop/Copilot-Studio-Workshop-Slides/ follow the naming pattern:
Module-{NN}-{Title}.pptx. Never rename existing modules.
```

**Configure routing rules** in `.squad/routing.md`:

```markdown
# Routing Rules

**Lab content** (workshop/labs/**) → Instructional Designer
**Facilitator guides** (workshop/facilitator-guide/**) → Instructional Designer
**Participant guides** (workshop/participant-guide/**) → Instructional Designer
**Slide decks** (workshop/Copilot-Studio-Workshop-Slides/**) → Slide Author
**Slide outlines** (workshop/assets/slide-deck-*.md) → Slide Author
**Test files** (workshop/tests/**) → Lab QA Tester
**PDF generation** (workshop/pdf-output/**) → Lab QA Tester
```

**Checkpoint:** Run `squad doctor` and verify setup.

---

## Part 4: Model Configuration

Since you prioritize quality and accuracy over cost and speed, configure all three repos to use premium models. In each repo, tell the Squad:

```
Always use Opus
```

This creates a persistent preference in `.squad/config.json` that survives across sessions [5]. For the specific agent-to-model mapping recommended for your work:

| Agent Role | Recommended Model | Rationale |
|------------|-------------------|-----------|
| Lead / Architect | Claude Opus 4.6 | Architecture decisions require highest reasoning |
| Compliance Analyst | Claude Opus 4.6 | Regulatory accuracy is critical |
| PowerShell Expert | Claude Sonnet 4.6 | Code generation; Sonnet is excellent for implementation |
| Tech Writer | Claude Sonnet 4.6 | Documentation quality; good balance |
| Instructional Designer | Claude Sonnet 4.6 | Structured writing with creativity |
| Scribe | Claude Haiku 4.5 | Mechanical logging; cost-efficient |
| Integration Tester | Claude Sonnet 4.6 | Test code generation |

To set per-agent overrides:
```
Use Opus for the Lead. Use Sonnet for the PowerShell Expert. Use Haiku for the Scribe.
```

---

## Part 5: Daily Workflow Patterns

### Pattern A: Interactive Multi-Repo Session (VS Code)

This is your day-to-day workflow when actively developing.

1. Open `FSI-Master.code-workspace` in VS Code.
2. Open GitHub Copilot Chat (Ctrl+Shift+I or the sidebar icon).
3. Select the **Squad** agent from the agent list.
4. Navigate to the file you want to work on (e.g., a control in FSI-AgentGov).
5. Tell the Squad what you need:
   - *"Update control 1.14 to add the new OCC 2026-13 requirement about data minimization scope."*
6. The Squad's Compliance Analyst agent works on it, proposes changes, and you review.
7. Switch to the Solutions repo (click a file in FSI-AgentGov-Solutions).
8. Tell the Squad:
   - *"The credential-oversharing-detector solution needs to be updated to match the new control 1.14 requirements. Add a data minimization check to the PowerShell script."*
9. The PowerShell Expert agent picks it up.

### Pattern B: Autonomous Background Execution (Ralph Watch)

This is for when you want agents working while you are in meetings or doing other work.

1. Open Windows Terminal.
2. Create three tabs (Ctrl+Shift+T).
3. In each tab, navigate to a repo and start the watch:
   ```powershell
   # Tab 1
   cd c:\dev\FSI-AgentGov
   squad watch --execute --max-concurrent 2

   # Tab 2
   cd c:\dev\FSI-AgentGov-Solutions
   squad watch --execute --max-concurrent 2

   # Tab 3
   cd c:\dev\copilot-studio-workshop
   squad watch --execute --max-concurrent 2
   ```
4. Create GitHub Issues in the respective repos with clear task descriptions.
5. Ralph will poll, triage, and spawn agents to work on each issue.

### Pattern C: Cross-Repo Cascade Update

When a control change cascades across all three repos:

1. **Step 1 — Framework Update:** In FSI-AgentGov, create an issue: *"Add new control 1.28: Agent Output Watermarking. Pillar 1 Security. Requires all enterprise-zone agents to embed provenance metadata in generated content."*
2. **Step 2 — Solution Creation:** After the control is merged, create an issue in FSI-AgentGov-Solutions: *"Create new solution `agent-output-watermarking` implementing control 1.28. Must include manifest.yaml mapping to control 1.28, a PowerShell collector script, and a README."*
3. **Step 3 — Workshop Update:** If relevant, create an issue in copilot-studio-workshop: *"Add a reference to control 1.28 (Agent Output Watermarking) in Lab 18 (Content Moderation) as an advanced governance example."*

Each Squad instance handles its own issue independently, but because they all inherit from the global upstream, they share the same understanding of what control 1.28 means.

---

## Part 6: Upstream Sync Workflow

When you add a new global decision or skill that all repos should inherit:

```powershell
# Navigate to the global squad
cd $env:APPDATA\squad

# Open a session and add the new directive
copilot --agent squad
> "From now on, all solutions must include a THREAT-MODEL.md file."

# Then sync each repo
cd c:\dev\FSI-AgentGov
squad upstream sync

cd c:\dev\FSI-AgentGov-Solutions
squad upstream sync

cd c:\dev\copilot-studio-workshop
squad upstream sync
```

After syncing, each repo's agents will read the updated `decisions.md` (which now includes the global directive) before their next task [6].

---

## Part 7: Skills to Pre-Seed

Skills are reusable knowledge files that agents read before working [7]. Pre-seeding these accelerates your team's effectiveness from day one instead of waiting for agents to "learn" organically.

### Global Skills (in `%APPDATA%\squad\skills\`)

| Skill | Purpose |
|-------|---------|
| `control-solution-mapping/SKILL.md` | How to map a control ID to its solution directory |
| `mkdocs-conventions/SKILL.md` | MkDocs nav structure, Material theme features, admonition syntax |
| `powershell-standards/SKILL.md` | PSScriptAnalyzer rules, module structure, error handling patterns |
| `changelog-format/SKILL.md` | How to write CHANGELOG.md entries (Keep a Changelog format) |
| `git-workflow/SKILL.md` | Branch naming (`feature/`, `fix/`, `docs/`), PR template usage |

### FSI-AgentGov Skills (in `c:\dev\FSI-AgentGov\.squad\skills\`)

| Skill | Purpose |
|-------|---------|
| `control-authoring/SKILL.md` | How to write a control: structure, regulatory references, zone applicability |
| `assessment-collector/SKILL.md` | How to build a PowerShell collector script for the assessment engine |
| `regulatory-mapping/SKILL.md` | How to map FINRA/SEC/OCC/CFTC requirements to control IDs |

### FSI-AgentGov-Solutions Skills (in `c:\dev\FSI-AgentGov-Solutions\.squad\skills\`)

| Skill | Purpose |
|-------|---------|
| `solution-scaffolding/SKILL.md` | How to create a new solution directory with all required files |
| `manifest-authoring/SKILL.md` | YAML manifest schema, required fields, version conventions |
| `deployment-guide/SKILL.md` | How to write a DEPLOYMENT-GUIDE.md with prerequisites and steps |

### copilot-studio-workshop Skills (in `c:\dev\copilot-studio-workshop\.squad\skills\`)

| Skill | Purpose |
|-------|---------|
| `lab-authoring/SKILL.md` | Lab structure template: Goal, Prerequisites, Steps, Checkpoint, Summary |
| `slide-deck-conventions/SKILL.md` | Module naming, slide count targets, speaker notes format |
| `smoke-test-writing/SKILL.md` | How to write environment smoke tests for lab validation |

---

## Part 8: Governance and Safety

### Reviewer Protocol

For your critical repos (FSI-AgentGov and FSI-AgentGov-Solutions), enable the reviewer protocol so that the Lead agent must approve changes before they are committed [8]:

```
Make sure the Lead reviews all changes to control documentation before they are committed.
```

```
Never merge a solution change without the Integration Tester confirming tests pass.
```

If a reviewer rejects work, the original agent is locked out and the task is reassigned or escalated to you. This prevents endless fix-retry loops.

### File-Write Guards

For the workshop repo, protect the PDF outputs and slide decks from accidental modification:

```
Never modify files in workshop/pdf-output/ directly. PDFs are generated from source Markdown.
```

```
Never modify PowerPoint files without explicit user approval. Only propose changes in a summary.
```

### Directives as Guardrails

The directives system is your primary governance mechanism. Key directives to establish:

| Scope | Directive | Why |
|-------|-----------|-----|
| Global | "Never expose API keys, tenant IDs, or secrets in any committed file" | Security |
| Global | "Always run `squad doctor` after major changes to .squad/ files" | Integrity |
| FSI-AgentGov | "Never delete or renumber existing controls. Only add new ones or mark deprecated." | Stability |
| Solutions | "Every solution must pass its own test suite before a PR is created" | Quality |
| Workshop | "All lab steps must be independently verifiable by a participant" | Usability |

---

## Part 9: Maintenance and Health

### Daily Health Check

Run this in each repo periodically (or automate with `squad loop`):

```powershell
squad doctor
squad upstream sync
```

### Periodic Cleanup

Squad's memory grows over time. Use the `nap` command to compress and archive stale state [9]:

```powershell
# Preview what would be cleaned
squad nap --dry-run

# Execute cleanup
squad nap

# Deep cleanup (recursive)
squad nap --deep
```

### Exporting and Backing Up

Export your squad state for backup or sharing:

```powershell
squad export --out c:\dev\backups\fsi-agentgov-squad-backup.json
```

---

## Part 10: Summary of Commands

| Task | Command | Where to Run |
|------|---------|-------------|
| Install Squad | `npm install -g @bradygaster/squad-cli` | Any terminal |
| Create global hub | `squad init --global` | Any terminal |
| Initialize repo squad | `squad init` | Inside repo directory |
| Link to global | `squad upstream add global` | Inside repo directory |
| Sync upstream changes | `squad upstream sync` | Inside repo directory |
| Validate setup | `squad doctor` | Inside repo directory |
| Start interactive session | `copilot --agent squad` | Inside repo directory |
| Start autonomous watch | `squad watch --execute` | Inside repo directory |
| Check status | `squad status` | Inside repo directory |
| Export squad | `squad export` | Inside repo directory |
| Cleanup memory | `squad nap` | Inside repo directory |
| Set model preference | Tell squad: "Always use Opus" | During any session |

---

## References

[1]: https://github.com/tamirdresher/squad-personal-demo "tamirdresher/squad-personal-demo — Multi-repo Squad with upstream inheritance"
[2]: https://tamirdresher.github.io/blog/2026/03/10/organized-by-ai "Organized by AI — How Squad Changed My Daily Workflow"
[3]: https://bradygaster.github.io/squad/docs/concepts/architecture/ "Squad Concepts: Architecture"
[4]: https://bradygaster.github.io/squad/docs/get-started/installation/ "Squad Installation — CLI, VS Code, and SDK"
[5]: https://bradygaster.github.io/squad/docs/features/model-selection/ "Squad Features: Per-Agent Model Selection"
[6]: https://bradygaster.github.io/squad/docs/features/memory/ "Squad Features: Memory System"
[7]: https://bradygaster.github.io/squad/docs/features/skills/ "Squad Features: Skills System"
[8]: https://bradygaster.github.io/squad/docs/concepts/your-team/ "Squad Concepts: Your Team — Reviewer Protocol"
[9]: https://bradygaster.github.io/squad/docs/reference/cli/ "Squad CLI Reference"
