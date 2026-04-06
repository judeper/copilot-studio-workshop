# Copilot Studio Workshop Facilitator Guide

## Workshop goals

This two-day workshop helps customers move from foundational Copilot Studio concepts to a practical, enterprise-shaped multi-agent scenario. By the end of the event, participants should be able to build, ground, test, and publish agents on Day 1, then extend that foundation into a governed Loan Processing Agent solution on Day 2.

Primary goals:

- Build confidence with Copilot Studio for mixed audiences.
- Show how makers, IT pros, and developers each contribute to a shared agent delivery lifecycle.
- Connect foundational agent authoring to enterprise patterns such as orchestration, safety, data grounding, document generation, MCP-enabled operations, and built-in evaluation.
- Leave each participant with clear next steps for production readiness.

## Audience profile

This workshop is designed for mixed customer cohorts:

- [Maker] Business technologists and power users who will design prompts, topics, cards, and flows.
- [IT Pro] Platform owners, tenant admins, and governance leads who care about environments, security, publishing, licensing, and controls.
- [Developer] Engineers and architects who want solution packaging, extensibility, data integration, MCP-based tooling, and a VS Code-centered workflow.

Recommended baseline:

- Comfortable using Microsoft 365 and web apps.
- Familiarity with Power Platform concepts is helpful but not required for Day 1.
- Day 2 assumes Day 1 familiarity, completed Foundation labs, or equivalent hands-on Copilot Studio experience.

> **Note:** If several attendees skip Day 1, open Day 2 with a stricter prerequisite check and be ready to pair them with stronger table groups.

## Presentation companion sources

The 13 PPTX decks in [`../Copilot-Studio-Workshop-Slides/`](../Copilot-Studio-Workshop-Slides/) are the primary delivery artifacts for live instruction. The markdown files below are the companion authoring and speaker-note sources used for narrative review, content updates, and AI-assisted editing:

- [`../assets/slide-deck-outline.md`](../assets/slide-deck-outline.md) for the master slide-by-slide narrative and core speaker notes.
- [`../assets/slide-deck-delivery-notes.md`](../assets/slide-deck-delivery-notes.md) for transition framing, pacing guardrails, audience emphasis, and parallel deck-build tasks.
- [`../assets/slide-deck-visual-plan.md`](../assets/slide-deck-visual-plan.md) for screenshot reuse, custom visual planning, and failure-state capture recommendations.
- [`../assets/lab-timing-guide.md`](../assets/lab-timing-guide.md) for pacing, recovery options, and module timing.
- [`../assets/screenshot-capture-checklist.md`](../assets/screenshot-capture-checklist.md) for the screenshot inventory that supports the deck and the labs.
- [`../tests/validation-checklist.md`](../tests/validation-checklist.md) and [`../tests/environment-smoke-tests.md`](../tests/environment-smoke-tests.md) for validation cues and demo-mode fallback decisions.

## Automated setup

On a fresh Windows 11 machine, open PowerShell and run:

```powershell
mkdir C:\workshop; cd C:\workshop
irm https://raw.githubusercontent.com/judeper/copilot-studio-workshop/master/workshop/automation/Invoke-WorkshopBootstrap.ps1 -OutFile .\Bootstrap.ps1
.\Bootstrap.ps1
```

If the repo is already cloned, run the wizard directly instead:

```powershell
pwsh -File .\workshop\automation\Invoke-WorkshopBootstrap.ps1
```

The wizard handles these steps automatically:

1. **PowerShell 7** — Installs PS 7 via winget if running in PS 5.1, then re-launches itself.
2. **CLI tools** — Installs git, Power Platform CLI (pac), and Node.js via winget if missing. Halts if required tools (git, pac) cannot be installed.
3. **PowerShell modules** — Installs PnP.PowerShell, Microsoft.Graph, and PowerApps Admin modules. Halts if required modules fail.
4. **Config file** — Creates `workshop-config.json` from the example template and walks through each required value interactively: tenant name (auto-derives all SharePoint URLs), TenantId (auto-detected from pac auth if available).
5. **Entra app registration** — Auto-creates an Entra app with the required API permissions (Group.ReadWrite.All, User.Read.All, Team.Create, Sites.FullControl.All) via Microsoft Graph, creates the service principal, provides a direct Azure portal link for admin consent, and programmatically verifies that the SharePoint `oauth2PermissionGrant` (`AllSites.FullControl`) exists — this grant is critical for PnP tenant admin operations and the portal consent button sometimes silently fails to create it.
6. **pac CLI auth** — Checks for an active Power Platform CLI profile and launches interactive sign-in if needed.
7. **Day 2 assets** — Downloads all workshop assets from the public GitHub repository.
8. **Prerequisites check** — Runs the scripted validation suite and reports what the automation can verify for shared facilitator setup.
9. **Readiness dashboard** — Shows green/yellow status for shared setup signals plus the exact next-step commands to run.

