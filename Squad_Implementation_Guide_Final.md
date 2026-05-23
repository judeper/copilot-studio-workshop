# Squad Multi-Repository Implementation Guide

**Author:** Manus AI  
**Date:** May 23, 2026  
**For:** Jude Pereira, Principal CSA — FSI  
**Environment:** Windows 11 Cloud PC, GitHub Copilot Enterprise, VS Code v1.121+  

---

## What This Guide Covers

This is the authoritative implementation guide for deploying the Squad framework across three interconnected repositories. It uses only verified commands and production-ready tools. Every command in this document has been validated against official documentation.

**Repositories:**

| Repository | Purpose | Type |
|-----------|---------|------|
| `FSI-AgentGov` | Governance controls, regulatory mappings, compliance documentation | Framework (source of truth) |
| `FSI-AgentGov-Solutions` | Power Platform solutions, deployment scripts, PAC CLI automation | Companion automation |
| `copilot-studio-workshop` | Workshop labs, slides, sample code for customer training | Training delivery |

**Tools Used:**

| Tool | Role | Maturity |
|------|------|----------|
| Squad CLI v0.9.4 | Team definition, routing, context sharing, upstream inheritance | Alpha (use verified features only) |
| VS Code Agents Window | Daytime interactive parallel sessions | Preview (Stable since v1.120) |
| GitHub Copilot Coding Agent | Overnight autonomous execution via GitHub Issues | GA (production-ready since March 2026) |
| SquadUI Extension | Visual dashboard for Squad state | Stable |

---

## Architecture: Hub-and-Spoke

```
                ┌────────────────────────────────────┐
                │       PERSONAL SQUAD (Hub)          │
                │   %APPDATA%\squad\.squad\           │
                │                                    │
                │   Shared coding standards          │
                │   Cross-repo context (repo-map)    │
                │   Global decisions                 │
                └──────┬──────────┬──────────┬───────┘
                       │          │          │
                       ▼          ▼          ▼
              ┌────────────┐ ┌────────────┐ ┌────────────┐
              │FSI-AgentGov│ │Solutions   │ │Workshop    │
              │            │ │            │ │            │
              │.squad/     │ │.squad/     │ │.squad/     │
              │Compliance  │ │PowerShell  │ │Instructional│
              │Analyst     │ │Expert      │ │Designer    │
              │Tech Writer │ │Solution    │ │Lab QA      │
              │Assessment  │ │Architect   │ │Tester      │
              │Developer   │ │Integration │ │Slide Author│
              │            │ │Tester      │ │            │
              └────────────┘ └────────────┘ └────────────┘
```

The Personal Squad holds shared standards that all three repos inherit. Each repo has its own specialized team. They operate independently but share context through upstream inheritance.

---

## Phase 1: Environment Setup

### Step 1.1: Verify Prerequisites

Open PowerShell on your Cloud PC:

```powershell
node --version          # Expect v18+ or v22+
npm --version           # Expect 10+
gh auth status          # Expect "Logged in to github.com as judeper"
code --version          # Expect 1.121.0 or higher
```

**Checkpoint:** All four commands return valid output. If Node.js is missing, install from https://nodejs.org (LTS).

### Step 1.2: Install Squad CLI

```powershell
npm install -g @bradygaster/squad-cli@latest
```

**Checkpoint:** Run `squad --version` — expect `0.9.4` or later.

### Step 1.3: Run Squad Doctor

```powershell
squad doctor
```

This validates your environment for common issues (missing dependencies, auth problems, path issues). Fix any warnings before proceeding.

**Checkpoint:** All checks pass.

### Step 1.4: Install VS Code Extensions

In VS Code, install:

| Extension | ID | Purpose |
|-----------|-----|---------|
| GitHub Copilot | `GitHub.copilot` | Core AI assistant |
| GitHub Copilot Chat | `GitHub.copilot-chat` | Chat interface + Agents Window |
| SquadUI | `csharpfritz.squadui` | Visual Squad dashboard in sidebar |

**Checkpoint:** All three extensions installed and enabled.

### Step 1.5: Enable Parent Repository Discovery

