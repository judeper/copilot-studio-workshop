# Pre-Event Environment Checklist

Use this runbook for three readiness passes: first pass 7 to 14 days before delivery, second pass 1 to 2 days before delivery, and a final pass on the morning of Day 1. Use the [Environment Smoke Tests](../tests/environment-smoke-tests.md) for the opening-room fast path; use this checklist when you need the complete pre-event go/no-go review. If you are new to the repo, start with the **Quick facilitator runbook** in the [Facilitator Guide](./facilitator-guide.md) and then return here for the full review.

## How to use this checklist

- Mark each section green, yellow, or red during the pre-event review.
- Green means continue hands-on as planned.
- Yellow means keep the module on the agenda, but pre-stage a facilitator demo and tell the room where hands-on stops.
- Red means treat the environment as not ready until the blocker is fixed or the module is formally removed from the delivery plan.

**Recommended:** On a fresh Windows 11 machine, open PowerShell and run:

```
mkdir C:\workshop; cd C:\workshop
irm https://raw.githubusercontent.com/judeper/copilot-studio-workshop/master/workshop/automation/Invoke-WorkshopBootstrap.ps1 -OutFile .\Bootstrap.ps1
.\Bootstrap.ps1
```

Or if the repo is already cloned: `pwsh -File .\workshop\automation\Invoke-WorkshopBootstrap.ps1`

After the wizard, run `pwsh -File .\workshop\automation\Invoke-WorkshopLabSetup.ps1 -Mode StudentReady` to pre-stage the shared Day 1 site.

Manual setup steps (if not using the bootstrap wizard): copy `workshop-config.example.json` to `workshop-config.json`, edit placeholders, run `Install-WorkshopPrerequisites.ps1`, run `Get-WorkshopDay2Assets.ps1`, run `Invoke-WorkshopPrereqCheck.ps1`, then run `Invoke-WorkshopLabSetup.ps1 -Mode StudentReady`.

- If the dry run still needs a fresh facilitator environment, populate the optional `EnvironmentBootstrap` block in `../automation/workshop-config.json` and run `../automation/Initialize-WorkshopPowerPlatformEnvironment.ps1 -CreateEnvironment` directly, or `../automation/Invoke-WorkshopLabSetup.ps1 -CreateEnvironment -Mode StudentReady` if you want the rest of the provisioning flow to continue. This wraps the officially documented `pac admin create` flow, still requires an already-authenticated admin-capable `pac` profile plus available capacity/licensing, and updates `EnvironmentUrl` when the created URL can be resolved.
- `SharePoint.PnPLoginMode` defaults to `OSLogin` (Windows native sign-in via WAM) with automatic fallback to `DeviceLogin`. If setup runs under `DeviceLogin`, expect separate browser/device-code prompts for the SharePoint admin center, tenant root, and target site during first-time site provisioning. The bootstrap wizard ensures the Entra app's SharePoint `oauth2PermissionGrant` (`AllSites.FullControl`) is created — without this, PnP tenant admin operations fail even for Global Admins.

Review the workshop in this order so a new facilitator does not mix the setup tracks together:

1. **Shared prerequisites** — bootstrap, tenant/app/auth readiness, the shared Day 1 SharePoint baseline, and the Day 2 assets
2. **Facilitator demo base** — a separate facilitator-only Power Platform environment used for demos and recovery
3. **Student hands-on path** — either the shared `StudentReady` route or the optional per-student provisioning route

### Facilitator-only demo base

- [ ] A separate facilitator demo environment exists and is reserved for facilitator-only demos and recovery use
- [ ] Before any optional Day 2 import, `pac auth list` / `pac auth who` confirm the active profile points to that facilitator demo environment
- [ ] If Day 2 demo pre-staging is needed, `Import-WorkshopOperativeAssets.ps1 -ImportSolution` has been validated only in that facilitator demo environment
- [ ] The facilitator can demonstrate the highest-risk modules from this demo environment without depending on student environments
- [ ] If the delivery plan needs completed end-state artifacts beyond the clean demo base, separate checkpoints, screenshots, or facilitator-owned snapshots are prepared because the repo does not currently auto-build every later-lab outcome

### Optional: batch student environment provisioning

If provisioning per-student environments (instead of a shared environment), additional Entra app permissions and prerequisites are required:

- [ ] Entra app registration has **Microsoft Graph** application permissions: `Team.Create`, `User.Read.All`, `Group.ReadWrite.All`
- [ ] Entra app registration has **SharePoint** application permission: `Sites.FullControl.All`
- [ ] Entra app registration has the **Power Apps Service** delegated permission for **Access the Power Apps Service API** and admin consent
- [ ] A delegated Power Platform admin has registered the Entra app with Power Platform once (for example via `New-PowerAppManagementApp` or `pac admin application register`)
- [ ] Bootstrap has either reused, imported, or created the student-provisioning certificate and saved its thumbprint in `SharePoint.PnPCertificateThumbprint`
- [ ] `Invoke-WorkshopPrereqCheck.ps1` reports that student-provisioning SharePoint app-only auth succeeds
- [ ] Be ready to complete delegated SharePoint sign-in during provisioning if the tenant rejects app-only site creation or site-content initialization; the script falls back to the configured PnP login mode, can grant the facilitator account site-collection-admin access, and then resumes from the saved student map on retry
- [ ] `Microsoft.PowerApps.Administration.PowerShell` module v2.0.150+ is installed (for `Add-PowerAppsAccount -ClientSecret`)
- [ ] `Identity.ParticipantEmails` is populated in `workshop-config.json`
- [ ] A client secret is available either in `Identity.ClientSecret` or, preferably, via `Identity.ClientSecretEnvVar` (the bootstrap wizard can generate and store one in `COPILOT_WORKSHOP_APP_SECRET`; this supports app-only PowerApps admin auth after the one-time registration above)
- [ ] Tenant has sufficient Copilot Studio credit capacity for all students (default: 25,000 per student)
- [ ] `D365_CDSSampleApp` template is enabled for the target region — verify with `pac admin list-app-templates` (enabled for `unitedstates`, may be disabled in other regions)
- [ ] If preview app-only credit allocation still returns 403, the facilitator has a manual PPAC credit-allocation fallback ready
- [ ] `EnvironmentBootstrap.DomainName` is set to a workshop-safe base prefix; student environment domains are auto-shortened as needed so each student alias remains unique within the 24-character limit
- [ ] Before a full batch run, validate with a temporary one-student `Identity.ParticipantEmails` list. If you need to isolate environment and SharePoint validation from Teams, run `powershell -File .\workshop\automation\Invoke-StudentEnvironmentProvisioning.ps1 -SkipTeams` first, then re-run the full student batch when you are ready to validate Teams as well
- Run: `powershell -File .\workshop\automation\Invoke-StudentEnvironmentProvisioning.ps1`
- Post-workshop cleanup: `powershell -File .\workshop\automation\Remove-StudentEnvironments.ps1 -HardDelete`

### Cleanup and re-testing

If you need to tear down the shared environment and re-test from scratch:

1. **Reset the shared environment** — deletes the Contoso IT SharePoint site and purges it from the recycle bin:
   ```powershell
   pwsh -File .\workshop\automation\Reset-WorkshopEnvironment.ps1 -HardDelete
   ```
2. **Wait at least 30 seconds** after the hard-delete completes before re-running setup. SharePoint recycle bin purges are asynchronous.
3. **Re-run the lab setup** to recreate the site and sample data:
   ```powershell
   pwsh -File .\workshop\automation\Invoke-WorkshopLabSetup.ps1 -Mode StudentReady
   ```

> **Soft-delete gotcha:** Without `-HardDelete`, deleted sites remain in the SharePoint recycle bin for up to 93 days. Site creation will fail if the URL is still reserved in the recycle bin. Always use `-HardDelete` when re-testing.

Additional reset options:
- Add `-IncludeEntraApp` to also delete the Entra app registration (the bootstrap wizard will recreate it).
- Add `-IncludeTokenCache` to clear local MSAL token caches (forces fresh sign-in on next run).
- For per-student environment cleanup, use `Remove-StudentEnvironments.ps1 -HardDelete` instead.

## Tenant, identity, and licensing