After the wizard completes:

```powershell
# 1. Pre-stage shared Day 1 site (creates Woodgrove Bank site, lists, schema, and sample data)
powershell -File .\workshop\automation\Invoke-WorkshopLabSetup.ps1 -Mode StudentReady

# 2. Optional: create or reserve a separate facilitator demo environment
# Use -UpdateConfig to write the discovered or created URL back to workshop-config.json
powershell -File .\workshop\automation\Initialize-WorkshopPowerPlatformEnvironment.ps1 -CreateEnvironment -UpdateConfig

# 3. Optional: pre-import the Day 2 base state in a separate demo environment only
# Import target comes from -EnvironmentUrl or config.EnvironmentUrl; pac auth only supplies tenant/account context
powershell -File .\workshop\automation\Import-WorkshopEnterpriseAssets.ps1 -ImportSolution -EnvironmentUrl https://<facilitator-demo>.crm.dynamics.com
# -ImportBaseData also needs a Dataverse-capable client secret plus one-time Power Platform app registration
powershell -File .\workshop\automation\Import-WorkshopEnterpriseAssets.ps1 -ImportBaseData -EnvironmentUrl https://<facilitator-demo>.crm.dynamics.com

# 4. Optional advanced path: qualify a completed facilitator gold source, then rebuild the fallback environment
powershell -File .\workshop\automation\Set-WorkshopFacilitatorFallbackSource.ps1 -ListCandidates
powershell -File .\workshop\automation\Set-WorkshopFacilitatorFallbackSource.ps1 -SourceEnvironmentUrl https://<completed-source>.crm.dynamics.com -UpdateConfig
powershell -File .\workshop\automation\Invoke-WorkshopFacilitatorFallbackBuild.ps1

# 5. Optional: validate one student first, then batch-provision per-student environments
powershell -File .\workshop\automation\Invoke-StudentEnvironmentProvisioning.ps1

# 6. Reset the shared environment for re-testing (deletes WoodgroveBank site + purges recycle bin)
pwsh -File .\workshop\automation\Reset-WorkshopEnvironment.ps1 -HardDelete

# 7. Post-workshop: tear down all student environments
powershell -File .\workshop\automation\Remove-StudentEnvironments.ps1 -HardDelete

# 8. Optional: tear down a disposable facilitator demo or fallback target
powershell -File .\workshop\automation\Remove-WorkshopFacilitatorEnvironment.ps1 -EnvironmentUrl https://<demo-or-fallback>.crm.dynamics.com
```

> **Cleanup safety:** `Remove-WorkshopFacilitatorEnvironment.ps1` refuses to delete the configured facilitator gold source unless you intentionally re-run it with `-AllowGoldSourceDeletion`.

> **Per-student provisioning path:** If you answer **Yes** to student provisioning during the bootstrap wizard, the wizard now saves participant emails, reuses or imports an existing app-only certificate when available, creates a new self-signed certificate when needed, registers that certificate on the workshop Entra app, and can optionally generate a client secret into the configured user environment variable (`COPILOT_WORKSHOP_APP_SECRET` by default). `Invoke-WorkshopPrereqCheck.ps1` now reports shared facilitator readiness separately from student-provisioning readiness so you can see whether app-only SharePoint auth is actually ready before you run `Invoke-StudentEnvironmentProvisioning.ps1`. If the tenant still rejects app-only SharePoint site creation or site-content initialization, the provisioning script falls back to the configured delegated PnP login flow (`OSLogin`, `Interactive`, or `DeviceLogin`), grants the facilitator delegated account site-collection-admin access alongside the student, and retries from the saved student map instead of rebuilding the whole student environment from scratch.