In VS Code Settings (JSON), add:

```json
{
  "chat.useCustomizationsInParentRepositories": true
}
```

---

## Phase 2: Personal Squad (The Hub)

The Personal Squad is your global upstream. All repos inherit from it.

### Step 2.1: Initialize

```powershell
squad init --global
```

This creates the personal squad at `%APPDATA%\squad\`.

**Checkpoint:** Verify:
```powershell
Test-Path "$env:APPDATA\squad\.squad"
# Expected: True
```

### Step 2.2: Add Global Decisions

Create the file `%APPDATA%\squad\.squad\decisions.md`:

```powershell
notepad "$env:APPDATA\squad\.squad\decisions.md"
```

Paste the following content:

```markdown
# Global Decisions (Inherited by All Repositories)

## Coding Standards
- All Python scripts must include comprehensive documentation and use .env files for secrets.
- All PowerShell scripts must include comment-based help and error handling.
- All Markdown documentation must follow MkDocs-compatible formatting.
- Use consistent YAML frontmatter for metadata across all repos.

## Repository Relationships
- FSI-AgentGov contains the authoritative control definitions.
- FSI-AgentGov-Solutions is the companion automation repository for FSI-AgentGov.
- copilot-studio-workshop contains training labs that reference both FSI-AgentGov and FSI-AgentGov-Solutions.
- When a control is updated in FSI-AgentGov, the corresponding solution in FSI-AgentGov-Solutions should be reviewed for impact.
- When either framework repo changes, relevant workshop labs should be flagged for review.

## Quality Gates
- No PR should be merged without review.
- Documentation updates must accompany any functional changes.
- All automation scripts must be tested before delivery.
```

### Step 2.3: Add Global Skill (Repo Map)

Create the file `%APPDATA%\squad\.squad\skills\repo-map.md`:

```markdown
# Skill: Repository Map

## Description
Provides context about the multi-repository ecosystem and how repos relate to each other.

## Knowledge
The operator maintains three interconnected repositories, all cloned under C:\dev\:

1. **C:\dev\FSI-AgentGov** — The governance framework containing control definitions, regulatory mappings, and compliance documentation. Uses MkDocs for its documentation site.

2. **C:\dev\FSI-AgentGov-Solutions** — The companion automation repository. Contains Power Platform solutions, deployment scripts, and PAC CLI automation that implements the controls defined in FSI-AgentGov.

3. **C:\dev\copilot-studio-workshop** — A training and workshop development repository. Contains labs, lab steps, slides, and sample code for customer workshops.

## Cross-Reference Rules
- When asked about a "control," check C:\dev\FSI-AgentGov\docs\ for the authoritative definition.
- When asked about "automating a control," check C:\dev\FSI-AgentGov-Solutions\ for existing solutions.
- When asked about "teaching" or "labs," check C:\dev\copilot-studio-workshop\workshops\ for existing content.
```

**Checkpoint:** Both files exist in `%APPDATA%\squad\.squad\`.

---

## Phase 3: Per-Repository Squad Setup

### Repository 1: FSI-AgentGov (Controls)

```powershell
cd C:\dev\FSI-AgentGov
squad init
```

When Squad asks what you are building, respond:

> A financial services governance framework containing regulatory control definitions, compliance documentation, and assessment logic. The stack is MkDocs for documentation, Markdown for control definitions, and YAML for metadata. This repo is the authoritative source of truth for all FSI compliance controls.

After the team is proposed, link to the upstream hub:

```powershell
squad upstream add "$env:APPDATA\squad\.squad"
squad upstream sync
```

**Checkpoint:** Run `squad status` — confirm team and upstream link appear.

Now create the routing rules. Edit `.squad\routing.md`:

```markdown
# FSI-AgentGov Routing Rules

## Compliance Analyst
Handles control definitions, regulatory mappings, gap analysis, and compliance language.
Routes on: control, regulation, compliance, mapping, DORA, requirement

## Tech Writer
Manages the MkDocs site, formatting, structural consistency, navigation, and cross-references.
Routes on: docs, site, page, format, navigation, mkdocs, structure

