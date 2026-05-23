# Definitive Squad Implementation Plan for Multi-Repository Automation

**Author:** Manus AI  
**Date:** May 23, 2026  
**Squad CLI Version:** v0.9.4  
**VS Code Version:** v1.119+  
**Target Environment:** Windows 11 Cloud PC, GitHub Copilot Enterprise  

---

## Executive Summary

This document provides the definitive, step-by-step implementation plan for deploying the Squad framework across your three repositories. It is grounded in the official Squad documentation [1], the VS Code Agents Window documentation [2], Tamir Dresher's multi-repo patterns [3], and the Gemini Deep Research findings you provided.

The plan answers your core questions:

| Question | Answer |
|----------|--------|
| Can I run multiple Squads at once? | Yes. Each repo's `.squad/` is independent. Run three simultaneously. |
| Should I use VS Code or CLI? | Both. VS Code Agents Window for interactive daytime work. CLI for overnight autonomous execution. |
| One Squad or three? | Three repo-specific Squads + one Personal Global Squad as the upstream hub. |
| Which development environment? | VS Code with the Agents Window is now the recommended primary interface, supplemented by CLI for background/overnight tasks. |
| How do repos share knowledge? | Via Upstream Inheritance + a cross-repo skill that reads adjacent repo files. |

---

## Part 1: Why VS Code Agents Window Is Now the Right Choice

You mentioned you heard VS Code now has an "agent pop out" where you can see all agents. This is the **Agents Window**, introduced in VS Code v1.115 and significantly refined through v1.119. Here is why this changes your workflow:

### What the Agents Window Does

The Agents Window is a dedicated VS Code window built for an **agent-first workflow**. Unlike the traditional editor window (which is code-centric), the Agents Window treats chat and sessions as the primary interface. It provides:

- A **sessions list** grouped by workspace, showing all active agent sessions across your projects
- The ability to **run and track multiple sessions in parallel** without opening each workspace in a separate window
- Shared sessions between the Agents Window and the main VS Code editor (switch freely between them)
- Direct access to **Copilot CLI background sessions** that continue running even when VS Code is closed

### What This Means for You

Previously, to work on three repos simultaneously with Squad, you would need three separate terminal windows running `copilot --agent squad`. Now, the Agents Window gives you a single dashboard where you can see all three repo sessions side-by-side, switch between them, and monitor their progress visually.

### How to Open It

There are three ways to open the Agents Window:

```powershell
# Method 1: From the command line
code --agents

# Method 2: From inside VS Code
# Click the "Open in Agents" button in the title bar
# Or run Command Palette > "Chat: Open Agents Window"

# Method 3: From a browser (any device)
# Navigate to https://insiders.vscode.dev/agents
```

---

## Part 2: The Architecture (Hub-and-Spoke with Dual-Mode Execution)

Your deployment topology uses a **Hub-and-Spoke** pattern combined with **Dual-Mode Execution**:

```
                    ┌─────────────────────────────────┐
                    │   PERSONAL SQUAD (The Hub)       │
                    │   %APPDATA%\squad\               │
                    │                                  │
                    │   - Shared coding standards      │
                    │   - Cross-repo skills            │
                    │   - Global decisions             │
                    │   - Model preferences            │
                    └─────────┬───────────┬────────────┘
                              │           │
              ┌───────────────┼───────────┼───────────────┐
              │               │           │               │
              ▼               ▼           ▼               │
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│  FSI-AgentGov   │ │ FSI-AgentGov-   │ │ copilot-studio- │
│  (Controls)     │ │ Solutions       │ │ workshop        │
│                 │ │ (Automation)    │ │ (Training)      │
│  .squad/        │ │ .squad/         │ │ .squad/         │
│  - Compliance   │ │ - PowerShell    │ │ - Instructional │
│    Analyst      │ │   Expert        │ │   Designer      │
│  - Tech Writer  │ │ - Solution      │ │ - Lab QA Tester │
│  - Assessment   │ │   Architect     │ │ - Slide Author  │
│    Developer    │ │ - Integration   │ │                 │
│                 │ │   Tester        │ │                 │
└─────────────────┘ └─────────────────┘ └─────────────────┘
```