- [ ] Confirm the workshop tenant is active and not under service restriction.
- [ ] Confirm facilitator and backup facilitator accounts can sign in successfully.
- [ ] Confirm participant accounts or attendee sign-in instructions are ready.
- [ ] Confirm workshop accounts use supported work or school identities.
- [ ] Confirm multifactor authentication expectations are communicated in advance.
- [ ] Confirm Microsoft Copilot Studio access is available for facilitators.
- [ ] Confirm participant licensing or trial guidance is ready and tested.
- [ ] Confirm Microsoft 365 Copilot requirements are understood for publishing scenarios.
- [ ] Confirm Copilot Studio Authors or equivalent publishing permissions are configured.
- [ ] Confirm the workshop environment has **Copilot Studio credits** available. Use one of these options:
  - **Pay-as-you-go:** Link an Azure subscription to the environment via **Power Platform admin center** > **Environments** > select your environment > **Billing** > **Link Azure subscription**. This is the fastest option for workshop scenarios.
  - **Capacity pack:** Confirm a Copilot Studio capacity pack is assigned to the tenant and allocated to the workshop environment.
  - **Trial:** Confirm a Copilot Studio trial is active and has not expired. Note that trials are time-limited and may block publishing or advanced actions.
- [ ] Verify credits are working by creating a temporary test agent, asking a question in the test pane, and confirming a response is returned without a capacity error.

**If unresolved:** Treat the environment as not ready. Do not start self-paced work until sign-in, licensing, and role assignments are stable.

## Power Platform environment, solutions, and Dataverse

- [ ] Confirm `workshop/automation/workshop-config.json` is populated with the real environment and SharePoint values, and that the Day 2 asset paths point to the helper-localized `workshop\assets` copies or another approved local folder.
- [ ] Confirm the target Power Platform environment exists.
- [ ] Confirm Dataverse is provisioned and healthy in the target environment.
- [ ] Confirm facilitators can create or open the workshop solution in the intended environment.
- [ ] Confirm facilitators can create or open agents, connections, and tables inside that solution.
- [ ] Confirm environment maker permissions are assigned to expected users.
- [ ] Confirm the localized Day 2 Hiring Agent files (`Operative_1_0_0_0.zip`, `job-roles.csv`, and `evaluation-criteria.csv`) are present locally before you begin the Lab 13 walkthrough in that environment.
- [ ] Confirm `pac auth list` shows the intended facilitator demo environment as the active profile before any optional solution import.
- [ ] Confirm at least one clean demo environment is reserved for live walkthroughs and any optional solution-package pre-staging.

**If unresolved:** Treat the environment as not ready for hands-on. Both workshop days depend on stable environment and solution access.

## SharePoint knowledge and Microsoft 365 content

- [ ] Confirm SharePoint is enabled in the tenant.
- [ ] Confirm the workshop SharePoint site is created and reachable.
- [ ] Confirm sample lists or sample document libraries are populated as needed.
- [ ] Confirm sample HR documents are uploaded for grounding and document-processing exercises.
- [ ] Confirm document links are stable and readable by the intended workshop accounts.
- [ ] Confirm the facilitator account can reach the SharePoint site or library picker from Copilot Studio knowledge setup.
- [ ] Confirm at least one SharePoint knowledge source can be attached or refreshed in the demo environment.

**If unresolved:** Switch the affected knowledge-grounding modules to facilitator demo only. If even the facilitator cannot attach SharePoint knowledge, the environment is not ready for that Day 1 path.

## Connectors, DLP, triggers, and email execution

- [ ] Confirm the SharePoint and Office 365 Outlook connectors are allowed by DLP policy in the target environment.
- [ ] Confirm required connections or connection references can be created or reused inside the workshop solution.
- [ ] Confirm the facilitator account can open the connector picker for flows, tools, and triggers without policy errors.
- [ ] Confirm a pre-staged agent flow can read from SharePoint, write back to SharePoint or Dataverse as expected, and return a response to the agent.
- [ ] Confirm a pre-staged trigger can fire from SharePoint or the intended event source in the demo environment.
- [ ] Confirm at least one workshop-safe email action can send to a monitored test mailbox.
- [ ] Confirm the escalation owner is known if connector approval or DLP policy changes at the last minute.

**If unresolved:** Mark Lab 09, Lab 10, and any email-dependent automation as demo-only. If the facilitator account cannot execute the recovery demo, treat the automation path as not ready.

## Teams and publishing surfaces