## Assessment Developer
Builds assessment questions, scoring logic, and validation rules.
Routes on: assessment, question, score, validate, test, evaluate
```

### Repository 2: FSI-AgentGov-Solutions (Automation)

```powershell
cd C:\dev\FSI-AgentGov-Solutions
squad init
```

When Squad asks what you are building, respond:

> A companion automation repository for FSI-AgentGov. Contains Power Platform solutions, PowerShell deployment scripts, and PAC CLI automation that implements governance controls in bulk. The stack is PowerShell, Power Platform, and YAML for solution metadata.

Link to upstream:

```powershell
squad upstream add "$env:APPDATA\squad\.squad"
squad upstream sync
```

**Checkpoint:** Run `squad status` — confirm team and upstream link appear.

Edit `.squad\routing.md`:

```markdown
# FSI-AgentGov-Solutions Routing Rules

## PowerShell Expert
Writes deployment scripts, PAC CLI automation, and bulk operations.
Routes on: script, deploy, PAC, PowerShell, automate, bulk

## Solution Architect
Designs Power Platform solutions, data models, and entity relationships.
Routes on: solution, design, model, entity, architecture, Dataverse

## Integration Tester
Validates deployments, tests API connections, and verifies automation output.
Routes on: test, validate, verify, integration, connection, API
```

Add the cross-repo skill. Create `.squad\skills\read-controls.md`:

```markdown
# Skill: Read Controls from FSI-AgentGov

## Description
Allows agents in this repository to read and reference control definitions from the companion FSI-AgentGov repository.

## Instructions
When implementing automation for a specific control:
1. Read the control definition from C:\dev\FSI-AgentGov\docs\controls\
2. Identify the control requirements and acceptance criteria
3. Implement the automation in this repository that satisfies those requirements
4. Reference the control ID in your solution's metadata

## File Locations
- Control definitions: C:\dev\FSI-AgentGov\docs\controls\
- Regulatory mappings: C:\dev\FSI-AgentGov\docs\mappings\
- Assessment logic: C:\dev\FSI-AgentGov\docs\assessments\
```

### Repository 3: copilot-studio-workshop (Training)

```powershell
cd C:\dev\copilot-studio-workshop
squad init
```

When Squad asks what you are building, respond:

> A workshop development repository for customer training. Contains lab documents with step-by-step instructions, slide content, sample code, and configuration files. Labs teach developers how to build with Microsoft Copilot Studio. The format is Markdown labs with numbered steps, expected outputs, and validation checkpoints.

Link to upstream:

```powershell
squad upstream add "$env:APPDATA\squad\.squad"
squad upstream sync
```

**Checkpoint:** Run `squad status` — confirm team and upstream link appear.

Edit `.squad\routing.md`:

```markdown
# Workshop Routing Rules

## Instructional Designer
Structures lab steps, learning objectives, step sequencing, and difficulty progression.
Routes on: lab, step, objective, learning, structure, curriculum

## Lab QA Tester
Validates that lab instructions actually work, checks for missing steps, and identifies broken references.
Routes on: test, validate, broken, fix, verify, check