### Why This Topology

The Hub-and-Spoke pattern is recommended because:

1. **Independence:** Each repo's Squad runs autonomously. If one fails or stalls, the others continue unaffected.
2. **Shared Standards:** The Personal Squad (Hub) holds your universal rules (e.g., "always use .env for secrets", "always include comprehensive documentation"). All three repos inherit these via `squad upstream sync`.
3. **Specialization:** Each repo gets purpose-built agents that understand its specific domain (compliance vs. automation vs. training).
4. **Concurrency:** You can run all three simultaneously because each `.squad/` directory is fully independent state.

---

## Part 3: Step-by-Step Implementation

### Phase 1: Environment Preparation (One-Time Setup)

#### Step 1.1: Verify Prerequisites

Open PowerShell on your Windows 11 Cloud PC and verify:

```powershell
# Check Node.js is installed (required for Squad CLI)
node --version
# Expected: v18+ or v22+

# Check npm is available
npm --version

# Check GitHub CLI is authenticated
gh auth status
# Expected: "Logged in to github.com as judeper"

# Check VS Code version
code --version
# Expected: 1.119.0 or higher
```

**Checkpoint:** All four commands return valid output. If Node.js is not installed, install it from https://nodejs.org (LTS version).

#### Step 1.2: Install Squad CLI

```powershell
npm install -g @bradygaster/squad-cli@latest
```

**Checkpoint:** Run `squad --version` and confirm it shows `0.9.4` or later.

#### Step 1.3: Run Squad Doctor

```powershell
squad doctor
```

This diagnostic command checks your setup for common issues (missing dependencies, auth problems, path issues). Fix any warnings it reports before proceeding.

**Checkpoint:** `squad doctor` reports all checks passing.

#### Step 1.4: Install VS Code Extensions

Open VS Code and install these extensions:

| Extension | ID | Purpose |
|-----------|-----|---------|
| GitHub Copilot | `GitHub.copilot` | Core AI assistant |
| GitHub Copilot Chat | `GitHub.copilot-chat` | Chat interface + Agents Window |
| SquadUI | `csharpfritz.squadui` | Visual Squad dashboard |

**Checkpoint:** All three extensions show as installed and enabled.

#### Step 1.5: Enable Parent Repository Discovery

In VS Code Settings (JSON), add:

```json
{
  "chat.useCustomizationsInParentRepositories": true
}
```

This ensures VS Code discovers `.github/agents/squad.agent.md` even if you open a subfolder.

---

### Phase 2: Personal Squad (The Hub)

The Personal Squad is your global upstream that all repos inherit from. It holds decisions and skills that apply everywhere.

#### Step 2.1: Initialize the Global Squad

```powershell
squad init --global
```

This creates the personal squad directory at `%APPDATA%\squad\` (on Windows, typically `C:\Users\<username>\AppData\Roaming\squad\`).

**Checkpoint:** Verify the directory exists:
```powershell
dir $env:APPDATA\squad\.squad\
```

#### Step 2.2: Add Global Decisions

Navigate to the personal squad and add your universal standards:

```powershell
cd $env:APPDATA\squad
```

Create or edit `.squad\decisions.md` with the following content:

```markdown
# Global Decisions (Inherited by All Repositories)

## Coding Standards
- All Python scripts must include comprehensive documentation and use .env files for secrets.
- All PowerShell scripts must include comment-based help and error handling.
- All Markdown documentation must follow MkDocs-compatible formatting.

## Repository Relationships
- FSI-AgentGov contains the authoritative control definitions.
- FSI-AgentGov-Solutions is the companion automation repository for FSI-AgentGov.
- copilot-studio-workshop contains training labs that reference both FSI-AgentGov and FSI-AgentGov-Solutions.
- When a control is updated in FSI-AgentGov, the corresponding solution in FSI-AgentGov-Solutions should be reviewed for impact.
- When either framework repo changes, relevant workshop labs should be flagged for review.