- [ ] Confirm Microsoft Teams is enabled for the workshop tenant.
- [ ] Confirm a Teams space or channel exists for workshop communications.
- [ ] Confirm facilitators can publish or demonstrate publishing to Teams if included.
- [ ] Confirm backup communication channel is ready if Teams access is inconsistent.

**If unresolved:** Switch publishing to a readiness walkthrough or facilitator demo. Do not let Teams drift block the rest of the room.

## MCP and developer tooling

- [ ] Confirm the Copilot Studio MCP onboarding wizard is visible in the target environment.
- [ ] Confirm at least one supported MCP server can be added in the demo environment.
- [ ] Confirm the facilitator account can complete the Microsoft 365 connection prompts needed for MCP labs.
- [ ] Confirm Visual Studio Code is installed on facilitator machines for the optional developer workflow.
- [ ] Confirm the Copilot Studio extension for Visual Studio Code is available on facilitator machines if Module 25 is included.

**If unresolved:** Switch MCP and VS Code extension modules to facilitator demo mode. If no facilitator account can open the wizard, treat those modules as not ready and replace them with discussion or screenshots.

## Evaluation readiness

- [ ] Confirm the built-in Evaluation experience opens in the target environment.
- [ ] Confirm the New evaluation flow allows a manual or import-based test set.
- [ ] Confirm the evaluation account can reuse the same knowledge, connections, and tools expected in the workshop.
- [ ] Confirm at least one sample evaluation can be started or completed in the demo environment.
- [ ] Confirm detailed results, graders, and activity-map-style diagnostics are visible for a completed or historical run.

**If unresolved:** Switch the evaluation module to facilitator demo mode. If the facilitator account cannot run or open evaluation, treat that module as not ready.

## Document generation readiness

- [ ] Confirm participants have **Microsoft Word desktop** (not Word Online) for Lab 21, or pre-stage the prebuilt `OfferLetterTemplate.docx` from `workshop/assets/Operative09StarterSolution.zip`.
- [ ] Confirm facilitators can distribute the extracted template to participants who lack Word desktop.

**If unresolved:** Distribute the prebuilt template before Lab 21 starts. Do not let Word desktop availability block the lab.

## Demo account and backup path

- [ ] Confirm a dedicated demo account is fully configured and validated end to end.
- [ ] Confirm the demo account has access to Copilot Studio, Dataverse, SharePoint, Teams, MCP, and Evaluation as applicable.
- [ ] Confirm the demo account includes the clean demo base plus any targeted recovery checkpoints, screenshots, or facilitator-owned snapshots needed for the riskiest modules.
- [ ] Confirm a second backup account is available in case the primary demo account fails.
- [ ] Confirm screenshots or a completed tenant snapshot exist for the highest-risk steps.

**If unresolved:** Treat the environment as not ready. A workshop without a validated recovery path will stall when the first tenant issue appears.

## Communications setup

- [ ] Send pre-event email with schedule, prerequisites, and sign-in expectations.
- [ ] Share required URLs, tenant guidance, and any software install steps in advance.
- [ ] Provide Day 1 and Day 2 readiness notes, including Day 2 dependency on Day 1 familiarity or Recruit-equivalent experience.
- [ ] Prepare a support message template for common sign-in, licensing, and environment issues.
- [ ] Prepare a visible “current lab and restart point” message for breaks.

## Room-readiness checks

- [ ] Confirm reliable internet for facilitator and attendees.
- [ ] Confirm projector, adapters, audio, and screen resolution are working.
- [ ] Confirm browser choice and pop-up settings will not block workshop tasks.
- [ ] Confirm a printed or offline copy of key screenshots is available for recovery use.

**If unresolved:** Treat the room as not ready even if the tenant checks are green.

## Virtual delivery preparation

Complete these items when delivering the workshop virtually with a single facilitator and 8–15 participants. These steps reduce the 25–35% virtual overhead that hands-on Copilot Studio labs carry compared to in-person delivery.

### One week before