## Slide Author
Generates presentation content, talking points, and demo scripts.
Routes on: slide, presentation, demo, talk, content, deck
```

Add the cross-repo skill. Create `.squad\skills\read-framework.md`:

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

## Phase 4: VS Code Workspace (Daytime Interactive Work)

### Step 4.1: Create the Multi-Root Workspace

Create the file `C:\dev\fsi-workspace.code-workspace`:

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

Open it:
```powershell
code C:\dev\fsi-workspace.code-workspace
```

### Step 4.2: Open the Agents Window

From inside VS Code, click the **"Open in Agents"** button in the title bar. Or use the Command Palette: `Chat: Open Agents Window`. Or from the terminal: `code --agents`.

The Agents Window shows a sessions list grouped by workspace. You will see your three repos listed.

### Step 4.3: Start Parallel Sessions

In the Agents Window:

1. Hover over "Controls (FSI-AgentGov)" and click **+** (New Session).
2. Select **Copilot CLI** as the agent type.
3. Choose **Worktree** isolation (recommended — keeps changes on a separate branch).
4. Type your prompt. The Squad team will be engaged automatically via the `.github/agents/squad.agent.md` file.
5. While that session runs, start another session in "Automation (Solutions)" by clicking **+** on that workspace.

Both sessions run in parallel. Each has its own Squad team with repo-specific routing.

### Step 4.4: Remote Control (Optional)

If you need to step away from your desk but want to monitor a running session:

1. In the active Copilot CLI session, type `/remote on`.
2. This enables remote control via GitHub.com or the GitHub Mobile app.
3. The session continues running even if you close VS Code.
4. Check in from your phone via GitHub Mobile.

**Important:** Only remote-controlled sessions persist after VS Code is closed. Standard local sessions do not.

---

## Phase 5: Overnight Autonomous Execution (GitHub Copilot Coding Agent)

This is the production-ready approach for overnight unattended work. It uses GitHub's native cloud infrastructure — no local processes, no alpha features, no risk of runaway loops on your machine.

### Step 5.1: Enable Copilot Coding Agent

Ensure your GitHub Enterprise organization has the Copilot Coding Agent enabled. This is available on your GitHub Copilot Enterprise subscription.

### Step 5.2: Add Setup Workflow to Each Repo

Create `.github/workflows/copilot-setup-steps.yml` in each repository:

**For FSI-AgentGov:**
```yaml
name: Copilot Setup Steps
on: workflow_dispatch
jobs:
  copilot-setup-steps:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install dependencies
        run: |
          pip install mkdocs mkdocs-material
```

**For FSI-AgentGov-Solutions:**
```yaml
name: Copilot Setup Steps
on: workflow_dispatch
jobs:
  copilot-setup-steps:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install dependencies
        run: |
          pwsh -Command "Install-Module -Name Microsoft.PowerApps.Administration.PowerShell -Force -Scope CurrentUser"
```

**For copilot-studio-workshop:**
```yaml
name: Copilot Setup Steps
on: workflow_dispatch
jobs:
  copilot-setup-steps:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install dependencies
        run: |
          npm install
```

### Step 5.3: Add Copilot Instructions to Each Repo

Create `.github/copilot-instructions.md` in each repository. This file tells the Copilot Coding Agent how to behave when working on issues.

**For FSI-AgentGov:**
```markdown
# Copilot Instructions for FSI-AgentGov

## Context
This is a financial services governance framework. It contains regulatory control definitions, compliance documentation, and assessment logic. The documentation site is built with MkDocs.

## Rules
- Never modify mkdocs.yml navigation without also creating the corresponding .md file.
- All control files must include YAML frontmatter with: id, title, category, and regulatory_mapping.
- Follow the existing file naming convention in docs/controls/.
- When adding a new control, also add it to the appropriate mapping file in docs/mappings/.
- Run `mkdocs build` to verify the site compiles without errors before creating a PR.

## Do Not
- Delete any existing control files.
- Change the regulatory mapping format without explicit instruction.
- Modify the CI/CD pipeline files.
```

**For FSI-AgentGov-Solutions:**
```markdown
# Copilot Instructions for FSI-AgentGov-Solutions

## Context
This is the companion automation repository for FSI-AgentGov. It contains Power Platform solutions and PowerShell deployment scripts that implement governance controls.

## Rules
- All PowerShell scripts must include comment-based help (Synopsis, Description, Parameters, Examples).
- All scripts must include error handling with try/catch blocks.
- Reference the corresponding control ID from FSI-AgentGov in script comments.
- Follow the existing folder structure under solutions/ and scripts/.

## Do Not
- Delete any existing solution files.
- Hard-code credentials or connection strings.
- Modify deployment pipelines without explicit instruction.
```

**For copilot-studio-workshop:**
```markdown
# Copilot Instructions for copilot-studio-workshop

## Context
This is a workshop development repository for customer training on Microsoft Copilot Studio. It contains lab documents, slides, and sample code.

## Rules
- Labs must follow the numbered-step format with clear expected outputs at each checkpoint.
- Each lab must include: Goal, Prerequisites, Steps, Expected Output, and Troubleshooting sections.
- Use relative links between lab files.
- Screenshots should be referenced but not generated (add placeholder text like [Screenshot: description]).