## Quality Gates
- No PR should be merged without passing all existing tests.
- Documentation updates must accompany any functional changes.
- All automation scripts must be tested before delivery.
```

**Checkpoint:** The file exists and contains your standards.

#### Step 2.3: Add Global Skills

Create a skill that any repo can use to understand the cross-repo relationship:

Create file `%APPDATA%\squad\.squad\skills\repo-map.md`:

```markdown
# Skill: Repository Map

## Description
Provides context about the multi-repository ecosystem and how repos relate to each other.

## Knowledge
The operator maintains three interconnected repositories, all cloned under C:\dev\:

1. **C:\dev\FSI-AgentGov** — The governance framework containing control definitions, regulatory mappings, and compliance documentation. Uses MkDocs for its documentation site.

2. **C:\dev\FSI-AgentGov-Solutions** — The companion automation repository. Contains Power Platform solutions, deployment scripts, and PAC CLI automation that implements the controls defined in FSI-AgentGov.

3. **C:\dev\copilot-studio-workshop** — A training and workshop development repository. Contains labs, lab steps, slides, and sample code for customer workshops. Some labs reference controls and solutions from the other two repos.

## Cross-Reference Rules
- When asked about a "control," check C:\dev\FSI-AgentGov\docs\ for the authoritative definition.
- When asked about "automating a control," check C:\dev\FSI-AgentGov-Solutions\ for existing solutions.
- When asked about "teaching" or "labs," check C:\dev\copilot-studio-workshop\workshops\ for existing content.
```

---

### Phase 3: Repository-Specific Squads (The Spokes)

#### Repository 1: FSI-AgentGov (The Controls Framework)

```powershell
cd C:\dev\FSI-AgentGov
squad init
```

When Squad asks "What are you building?", respond with:

> "A financial services governance framework containing regulatory control definitions, compliance documentation, and assessment logic. The stack is MkDocs for documentation, Markdown for control definitions, and YAML for metadata. The repo serves as the authoritative source of truth for all FSI compliance controls."

After the team is proposed, link to your global upstream:

```powershell
squad upstream add global
squad upstream sync
```

**Checkpoint:** Run `squad status` and confirm it shows the team and upstream link.

**Recommended Agent Roles for This Repo:**

| Agent Role | Responsibility | Routing Trigger |
|-----------|---------------|-----------------|
| Compliance Analyst | Control definitions, regulatory mappings, gap analysis | Keywords: "control", "regulation", "compliance", "mapping" |
| Tech Writer | MkDocs site structure, formatting, navigation, cross-references | Keywords: "docs", "site", "page", "format", "navigation" |
| Assessment Developer | Assessment questions, scoring logic, validation rules | Keywords: "assessment", "question", "score", "validate" |

#### Repository 2: FSI-AgentGov-Solutions (The Automation)

```powershell
cd C:\dev\FSI-AgentGov-Solutions
squad init
```

When Squad asks "What are you building?", respond with:

> "A companion automation repository for FSI-AgentGov. Contains Power Platform solutions, PowerShell deployment scripts, and PAC CLI automation that implements governance controls in bulk. The stack is PowerShell, Power Platform, and YAML for solution metadata."

Link to upstream:

```powershell
squad upstream add global
squad upstream sync
```

**Checkpoint:** Run `squad status` and confirm.

**Recommended Agent Roles for This Repo:**

| Agent Role | Responsibility | Routing Trigger |
|-----------|---------------|-----------------|
| PowerShell Expert | Deployment scripts, PAC CLI automation, bulk operations | Keywords: "script", "deploy", "PAC", "PowerShell", "automate" |
| Solution Architect | Power Platform solution design, data models, entity relationships | Keywords: "solution", "design", "model", "entity", "architecture" |
| Integration Tester | Validates deployments, tests API connections, verifies automation output | Keywords: "test", "validate", "verify", "integration" |

#### Repository 3: copilot-studio-workshop (The Training)

```powershell
cd C:\dev\copilot-studio-workshop
squad init
```

When Squad asks "What are you building?", respond with:

> "A workshop development repository for customer training. Contains lab documents with step-by-step instructions, slide content, sample code, and configuration files. Labs teach developers how to build with Microsoft Copilot Studio. The format is Markdown labs with numbered steps, expected outputs, and validation checkpoints."

Link to upstream:

```powershell
squad upstream add global
squad upstream sync
```

**Checkpoint:** Run `squad status` and confirm.

**Recommended Agent Roles for This Repo:**

| Agent Role | Responsibility | Routing Trigger |
|-----------|---------------|-----------------|
| Instructional Designer | Lab structure, learning objectives, step sequencing, difficulty progression | Keywords: "lab", "step", "objective", "learning", "structure" |
| Lab QA Tester | Validates that lab instructions actually work, checks for missing steps | Keywords: "test", "validate", "broken", "fix", "verify" |
| Slide Author | Generates presentation content, talking points, demo scripts | Keywords: "slide", "presentation", "demo", "talk", "content" |

---

### Phase 4: Cross-Repo Knowledge Sharing

#### The Cross-Repo Skill (Solutions reads from Controls)

Create this skill in the Solutions repo so its agents can look up control definitions from the Framework repo:

**File:** `C:\dev\FSI-AgentGov-Solutions\.squad\skills\read-controls.md`

```markdown
# Skill: Read Controls from FSI-AgentGov