- [ ] Audit every connector used across both days (SharePoint, Office 365 Outlook, Teams, Dataverse, HTTP) against the tenant DLP policy list in the Power Platform Admin Center. Get admin exceptions approved and applied before delivery.
- [ ] Pre-grant all participant accounts at least Contributor access to the lab SharePoint site used for knowledge grounding.
- [ ] Pre-grant MCP admin consent at the tenant level so participants do not hit a "needs admin approval" screen during the MCP onboarding wizard.
- [ ] Pre-enable custom app sideloading and app setup policies in the Teams Admin Center for the participant group.
- [ ] Run a full end-to-end dry run of both days using a participant-equivalent account, not a global admin account. Time each lab and document actual durations.
- [ ] Pre-import the Day 2 solution ZIP into a clean sandbox environment identical to participant environments and verify the agent appears with all topics.
- [ ] Build a Lab State Recovery document listing: (a) the direct environment URL with `environmentid` parameter for each lab, (b) a screenshot of each lab end state, and (c) a skip-ahead path for any lab that can be bypassed without breaking downstream labs.

### 48 hours before

- [ ] Run the automation scripts to pre-stage the Lab 00 SharePoint site, core lists, and sample data.
- [ ] Pre-create a temporary warm-up agent in each participant environment to pre-provision the backend. Delete the warm-up agent after backend provisioning completes. This eliminates the 1–10 minute first-agent provisioning delay that has no progress indicator.
- [ ] Pre-attach the lab SharePoint knowledge source to a facilitator template agent and allow it to index overnight. SharePoint indexing can take 15–60 minutes and blocks Lab 06 validation if not pre-seeded.
- [ ] Pre-import the Day 2 solution ZIP into at least two participant environments to validate import success and create a recovery fallback.
- [ ] Pre-create SharePoint, Office 365 Outlook, and Dataverse connector connections in the facilitator account to enable demo fallback for flow-based labs.
- [ ] Stage all self-paced support materials (Adaptive Card JSON scaffolds, flow templates, sample documents, Word templates) and verify download links work.

### Morning of Day 1

- [ ] Pin the direct Copilot Studio environment URL (including `?environmentid=XXXX`) in the virtual meeting chat before participants arrive.
- [ ] Confirm overnight SharePoint indexing completed by checking the facilitator template agent shows "Ready" status for the knowledge source.
- [ ] Prepare a shared troubleshooting document (OneNote or Loop) where stuck participants can paste error messages and screenshots while waiting for a screen-share slot. Share the link in chat before the first hands-on block.
- [ ] Post a "known platform lag" message template in chat: "If Copilot Studio feels slow, try Ctrl+Shift+R before assuming something is broken."
- [ ] Establish the troubleshooting protocol with participants: screen-share is the default, cap each debug session at 5 minutes, then move to a fallback path and follow up asynchronously.

### Morning of Day 2

- [ ] Confirm the MCP onboarding wizard is visible in a representative participant environment. If absent, pre-stage the manual Custom MCP Server workaround as a fallback handout.
- [ ] Confirm Dataverse tables are accessible in participant environments by testing record creation and deletion with a non-admin account.
- [ ] Confirm the Evaluation experience opens and the "New evaluation" flow starts without errors.
- [ ] Pre-download Day 2 CSV files (`job-roles.csv`, `evaluation-criteria.csv`) and share a direct download link in the meeting chat.

### Virtual pacing discipline

- [ ] Use explicit hold points at the end of each hands-on block. Post a "✅ Thumbs-up when you reach [checkpoint]" message in chat before releasing participants to work.
- [ ] Keep fast finishers busy with extension challenge questions rather than allowing them to advance to the next lab unsynchronized.
- [ ] Schedule the lightest content (demos, buffer, wrap-up) after the afternoon break to account for virtual fatigue.
- [ ] Budget 8–12 minutes per 90-minute hands-on block for screen-share troubleshooting overhead.

**If unresolved:** Virtual delivery without the pre-seeded SharePoint indexing, DLP audit, and MCP admin consent is high risk for a single facilitator. Treat these three items as go/no-go prerequisites.

## Final go/no-go review

- [ ] Continue hands-on only when core access, solution access, save/test, SharePoint knowledge, and the facilitator recovery path are green.
- [ ] Switch a module to demo mode only when the facilitator fallback has been validated in advance.
- [ ] Treat the environment as not ready when a core blocker is red or when a demo fallback has not been proven end to end.
- [ ] Capture known risks, workarounds, and escalation contacts before attendees arrive.