## Do Not
- Delete any existing lab files.
- Change the workshop folder structure without explicit instruction.
- Add dependencies that require customer-specific licenses to test.
```

### Step 5.4: The Overnight Workflow

**Evening (before you leave):**

1. Sync upstream context in each repo:
   ```powershell
   cd C:\dev\FSI-AgentGov && squad upstream sync
   cd C:\dev\FSI-AgentGov-Solutions && squad upstream sync
   cd C:\dev\copilot-studio-workshop && squad upstream sync
   ```

2. Create well-specified GitHub Issues in **FSI-AgentGov only** (the source of truth). Example:
   - "Add MkDocs page for control AC-07 (Access Review Automation)"
   - "Update regulatory mapping for DORA Article 15 in docs/mappings/dora.md"
   - "Generate assessment questions for controls in the Identity category"

3. Assign each issue to `@copilot` (via the GitHub UI, GitHub Mobile, or CLI):
   ```powershell
   gh issue edit 42 --repo judeper/FSI-AgentGov --add-assignee @copilot
   ```

4. Close your laptop. The Copilot Coding Agent runs in GitHub's cloud.

**Morning:**

1. Open GitHub — check for PRs in FSI-AgentGov.
2. Review each PR. Approve and merge the good ones.
3. If the merged changes affect Solutions, create follow-up issues in FSI-AgentGov-Solutions:
   - "Control AC-07 was added to FSI-AgentGov. Create a corresponding deployment script in scripts/AC-07-deploy.ps1."
4. Assign to `@copilot`.
5. After those PRs are merged, create Workshop issues if needed:
   - "Control AC-07 and its automation script are now available. Add a lab exercise demonstrating AC-07 deployment."
6. Assign to `@copilot`.

**Why sequential:** This prevents cascade errors. If the Coding Agent makes a mistake in the Controls repo, it does not automatically propagate to Solutions and Workshop. You catch it at the PR review stage.

---

## Phase 6: What to Commit to Git

Each repo now has new `.squad/` and `.github/` content. Here is what to commit:

| Path | Commit? | Reason |
|------|---------|--------|
| `.github/agents/squad.agent.md` | Yes | Agent definition that Copilot discovers |
| `.github/workflows/copilot-setup-steps.yml` | Yes | Enables Copilot Coding Agent |
| `.github/copilot-instructions.md` | Yes | Guides Copilot Coding Agent behavior |
| `.squad/team.md` | Yes | Team roster persists across clones |
| `.squad/decisions.md` | Yes | Shared decisions (project knowledge) |
| `.squad/routing.md` | Yes | Routing rules |
| `.squad/skills/` | Yes | Custom skills |
| `.squad/memory/` | No (.gitignore) | Session memory (can be large) |
| `.squad/scratch/` | No (.gitignore) | Temporary working files |

Add to each repo's `.gitignore`:
```
.squad/memory/
.squad/scratch/
```

Commit and push:
```powershell
cd C:\dev\FSI-AgentGov
git add .squad/ .github/ .gitignore
git commit -m "Add Squad team configuration and Copilot Coding Agent setup"
git push

cd C:\dev\FSI-AgentGov-Solutions
git add .squad/ .github/ .gitignore
git commit -m "Add Squad team configuration and Copilot Coding Agent setup"
git push