## Description
Allows agents in this repository to read and reference control definitions from the companion FSI-AgentGov repository.

## Instructions
When you need to understand a control definition, read the corresponding file from C:\dev\FSI-AgentGov\docs\. The controls are organized as Markdown files with YAML frontmatter containing metadata like control ID, category, and regulatory mapping.

## Usage
When implementing automation for a specific control:
1. First read the control definition from C:\dev\FSI-AgentGov\docs\controls\
2. Identify the control requirements and acceptance criteria
3. Then implement the automation in this repository that satisfies those requirements
4. Reference the control ID in your solution's metadata

## File Locations
- Control definitions: C:\dev\FSI-AgentGov\docs\controls\
- Regulatory mappings: C:\dev\FSI-AgentGov\docs\mappings\
- Assessment logic: C:\dev\FSI-AgentGov\docs\assessments\
```

#### The Cross-Repo Skill (Workshop reads from both)

**File:** `C:\dev\copilot-studio-workshop\.squad\skills\read-framework.md`

```markdown
# Skill: Read Framework and Solutions

## Description
Allows agents in this repository to reference the FSI-AgentGov framework and its companion solutions repository when building workshop labs.

## Instructions
When creating or updating labs that reference governance controls or automation:
1. Read control definitions from C:\dev\FSI-AgentGov\docs\
2. Read solution implementations from C:\dev\FSI-AgentGov-Solutions\
3. Ensure lab instructions accurately reflect the current state of both repos