> **Billing expectation:** After any facilitator demo or student Power Platform environment is created, open **Power Platform admin center** and either link an Azure subscription under **Billing** for pay-as-you-go or allocate Copilot Studio capacity/credits to that environment. Treat this as a manual facilitator step. The repo can attempt preview student credit allocation when a client secret is available, but that API may still return `403`, so automation is not a reliable substitute for PPAC billing configuration.

Decision point:

- Use `-Mode StudentReady` for participant environments.
- Use `-ImportSolution` and `-ImportBaseData` only for a separate facilitator demo environment.
- Expected result for optional import: the selected facilitator environment can be pre-staged with the Enterprise solution plus the base Woodgrove Lending Hub job roles, evaluation criteria, candidates, resumes, and job applications.
- `Import-WorkshopEnterpriseAssets.ps1` targets the URL supplied by `-EnvironmentUrl`, or `config.EnvironmentUrl` when `-EnvironmentUrl` is omitted. Changing the active `pac` environment alone does not retarget the import.
- `Initialize-WorkshopPowerPlatformEnvironment.ps1 -CreateEnvironment` only writes the resolved URL back to `workshop-config.json` when you also pass `-UpdateConfig`.
- `-ImportBaseData` and the advanced facilitator fallback automation require a client secret (`Identity.ClientSecret` or `Identity.ClientSecretEnvVar`), the Power Apps Service delegated permission with admin consent, and a one-time Power Platform app registration by a delegated admin (`New-PowerAppManagementApp` or `pac admin application register`).

> **Operator expectation:** SharePoint setup uses PnP PowerShell sign-in with the configured Entra app client ID. The default login mode is `OSLogin` (Windows native sign-in via WAM) with automatic fallback to `DeviceLogin`. You can override this by setting `SharePoint.PnPLoginMode` to `DeviceLogin`, `Interactive`, or `CertificateThumbprint` in `workshop-config.json`. If setup runs under `DeviceLogin`, the first provisioning pass can prompt separately for the SharePoint admin center, tenant root, and target site; that is expected. Open `https://microsoft.com/devicelogin` and then enter the current code shown by the script rather than relying on the auto-opened browser tab. For Power Platform work, keep the active `pac` profile in the correct tenant and admin account context, but remember that `Import-WorkshopEnterpriseAssets.ps1` still targets `-EnvironmentUrl` or `config.EnvironmentUrl`.

> **Student domain naming:** Per-student Power Platform domains are derived from `EnvironmentBootstrap.DomainName`, but the automation now shortens the prefix when needed so the student alias still survives inside the 24-character platform limit. This keeps domains unique across students instead of truncating them all to the same shared prefix.

## Environment tracks and recommended setup order

Treat the workshop as three separate readiness tracks, not one blended setup job:

1. **Shared prerequisites**
   - Facilitator machine readiness
   - Tenant/app/auth readiness
   - Shared Day 1 `Woodgrove Bank` SharePoint site and sample data
   - Day 2 localized assets

2. **Facilitator-only demo base**
   - A separate Power Platform environment reserved for facilitator demos and rescue moments
   - Optional Day 2 Enterprise solution and Woodgrove Lending Hub base-data import only in that demo environment
   - A validated fallback path for the riskiest modules

3. **Student hands-on environments**
   - Either the shared `StudentReady` path or per-student provisioning
   - Ready for labs, but intentionally not pre-solved past the shared prerequisites

Recommended setup order:

1. Run the bootstrap wizard and make sure the shared-readiness dashboard is green enough to continue.
2. Run `Invoke-WorkshopLabSetup.ps1 -Mode StudentReady` to establish the shared Day 1 baseline.
3. Reserve or create a **separate facilitator demo environment**, persist its URL with `-UpdateConfig` or plan to pass `-EnvironmentUrl`, and keep `pac` in the correct tenant/admin account context before any optional demo-only imports.
4. If Day 2 demo pre-staging is needed, run `Import-WorkshopEnterpriseAssets.ps1 -ImportSolution` and, when you want the Lab 13 base data present too, `Import-WorkshopEnterpriseAssets.ps1 -ImportBaseData` only against that facilitator demo URL.
5. If you maintain a completed gold source environment, first run `Set-WorkshopFacilitatorFallbackSource.ps1` to qualify it and save `FacilitatorFallback.SourceEnvironmentUrl`, then run `Invoke-WorkshopFacilitatorFallbackBuild.ps1` only against a separate facilitator-owned fallback target.
6. If you want isolated student environments, validate with one student first, then run `Invoke-StudentEnvironmentProvisioning.ps1` after the shared prerequisites are already stable.
7. Validate the facilitator demo path or copied facilitator fallback path separately from the student path. A green student setup does not prove the facilitator rescue path is ready, and a green facilitator demo does not prove hands-on students can build forward unaided.