cd C:\dev\copilot-studio-workshop
git add .squad/ .github/ .gitignore
git commit -m "Add Squad team configuration and Copilot Coding Agent setup"
git push
```

---

## Phase 7: Maintenance

These commands are part of your regular workflow:

| Command | When | What It Does |
|---------|------|--------------|
| `squad upstream sync` | Weekly, or after updating global decisions | Pulls latest from Personal Squad into the repo |
| `squad doctor` | When something seems wrong | Diagnoses setup issues |
| `squad nap` | When `.squad/` gets large | Compresses memory, archives old state |
| `squad upgrade` | When a new Squad version is released | Updates Squad-owned files without touching your team |
| `squad status` | Anytime | Shows which squad is active and upstream links |

---

## Rollout Checklist

Complete in order. Each step has a checkpoint.

| # | Action | Checkpoint |
|---|--------|-----------|
| 1 | Verify Node.js installed | `node --version` shows v18+ |
| 2 | Install Squad CLI | `squad --version` shows 0.9.4+ |
| 3 | Run `squad doctor` | All checks pass |
| 4 | Install VS Code extensions (Copilot, Copilot Chat, SquadUI) | All enabled |
| 5 | Verify VS Code version | `code --version` shows 1.121+ |
| 6 | `squad init --global` | `%APPDATA%\squad\.squad\` exists |
| 7 | Create global `decisions.md` | File contains your standards |
| 8 | Create global `skills\repo-map.md` | File exists |
| 9 | `squad init` in FSI-AgentGov | `.squad\team.md` exists |
| 10 | `squad upstream add "$env:APPDATA\squad\.squad"` in FSI-AgentGov | `squad status` shows upstream |
| 11 | Create `.squad\routing.md` in FSI-AgentGov | File contains 3 agent roles |
| 12 | `squad init` in FSI-AgentGov-Solutions | `.squad\team.md` exists |
| 13 | `squad upstream add "$env:APPDATA\squad\.squad"` in Solutions | `squad status` shows upstream |
| 14 | Create `.squad\routing.md` in Solutions | File contains 3 agent roles |
| 15 | Create `.squad\skills\read-controls.md` in Solutions | File exists |
| 16 | `squad init` in copilot-studio-workshop | `.squad\team.md` exists |
| 17 | `squad upstream add "$env:APPDATA\squad\.squad"` in Workshop | `squad status` shows upstream |
| 18 | Create `.squad\routing.md` in Workshop | File contains 3 agent roles |
| 19 | Create `.squad\skills\read-framework.md` in Workshop | File exists |
| 20 | Create `C:\dev\fsi-workspace.code-workspace` | Opens all 3 repos in VS Code |
| 21 | Open Agents Window | Sessions list shows 3 workspaces |
| 22 | Test a parallel session (start 2 sessions) | Both run simultaneously |
| 23 | Add `copilot-setup-steps.yml` to each repo | Files committed and pushed |
| 24 | Add `copilot-instructions.md` to each repo | Files committed and pushed |
| 25 | Test Copilot Coding Agent (create 1 issue, assign to @copilot) | PR appears within 30 minutes |
| 26 | Commit all `.squad/` and `.github/` files | All pushed to GitHub |

---

## Quick Reference Card

**Start your day:**
```powershell
code C:\dev\fsi-workspace.code-workspace
# Then: Click "Open in Agents" in title bar
```

**Before leaving for the night:**
```powershell
cd C:\dev\FSI-AgentGov && squad upstream sync
gh issue create --title "Your task description" --body "Detailed requirements" --assignee @copilot
```

**Check overnight results (morning):**
```powershell
gh pr list --repo judeper/FSI-AgentGov --state open
gh pr list --repo judeper/FSI-AgentGov-Solutions --state open
gh pr list --repo judeper/copilot-studio-workshop --state open
```

**Sync upstream after updating global decisions:**
```powershell
cd C:\dev\FSI-AgentGov && squad upstream sync
cd C:\dev\FSI-AgentGov-Solutions && squad upstream sync
cd C:\dev\copilot-studio-workshop && squad upstream sync
```

---

## References

[1]: https://bradygaster.github.io/squad/ "Squad Official Documentation"
[2]: https://bradygaster.github.io/squad/docs/reference/cli/ "Squad CLI Reference"
[3]: https://code.visualstudio.com/docs/copilot/agents/agents-window "VS Code Agents Window Documentation"
[4]: https://docs.github.com/en/copilot/using-github-copilot/using-the-github-copilot-coding-agent "GitHub Copilot Coding Agent Documentation"
[5]: https://github.blog/ai-and-ml/github-copilot/how-squad-runs-coordinated-ai-agents-inside-your-repository/ "How Squad Runs Coordinated AI Agents (GitHub Blog)"
[6]: https://code.visualstudio.com/updates "VS Code Release Notes"