## File Locations
- Framework controls: C:\dev\FSI-AgentGov\docs\controls\
- Framework site config: C:\dev\FSI-AgentGov\mkdocs.yml
- Solutions scripts: C:\dev\FSI-AgentGov-Solutions\solutions\
- Solutions deployment: C:\dev\FSI-AgentGov-Solutions\scripts\
```

---

### Phase 5: VS Code Workspace Configuration

#### Step 5.1: Create the Multi-Root Workspace

Create a workspace file at `C:\dev\fsi-workspace.code-workspace`:

```json
{
  "folders": [
    { "path": "FSI-AgentGov", "name": "Controls (FSI-AgentGov)" },
    { "path": "FSI-AgentGov-Solutions", "name": "Automation (Solutions)" },
    { "path": "copilot-studio-workshop", "name": "Workshop (Training)" }
  ],
  "settings": {
    "chat.useCustomizationsInParentRepositories": true
  }
}
```

Open this workspace:
```powershell
code C:\dev\fsi-workspace.code-workspace
```

#### Step 5.2: Open the Agents Window

Once the workspace is open, click the **"Open in Agents"** button in the VS Code title bar (or press `Ctrl+Shift+P` and run "Chat: Open Agents Window").

You will see the Agents Window with your three workspaces listed in the sidebar. Each workspace can have independent chat sessions running simultaneously.

#### Step 5.3: Start Parallel Sessions

In the Agents Window:

1. Hover over "Controls (FSI-AgentGov)" in the sessions list and click **+** (New Session).
2. Select **Copilot CLI** as the agent type.
3. Type your prompt (e.g., "Review the controls directory and identify any controls missing MkDocs pages").
4. While that session runs, hover over "Automation (Solutions)" and click **+** to start a second session.
5. Both sessions run in parallel, each with their own Squad team.

---

### Phase 6: Overnight Autonomous Execution

This is the critical section for your "run overnight" requirement.

#### Option A: Squad Watch (Issue-Driven Automation)

Squad Watch (Ralph) polls for GitHub Issues and automatically dispatches agents to work on them. This is ideal for overnight batch processing.

**Setup:**

1. Create GitHub Issues in each repo describing the work you want done overnight.
2. Label them appropriately (e.g., `squad-ready`, `priority-high`).
3. Start Ralph Watch:

```powershell
# Terminal 1: FSI-AgentGov
cd C:\dev\FSI-AgentGov
squad watch --execute --interval 5 --agent-cmd "copilot" --copilot-flags "--agent squad --yolo" --log-file ./watch-log.txt --state-backend git-notes
```

```powershell
# Terminal 2: FSI-AgentGov-Solutions
cd C:\dev\FSI-AgentGov-Solutions
squad watch --execute --interval 5 --agent-cmd "copilot" --copilot-flags "--agent squad --yolo" --log-file ./watch-log.txt --state-backend git-notes
```

```powershell
# Terminal 3: copilot-studio-workshop
cd C:\dev\copilot-studio-workshop
squad watch --execute --interval 5 --agent-cmd "copilot" --copilot-flags "--agent squad --yolo" --log-file ./watch-log.txt --state-backend git-notes
```

**Key Flags Explained:**

| Flag | Purpose |
|------|---------|
| `--execute` | Actually dispatch agents (without this, Ralph only triages) |
| `--interval 5` | Poll every 5 minutes for new issues |
| `--agent-cmd "copilot"` | Use GitHub Copilot CLI as the agent runner |
| `--copilot-flags "--agent squad --yolo"` | Pass Squad agent selection and auto-approve all tool calls |
| `--log-file ./watch-log.txt` | Write diagnostic output to a file for morning review |
| `--state-backend git-notes` | Persist watch state across restarts (survives crashes) |

**Graceful Shutdown (in the morning):**
```powershell
# Create the sentinel file to signal Ralph to stop after current task
touch C:\dev\FSI-AgentGov\.squad\ralph-stop
```

#### Option B: Squad Start with Remote Tunnel (Direct Monitoring)

For more interactive overnight work where you want to check in from your phone:

```powershell
cd C:\dev\FSI-AgentGov
squad start --tunnel --yolo
```

This spawns a Copilot CLI session with a DevTunnel URL. You can scan the QR code with your phone to see the live terminal output and even send commands from your mobile browser. The tunnel is secured via your Microsoft/GitHub identity — no one else can access it.

#### Option C: Copilot CLI Background Sessions via VS Code

The newest approach (VS Code 1.119):

1. Open the Agents Window.
2. Start a new session in any workspace.
3. Select **Copilot CLI** as the agent type.
4. Choose **Worktree** isolation (creates a separate Git worktree so your main branch is protected).
5. Submit your prompt.
6. **Close VS Code.** The Copilot CLI session continues running in the background.
7. Reopen VS Code later to check the session status and review changes.

You can also enable **Remote Control** within the session by typing `/remote on`. This allows you to monitor and interact with the session from github.com or the GitHub Mobile app.

---

### Phase 7: Model Configuration

For your requirement of "accuracy and quality paramount, speed secondary," configure each repo to use the best available model:

```powershell
# In each repo directory:
squad config model --set claude-sonnet-4
```

Alternatively, if you prefer GPT-4.1 for certain repos:

```powershell
squad config model --set gpt-4.1
```

The model selection is stored in `.squad/config.json` and applies to all agents in that repo.

---

### Phase 8: Governance and Safety

Since you will be running these overnight unattended, safety guardrails are critical.

#### Worktree Isolation (Recommended for Overnight)

Always use worktree isolation for overnight sessions. This means:
- The agent works on a separate Git worktree (a copy of your branch in a different folder).
- All changes are isolated from your main working directory.
- In the morning, you review the worktree's changes and merge what you approve.

#### The Reviewer Protocol

Squad includes a built-in reviewer protocol. Before any agent commits or creates a PR, the "Lead" agent reviews the changes. This provides a layer of automated quality control even when you are not present.

#### Circuit Breaker (Built into Watch)

Ralph Watch includes a 4-tier escalation strategy:
1. **Tier 1:** Circuit breaker reset (clear and retry)
2. **Tier 2:** Auth reprobe (re-verify credentials)
3. **Tier 3:** Git pull (update local state)
4. **Tier 4:** Pause 30 minutes (back off for human intervention)

This prevents the system from repeatedly failing on the same error overnight.

---

## Part 4: The Cascade Update Pattern

This is how you handle the scenario where updating a control in FSI-AgentGov requires corresponding updates in the other repos.

### Manual Cascade (Daytime, Interactive)

1. In the Agents Window, start a session in FSI-AgentGov: "Update control AC-01 to include the new regulatory requirement from DORA."
2. Once complete, start a session in FSI-AgentGov-Solutions: "The control AC-01 in FSI-AgentGov was just updated. Review the corresponding solution and update it to match the new requirements. Read the control from C:\dev\FSI-AgentGov\docs\controls\AC-01.md."
3. Then in copilot-studio-workshop: "Control AC-01 and its solution were updated. Check if any workshop labs reference this control and flag them for review."

### Automated Cascade (Overnight, via Issues)

1. Create a GitHub Issue in FSI-AgentGov: "Update control AC-01 for DORA compliance."
2. Create a linked Issue in FSI-AgentGov-Solutions: "After FSI-AgentGov#42 is complete, update the AC-01 solution to match."
3. Create a linked Issue in copilot-studio-workshop: "After Solutions#15 is complete, review Lab 3 for AC-01 accuracy."
4. Start Ralph Watch in all three repos. Ralph will process them in sequence based on dependencies.

---

## Part 5: Maintenance Commands

These commands will be part of your regular workflow:

| Command | When to Use | What It Does |
|---------|-------------|--------------|
| `squad upstream sync` | Weekly, or after updating global decisions | Pulls latest decisions/skills from Personal Squad into the repo |
| `squad nap` | When `.squad/` gets large | Compresses memory, archives old decisions, prunes stale state |
| `squad nap --deep` | Monthly | Aggressive compression for long-running projects |
| `squad upgrade` | When a new Squad version is released | Updates `squad.agent.md` and templates without touching your team state |
| `squad doctor` | When something seems wrong | Diagnoses setup issues and suggests fixes |
| `squad export` | Before major changes | Creates a portable JSON snapshot of your entire squad state |
| `squad watch --health` | To check overnight status | Shows PID, uptime, last poll, auth status |

---

## Part 6: What to Commit to Git

Each repo will have new `.squad/` and `.github/agents/` directories. Here is what should be committed vs. ignored:

| Path | Commit? | Reason |
|------|---------|--------|
| `.github/agents/squad.agent.md` | Yes | The agent definition that Copilot discovers |
| `.squad/team.md` | Yes | Team roster (so the team persists across clones) |
| `.squad/decisions.md` | Yes | Shared decisions (part of project knowledge) |
| `.squad/routing.md` | Yes | Routing rules |
| `.squad/skills/` | Yes | Custom skills |
| `.squad/memory/` | Optional | Session memory (can be large; consider .gitignore) |
| `.squad/scratch/` | No (.gitignore) | Temporary working files |
| `watch-log.txt` | No (.gitignore) | Diagnostic logs |

Add to each repo's `.gitignore`:
```
.squad/scratch/
.squad/ralph-stop
watch-log.txt
```

---

## Part 7: Rollout Checklist

Complete these in order. Each step has a checkpoint to confirm success.

| Phase | Step | Command / Action | Checkpoint |
|-------|------|-----------------|------------|
| 1 | Verify Node.js | `node --version` | Shows v18+ |
| 1 | Install Squad CLI | `npm install -g @bradygaster/squad-cli@latest` | `squad --version` shows 0.9.4+ |
| 1 | Run diagnostics | `squad doctor` | All checks pass |
| 1 | Install VS Code extensions | Install Copilot, Copilot Chat, SquadUI | All show enabled |
| 2 | Init Personal Squad | `squad init --global` | `%APPDATA%\squad\.squad\` exists |
| 2 | Add global decisions | Edit `decisions.md` | File contains your standards |
| 2 | Add repo-map skill | Create `skills\repo-map.md` | File exists in personal squad |
| 3 | Init FSI-AgentGov | `cd C:\dev\FSI-AgentGov && squad init` | `.squad\team.md` exists |
| 3 | Link to upstream | `squad upstream add global` | `squad status` shows upstream |
| 3 | Init Solutions | `cd C:\dev\FSI-AgentGov-Solutions && squad init` | `.squad\team.md` exists |
| 3 | Link to upstream | `squad upstream add global` | `squad status` shows upstream |
| 3 | Init Workshop | `cd C:\dev\copilot-studio-workshop && squad init` | `.squad\team.md` exists |
| 3 | Link to upstream | `squad upstream add global` | `squad status` shows upstream |
| 4 | Add cross-repo skill (Solutions) | Create `read-controls.md` | File exists in `.squad\skills\` |
| 4 | Add cross-repo skill (Workshop) | Create `read-framework.md` | File exists in `.squad\skills\` |
| 5 | Create workspace file | Create `fsi-workspace.code-workspace` | Opens all 3 repos in VS Code |
| 5 | Test Agents Window | Open Agents Window, start a session | Session appears in sidebar |
| 5 | Test parallel sessions | Start sessions in 2+ repos | Both run simultaneously |
| 6 | Test overnight watch | `squad watch --execute` in one repo | Ralph processes an issue |
| 6 | Test remote tunnel | `squad start --tunnel --yolo` | QR code appears, phone connects |
| 7 | Configure model | `squad config model --set claude-sonnet-4` | Model confirmed in config |
| 7 | Commit Squad files | `git add .squad/ .github/agents/ && git commit` | Files tracked in Git |

---

## Part 8: Answers to Your Specific Questions

### "Can I only run one Squad at a time?"

No. You can run as many as you want simultaneously. Each repo has its own independent `.squad/` directory, which means each terminal window or VS Code session operates on completely separate state. There is no global lock or shared resource between them.

### "I would like to run two or three Squads at a time"

This is fully supported. Your three options for concurrent execution:

1. **Three PowerShell terminals** (one per repo, each running `copilot --agent squad --yolo`)
2. **VS Code Agents Window** (start sessions in each workspace from the same window)
3. **Three Ralph Watch processes** (one per repo, for overnight unattended work)

### "Should I install it within the repository itself?"

Yes. Each repo gets its own `squad init`. The `.squad/` directory and `.github/agents/squad.agent.md` file live inside the repo and should be committed. This means anyone who clones the repo (or your future self on a different machine) gets the same team configuration.

### "Maybe I'll have a main one?"

Yes, that is the Personal Squad (`squad init --global`). It serves as the "main" upstream that all repos inherit from. But it does not replace the per-repo squads — it supplements them with shared knowledge.

### "Will I be able to see the agents running?"

Yes. In the VS Code Agents Window, you see:
- Active sessions listed in the sidebar
- Real-time chat output showing which agent is working
- The SquadUI extension shows the team roster, active tasks, and decisions in a dedicated sidebar panel

---

## References

[1]: https://bradygaster.github.io/squad/ "Squad Official Documentation"
[2]: https://code.visualstudio.com/docs/copilot/agents/agents-window "VS Code Agents Window Documentation"
[3]: https://tamirdresher.github.io/blog/2026/02/17/trying-squad-without-touching-your-repo "Tamir Dresher: Trying Squad Without Touching Your Repo"
[4]: https://tamirdresher.github.io/blog/2026/02/26/squad-remote-control "Tamir Dresher: Squad Remote Control from Phone"
[5]: https://github.com/bradygaster/squad/releases "Squad CLI Releases"
[6]: https://code.visualstudio.com/docs/copilot/agents/copilot-cli "VS Code Copilot CLI Sessions Documentation"