> **Scope decision:** The default path still optimizes for a **clean validated demo base** for facilitators. If you choose to maintain a completed facilitator-owned gold source environment, `Set-WorkshopFacilitatorFallbackSource.ps1` now qualifies and designates that source, and `Invoke-WorkshopFacilitatorFallbackBuild.ps1` rebuilds a separate facilitator fallback environment with a supported full-copy flow. Treat that as an advanced facilitator-only path, not as the student environment model.

> **Artifact packaging and repair:** The advanced fallback build now refreshes a git-ignored source snapshot at `workshop\automation\facilitator-fallback-artifacts.json` before copy and writes a git-ignored post-copy repair report at `workshop\automation\facilitator-fallback-repair-report.json` after copy. Review that repair report before you rely on the rebuilt fallback environment live.

## Quick facilitator runbook

If you are a new facilitator, follow this exact order:

1. Run the bootstrap wizard on a clean Windows machine.
2. Confirm the shared-readiness dashboard is good enough to continue.
3. Run `Invoke-WorkshopLabSetup.ps1 -Mode StudentReady` to create the shared Day 1 baseline.
4. Decide whether students will use the shared baseline only or per-student environments.
5. Reserve or create a **separate facilitator demo environment** before any demo-only Day 2 import, and either persist its URL with `-UpdateConfig` or plan to pass `-EnvironmentUrl`. After the environment exists, configure Copilot billing in PPAC by linking pay-as-you-go or assigning Copilot Studio capacity before you test agents in it.
6. If you need Day 2 demo pre-staging, keep `pac` in the correct tenant/admin context and run `Import-WorkshopEnterpriseAssets.ps1 -ImportSolution` against that facilitator demo URL. If you also want the Lab 13 base records present, follow with `Import-WorkshopEnterpriseAssets.ps1 -ImportBaseData` after confirming the Dataverse client-secret prerequisites are in place.
7. If you use a completed facilitator fallback environment, run `Set-WorkshopFacilitatorFallbackSource.ps1` to qualify the gold source and persist `FacilitatorFallback.SourceEnvironmentUrl`, then run `Invoke-WorkshopFacilitatorFallbackBuild.ps1` only against a separate facilitator-owned target environment and review `facilitator-fallback-repair-report.json` after the copy.
8. If you need isolated student environments, validate with one student first, then run `Invoke-StudentEnvironmentProvisioning.ps1` for the full batch only after the shared prerequisites are already stable. If the saved result ends as `FollowUpRequired` because credit allocation did not complete, finish the billing step in PPAC before you hand that environment to a student.
9. Validate the facilitator demo base or copied facilitator fallback environment separately from the student path.
10. Keep the facilitator demo environment private to facilitators; do not use it as the student build environment.
11. Keep the detailed checklist open for final go/no-go review and fallback planning.

Expected outcome after this runbook:

- The shared Day 1 prerequisites are ready.
- The facilitator has a separate demo base or rebuilt fallback environment for rescue demos.
- Student environments are ready for hands-on without being pre-solved past the shared prerequisites.

## Presentation materials

The repository includes a committed slide corpus for live delivery:

- **Location:** `workshop\Copilot-Studio-Workshop-Slides\`
- **Structure:** 13 PPTX decks, `Module-00` through `Module-12`
- **Total:** 98 slides across the full workshop

Use the slide assets this way:

- Use the **PPTX decks** for live delivery, screen sharing, and facilitator presentation flow.
- Use `workshop\assets\slide-deck-outline.md` for speaker notes, teaching intent, and text-first review.
- Treat the PPTX decks as the authoritative delivery format and the markdown outline as the narrative companion.

Day split:

- **Day 1:** Modules `00` through `06`
- **Day 2:** Modules `07` through `12`

When updating slide content:

1. Make the delivery change in the relevant PPTX file first.
2. Update `workshop\assets\slide-deck-outline.md` when the module structure, slide sequencing, transition points, or teaching intent changes.
3. Review `workshop\assets\lab-timing-guide.md` if the updated content affects pre-lab framing or module pacing.
4. Preserve the existing slide formatting. New or revised slides should match the current color palette, layout system, and design treatment rather than introducing a new visual style.

For pacing-sensitive delivery, keep the workshop's protected labs in view: Labs `06`, `18`, `22`, and `24` need enough instructor framing before the hands-on transition.

## Suggested delivery flow

### Day 1: Foundation essentials

Use Day 1 to create shared language and shared wins. Keep the pace brisk through concepts, then maximize keyboard time once participants enter guided build modules.

Suggested pattern:

1. Welcome and environment check.
2. Short framing on agents, scenarios, and workshop outcomes.
3. Guided tour of Copilot Studio fundamentals.
4. Structured build sequence through declarative patterns, solutions, prebuilt agents, and custom agent concepts.
5. Hands-on work through knowledge, topics, cards, flows, triggers, publishing, and the Day 1 licensing close.
6. End-of-day recap tied to Foundation completion or equivalent readiness.

Recommended labs to reference:

- [Lab 00 - Environment Setup](../labs/lab-00-environment-setup/)
- [Lab 01 - Intro to Agents](../labs/lab-01-intro-to-agents/)
- [Lab 02 - Copilot Studio Fundamentals](../labs/lab-02-copilot-studio-fundamentals/)
- [Lab 03 - Declarative Agents](../labs/lab-03-declarative-agents/)
- [Lab 04 - Solutions](../labs/lab-04-solutions/)
- [Lab 05 - Prebuilt Agents](../labs/lab-05-prebuilt-agents/)
- [Lab 06 - Custom Agent](../labs/lab-06-custom-agent/)
- [Lab 07 - Topics and Triggers](../labs/lab-07-topics-triggers/)
- [Lab 08 - Adaptive Cards](../labs/lab-08-adaptive-cards/)
- [Lab 09 - Agent Flows](../labs/lab-09-agent-flows/)
- [Lab 10 - Event Triggers](../labs/lab-10-event-triggers/)
- [Lab 11 - Publish Agent](../labs/lab-11-publish-agent/)
- [Lab 12 - Licensing](../labs/lab-12-licensing/)

### Day 2: Enterprise scenario

Day 2 should feel like a progression, not a reset. Anchor the day around the Loan Processing Agent scenario and repeatedly connect new material to business readiness, governance, and operational quality.

Suggested pattern:

1. Reconfirm prerequisites and Day 1 carry-forward.
2. Reorient participants to the Loan Processing Agent business process.
3. Build through instruction quality, connected agents, automation, model choices, safety, multimodal processing, Dataverse grounding, document generation, MCP integration, user feedback, and evaluation on the shared core path.
4. Close with architecture review, governance discussion, and next-step planning while developers who are caught up can branch to the optional VS Code workflow.

Recommended labs to reference:

Shared core path:

- [Lab 13 - Loan Processing Agent Setup](../labs/lab-13-hiring-agent-setup/)
- [Lab 14 - Agent Instructions](../labs/lab-14-agent-instructions/)
- [Lab 15 - Multi-Agent](../labs/lab-15-multi-agent/)
- [Lab 16 - Trigger Automation](../labs/lab-16-trigger-automation/)
- [Lab 17 - Model Selection](../labs/lab-17-model-selection/)
- [Lab 18 - Content Moderation](../labs/lab-18-content-moderation/)
- [Lab 19 - Multimodal Prompts](../labs/lab-19-multimodal-prompts/)
- [Lab 20 - Dataverse Grounding](../labs/lab-20-dataverse-grounding/)
- [Lab 21 - Document Generation](../labs/lab-21-document-generation/)
- [Lab 22 - MCP Integration](../labs/lab-22-mcp-integration/)
- [Lab 23 - User Feedback](../labs/lab-23-user-feedback/)
- [Lab 24 - Agent Evaluation](../labs/lab-24-agent-evaluation/)

Optional/stretch path:

- [Lab 25 - VS Code Extension](../labs/lab-25-vscode-extension/)

## Pacing guidance

Use a repeatable rhythm across both days:

- Demo first when a step has many clicks, permissions, or hidden dependencies.
- Let participants work first when the task is creative, exploratory, or easy to validate.
- Time-box concept sections to protect lab time.
- Pause every 60 to 90 minutes for visible status checks.
- Treat setup drift early; treat content drift later.

Recommended split:

- 35 to 40 percent instructor-led framing and demo.
- 50 to 60 percent guided hands-on work.
- 10 percent recap, Q&A, and reset time.

### When to demo

Demo the full flow before participants touch the keyboard when:

- Entering a new tool surface for the first time.
- Creating environments, solutions, connections, or security-sensitive configuration.
- Troubleshooting a known failure mode.
- Showing publishing, trigger setup, MCP configuration, or evaluation setup.

### When to let participants work

Let participants work without interruption when:

- Drafting prompts or instructions.
- Building topics, cards, and flows from a known pattern.
- Tuning grounding sources or response formatting.
- Running validation tests with a clear success criterion.

> **Tip:** Use short “demo, mirror, roam” cycles. Demo for 5 to 8 minutes, give 15 to 25 minutes to build, then roam and unblock tables.

## Timing checkpoints

| Day | Checkpoint | Target time | What should be true |
| --- | --- | --- | --- |
| Day 1 | Welcome complete | 09:30 | Attendees are signed in, know outcomes, and understand the two-day arc. |
| Day 1 | Environment ready | 10:15 | Copilot Studio access confirmed and core prerequisites validated. |
| Day 1 | Foundation complete | 11:30 | Participants understand agent concepts and core Copilot Studio building blocks. |
| Day 1 | Custom agent built | 13:45 | Most tables have a working agent with knowledge attached. |
| Day 1 | Interaction layer complete | 15:15 | Topics, Adaptive Cards, and flows are functioning for most participants. |
| Day 1 | Publish and recap | 16:30 | Participants have published or observed publishing and know Day 2 prerequisites. |
| Day 2 | Scenario reset complete | 09:30 | Loan Processing Agent architecture and prerequisites are clear to everyone. |
| Day 2 | Multi-agent core built | 11:15 | Central agent and connected-agent pattern are working. |
| Day 2 | Safety and grounding complete | 14:00 | Safety, model selection, multimodal, and Dataverse topics are covered. |
| Day 2 | MCP, feedback, and evaluation complete | 16:00 | MCP configuration, feedback capture, evaluation flow, and the end-to-end scenario can be demonstrated. |
| Day 2 | Final review | 16:30 | Deliverables reviewed, governance discussed, and next steps captured. |

## Troubleshooting strategy

Handle issues in this order:

1. Confirm identity, tenant, environment, and license.
2. Confirm participants are in the correct lab and using the expected account.
3. Reproduce the issue on the facilitator machine or demo tenant.
4. Decide whether the issue is local, tenant-wide, or service-related.
5. Route the participant to a recovery path that preserves momentum.

Useful recovery tactics:

- Pair blocked attendees with a working partner for observation-based learning.
- Keep screenshots or a completed demo environment ready for catch-up moments.
- If a licensing or tenant issue blocks a full exercise, switch the attendee to observe key checkpoints and continue later.
- For Day 2, allow participants who are behind to use a pre-staged Loan Processing Agent solution for later modules.

## Escalation guidance

Escalate quickly when:

- Multiple attendees fail at the same step.
- Tenant-wide permissions or licensing are missing.
- Copilot Studio or Dataverse services appear degraded.
- Publishing, Teams, MCP, or evaluation configuration fails for reasons outside normal workshop setup.

Escalation playbook:

- Capture the exact step, screenshot, account type, and error text.
- Test with the facilitator demo account.
- Decide whether to continue with workaround, switch to demonstration, or skip to the next learning objective.
- Preserve the schedule; do not let a single environment issue consume an entire module.

> **Warning:** If publishing, MCP setup, or evaluation setup fails across multiple attendees, convert the exercise to instructor demo mode and protect the rest of the day.

## Break and lunch handling

Use breaks as operational checkpoints, not only downtime.

- Before each break, tell attendees exactly where they should pause.
- Display a slide or shared note with the current lab number and next restart point.
- Ask everyone to keep browser tabs open and avoid signing out unless required.
- Use lunch to validate the afternoon demo environment and spot-check accounts that were partially blocked in the morning.

Suggested rhythm:

- Morning break after setup or foundation content.
- Lunch after the first major build milestone.
- Afternoon break after the most complex hands-on segment.

## Module-by-module facilitator notes

### Day 1 modules

#### Welcome and setup

- Set expectations for mixed audiences and emphasize collaboration across roles.
- Confirm every participant can access the correct tenant and environment.
- Call out [Lab 00 - Environment Setup](../labs/lab-00-environment-setup/) early for any attendee who needs catch-up steps.

#### Agent concepts and fundamentals

- Keep this section practical.
- Translate concepts like grounding, orchestration, and autonomy into customer examples.
- Ask each audience type what success looks like in their role.

#### Declarative agents, solutions, and reusable patterns

- Show the fastest path to visible value first.
- Explain when declarative agents are sufficient, how solutions package shared assets, and when prebuilt agents accelerate delivery.
- Remind [Developer] participants that solution packaging becomes important as soon as they move past experimentation.

#### Custom agent build and grounding

- Use [Lab 06 - Custom Agent](../labs/lab-06-custom-agent/) as the first long Day 1 build block and checkpoint working knowledge attachment halfway through.
- Connect the custom agent back to the earlier solution story so participants understand what should travel together between environments.
- Reinforce that makers shape behavior, IT pros validate access, and developers think ahead about reuse.

#### Topics, cards, and flows

- Demo one end-to-end pattern before participants build.
- Encourage [Maker] attendees to focus on clarity and user experience.
- Encourage [IT Pro] attendees to watch connectors, governance, and approval patterns.

#### Triggers and publishing

- Keep the publishing sequence tightly guided.
- Explain differences between “works in studio” and “ready for business use.”
- Use this moment to introduce Day 2 as the enterprise extension of Day 1.

#### Licensing, credits, ROI, and Day 2 prep

- Treat [Lab 12 - Licensing](../labs/lab-12-licensing/) as a discussion-first close that explains Copilot Credits, user licensing, and where capacity is still consumed.
- Use scenario-based ROI questions so mixed audiences can connect commercial readiness back to the build they just finished.
- End with the exact Day 2 prerequisite check so attendees know the shared core path comes first tomorrow.

### Day 2 modules

#### Loan Processing Agent setup and instructions

- Re-anchor the room on the scenario and business value.
- Stress that instruction quality drives downstream behavior.
- Connect instruction writing to testing and governance, not just creativity.

#### Multi-agent orchestration and triggers

- Draw the architecture on a whiteboard or slide.
- Revisit which agent owns which responsibility.
- Help participants resist over-engineering; simple handoffs are easier to debug.

#### Model selection, safety, and multimodal

- Frame model choice as a trade-off between cost, speed, and quality.
- Treat safety as a first-class requirement, not an add-on.
- Encourage [IT Pro] attendees to lead the governance discussion here.

#### Dataverse, document generation, MCP, and evaluation

- Remind attendees that enterprise grounding changes both usefulness and risk profile.
- Demo MCP setup once, keep user feedback and evaluation on the shared core path, then release advanced tables only to the optional VS Code branch after Lab 24.
- If time is tight, prioritize grounding and safety over optional embellishments.

#### Feedback and wrap-up

- End with measurable deliverables, not just a feature tour.
- Keep user feedback and evaluation with the full room; [Lab 25 - VS Code Extension](../labs/lab-25-vscode-extension/) is the optional developer-only stretch path once the core build is complete.
- Ask participants what would be required to productionize the scenario in their organization.
- Close on completion guidance, next labs, and ownership after the workshop.

## End-of-day outcomes

### Day 1 outcomes

- Participants understand core Copilot Studio concepts.
- Participants have completed or observed the core Foundation build path.
- Participants know whether they are ready for Day 2 or need additional practice.

### Day 2 outcomes

- Participants can explain the Loan Processing Agent architecture and supporting governance controls.
- Participants have worked through the shared core path of enterprise-focused agent patterns.
- Participants leave with a practical adoption conversation for their own environment.

## Facilitator closeout checklist

- Capture attendance, blockers, and follow-up owners.
- Note which labs were completed versus demonstrated.
- Record tenant or licensing issues that need post-event remediation.
- Share the participant guides and direct attendees to the relevant lab folders for continued practice.
