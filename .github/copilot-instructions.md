# Copilot Instructions for Copilot Studio Workshop

## Working context

- The repository root contains a `README.md` with the workshop overview, lab index, and quick start, plus signing artifacts and the `workshop\` package.
- Most editable content lives under `workshop\`; treat this as a documentation-first workshop repository, not a conventional application repo. Most changes are Markdown; the executable code is the facilitator PowerShell in `workshop\automation`.
- The workshop also includes a committed PowerPoint slide corpus in `workshop\Copilot-Studio-Workshop-Slides\` with 13 module decks. Treat those PPTX files as first-class repo assets when slide work is in scope.

## Commands

- **First-time setup on a fresh machine** — open PowerShell and run: `mkdir C:\workshop; cd C:\workshop`, then `irm https://raw.githubusercontent.com/judeper/copilot-studio-workshop/master/workshop/automation/Invoke-WorkshopBootstrap.ps1 -OutFile .\Bootstrap.ps1`, then `.\Bootstrap.ps1`. The wizard installs PS 7 (if needed), git, pac CLI, Node.js via winget, clones the repo, installs PowerShell modules, auto-creates an Entra app registration with required permissions, walks through config interactively, downloads assets, and validates everything.
- If the repo is already cloned, run the wizard directly:
  - `pwsh -File .\workshop\automation\Invoke-WorkshopBootstrap.ps1`
- After the bootstrap wizard completes, the individual scripts can be run separately:
- Install local prerequisites (if not using the bootstrap wizard):
  - `powershell -File .\workshop\automation\Install-WorkshopPrerequisites.ps1`
- Download the Day 2 setup assets into `workshop\assets`:
  - `powershell -File .\workshop\automation\Get-WorkshopDay2Assets.ps1`
- Validate local tools, config values, and Day 2 asset paths:
  - `powershell -File .\workshop\automation\Invoke-WorkshopPrereqCheck.ps1`
- Dry-run the shared setup without changing the environment:
  - `powershell -File .\workshop\automation\Invoke-WorkshopLabSetup.ps1 -ValidateOnly -Mode StudentReady`
- Pre-stage the shared Day 1 prerequisites:
  - `powershell -File .\workshop\automation\Invoke-WorkshopLabSetup.ps1 -Mode StudentReady`
- Bootstrap a facilitator-owned Power Platform environment when the config includes `EnvironmentBootstrap`:
  - `powershell -File .\workshop\automation\Initialize-WorkshopPowerPlatformEnvironment.ps1 -CreateEnvironment`
- Validate only the Lab 13 import inputs:
  - `powershell -File .\workshop\automation\Import-WorkshopOperativeAssets.ps1`
- Import the Operative solution into the active demo environment:
  - `powershell -File .\workshop\automation\Import-WorkshopOperativeAssets.ps1 -ImportSolution`
- Keep facilitator demo preparation and student hands-on preparation separate. The repo currently optimizes for a clean validated facilitator demo base, not a fully prebuilt “all labs completed” fallback environment.
- Generate branded PDF files for students and facilitators (requires Node.js and npm):
  - `cd workshop\automation && npm install && node Generate-WorkshopPDFs.js`
  - Output: `workshop\pdf-output\` (10 numbered PDFs: 4 student, 6 facilitator)
  - Selective generation: `node Generate-WorkshopPDFs.js --only S2,F1`
- Batch-provision per-student environments (requires Entra app with certificate auth, `Identity.ParticipantEmails` populated):
  - `powershell -File .\workshop\automation\Invoke-StudentEnvironmentProvisioning.ps1`
  - Each student gets: Sandbox environment with Dataverse (`D365_CDSSampleApp`), SharePoint TeamSite, Teams team, 25K Copilot credits, Environment Maker role
  - Validate-only: `powershell -File .\workshop\automation\Invoke-StudentEnvironmentProvisioning.ps1 -ValidateOnly`
- Tear down student environments after the workshop:
  - `powershell -File .\workshop\automation\Remove-StudentEnvironments.ps1 -HardDelete`
- No package-based build or lint command exists under `workshop`.
- No automated test runner exists. The closest single-test equivalents are:
  - a targeted dry run with `powershell -File .\workshop\automation\Import-WorkshopOperativeAssets.ps1`
  - one check from `workshop\tests\environment-smoke-tests.md`
  - the `Validation` section in the specific lab README you changed

## Automation architecture

### Common.ps1 shared utilities
- `Common.ps1` is dot-sourced by all automation scripts and provides: config I/O (`Get-WorkshopConfig`, `Save-WorkshopConfig`), validation helpers (`Get-RequiredString`, `Test-PlaceholderValue`), module/command guards (`Require-Module`, `Require-Command`), console output (`Write-Section`, `Write-StepResult`), logging (`Initialize-WorkshopLog`, `Write-Log`), native-process wrappers (`Invoke-NativeCommand`), student-provisioning auth helpers (`Get-CurrentUserCertificate`, `New-WorkshopSelfSignedCertificate`, `Resolve-ConfiguredClientSecret`, `Set-UserEnvironmentVariable`, `Test-AppOnlyCertificateReadiness`), student-provisioning building blocks (`Get-StudentAlias`, `Get-SafeGroupAlias`, `Get-SafeSiteAlias`, `Get-SafeDomainName`, `Get-PacEnvironmentListJson`, `Find-PacEnvironmentByDomainName`, `Resolve-EnvironmentGuid`, `Get-PowerPlatformAccessToken`, `Set-EnvironmentCopilotCredits`, `Confirm-EnvironmentCopilotCredits`, `Invoke-WithRetry`, `Save-StudentEnvironmentMap`, `Read-StudentEnvironmentMap`), and Entra security group management (`Ensure-SecurityGroup`).
- `Initialize-WorkshopSiteContent.ps1` is a reusable function library (dot-sourced, not run standalone) that creates all workshop SharePoint lists, field schemas, and sample data on the currently connected site. It is called by both `Initialize-WorkshopSharePoint.ps1` (shared facilitator site) and `Invoke-StudentEnvironmentProvisioning.ps1` (per-student sites) to ensure identical schema and sample data everywhere. The main entry point is `Initialize-WorkshopSiteContent -Config $config`.
- When adding new shared functions, follow the existing patterns in `Common.ps1`: mandatory parameter attributes, `[CmdletBinding()]` on scripts, `$ErrorActionPreference = 'Stop'`, and `Set-StrictMode -Version Latest` at the top of each script.

### Config schema (workshop-config.example.json)
- Top-level keys: `TenantId`, `EnvironmentUrl`, `EnvironmentBootstrap`, `SharePoint`, `Teams`, `Identity`, `Workshop`, `Day1`, `Day2`.
- `EnvironmentBootstrap` contains: `DisplayName`, `Type`, `DomainName`, `Region`, `Currency`, `Language`, `AdminUser`, `SecurityGroupId`, `CopilotStudioCreditsPerEnvironment`, `BatchSize`, `PreProvisionDayBefore`.
- `SharePoint` contains: `AdminUrl`, `SiteUrl`, `SiteTitle`, `SiteAlias`, `SitePrefix`, `SiteDescription`, `PnPClientId`, `PnPLoginMode`, `PnPCertificateThumbprint`.
- `Teams` contains: `WorkshopTeamName`, `StudentTeamPrefix`.
- `Identity` contains: `AgentCreatorsGroupName`, `ParticipantEmails` (array of student email addresses for batch provisioning), `ClientSecret`, and `ClientSecretEnvVar`.
- `Workshop` contains: `Wave`, `Concurrency`.
- When adding new config fields, add them to `workshop-config.example.json` with placeholder values and document them in the facilitator guide.

### Batch student provisioning
- `Invoke-StudentEnvironmentProvisioning.ps1` is the 12-phase batch orchestrator that provisions per-student Power Platform Sandbox environments with Dataverse, SharePoint TeamSites (with full schema and sample data via `Initialize-WorkshopSiteContent`), Teams teams, Copilot Studio credits, Environment Maker roles, and AgentCreators security group membership. It uses `Get-SafeGroupAlias` (no hyphens, for M365 Group mailNickname) and `Get-SafeSiteAlias` (hyphens OK, for SharePoint URL) to generate the split `-Alias`/`-SiteAlias` pattern for `New-PnPSite -Type TeamSite`. Environment creation uses `pac admin create --templates "D365_CDSSampleApp"` to trigger Dataverse provisioning; this template is enabled for `unitedstates` but may be disabled in other regions.
- Per-student SharePoint sites get the **same full schema and sample data** as the shared facilitator site: Devices list (10 custom columns + 4 sample items with Status choices Available/Requested/Retired), Tickets list (3 custom columns + 1 sample item), Device Requests list (7 custom columns), and Incoming Resumes document library. This ensures Labs 06-10 work identically on student-specific sites.
- `Remove-StudentEnvironments.ps1` tears down all student resources. With `-HardDelete`, it permanently purges M365 Groups from the Entra recycle bin (`Remove-PnPDeletedMicrosoft365Group`), SharePoint sites from the site recycle bin (`Remove-PnPTenantDeletedSite -Force`), and deletes Power Platform environments.
- `Ensure-SecurityGroup` in Common.ps1 creates the AgentCreators Entra security group (if missing) and adds participant emails as members. Requires `Connect-MgGraph` with `Group.ReadWrite.All` permission.
- The bootstrap wizard now prepares student-provisioning auth by reusing/importing/creating a certificate, registering its public key on the workshop Entra app, and optionally storing a client secret in the configured user environment variable.
- Student provisioning should try SharePoint app-only site creation and site-content initialization first, but when the tenant rejects those app-only calls it must fall back to delegated PnP login (`OSLogin`, `Interactive`, or `DeviceLogin`), grant the delegated facilitator account site-collection-admin access alongside the student, and then retry against the existing site instead of pretending the tenant cmdlets are still unattended.
- `Get-SafeDomainName` must preserve a unique student alias inside the 24-character Power Platform domain limit. Do not truncate away the student alias; shorten the shared prefix first when necessary.
- Environment resolution and reruns should use `pac admin list --json` / `Find-PacEnvironmentByDomainName` so partially created environments can be reused instead of recreated blindly.
- Student map entries with failed statuses must remain retryable. Only `Completed` entries should be skipped automatically on rerun, and retries must preserve any recorded `EnvironmentUrl`, `EnvironmentGuid`, and `SharePointUrl` so a partially provisioned student can resume from the existing environment or site instead of starting over.
- The Licensing API (`https://api.powerplatform.com`) requires a separate access token from the Graph and PnP sessions. Use `Get-PowerPlatformAccessToken` for client-credentials token acquisition scoped to `https://api.powerplatform.com/.default`. The currency type for Copilot Studio credits is `MCSSessions` (confirmed in the official `ExternalCurrencyType` enum), wrapped in `currencyAllocations`.
- Multi-service auth from a single Entra app requires separate tokens per API resource: `https://api.powerplatform.com/.default` for Licensing API, `Connect-MgGraph` (app-only certificate, no `-Scopes`) for Graph/Teams, `Connect-PnPOnline` for SharePoint, and `Add-PowerAppsAccount` for PowerApps admin cmdlets. These sessions do not share tokens and do not interfere.

## High-level architecture

- `workshop\participant-guide` defines the learner journey, the mixed audience, and the Day 1 to Day 2 progression.
- `workshop\facilitator-guide` contains delivery flow, environment readiness, fallback paths, and the repo's authoring guardrails.
- `workshop\Copilot-Studio-Workshop-Slides` contains the committed PPTX slide corpus for live delivery: 13 module decks (`Module-00` through `Module-12`) and 95 slides total.
- `workshop\assets\slide-deck-outline.md` is the canonical instructor presentation narrative and the text-first companion to the PPTX decks. Use it for speaker notes, teaching intent, and structural review, and keep it aligned with the PPTX decks when slide sequencing, module boundaries, or teaching intent changes.
- `workshop\assets\slide-deck-delivery-notes.md` and `workshop\assets\slide-deck-visual-plan.md` are companion markdown sources for speaker support, transition planning, and visual planning.
- `workshop\labs` is the source of truth for hands-on content:
  - Labs `00`-`12` are the Day 1 Recruit track. They establish the environment, build the `Contoso Helpdesk Agent`, and layer SharePoint grounding, topics, Adaptive Cards, flows, triggers, publishing, and licensing.
  - Labs `13`-`24` are the Day 2 Operative track. They import the `Operative` solution, use Dataverse and the `Hiring Hub` app, then extend the `Hiring Agent` with instructions, multi-agent behavior, automation, model selection, moderation, multimodal prompts, document generation, MCP, feedback, and evaluation.
  - Lab `25` is an optional VS Code workflow that edits the cloud agent definition locally and syncs it back to Copilot Studio.
- `workshop\automation` is for facilitator or demo preparation, not for skipping the student journey. `StudentReady` intentionally leaves later student-owned work unfinished, while `FacilitatorDemo` can pre-stage Day 2 assets in a separate demo environment. `Generate-WorkshopPDFs.js` produces 10 branded PDFs (4 student workbooks + 6 facilitator references) from the Markdown sources into `workshop\pdf-output\`.
- Future edits should preserve the three-track rollout model: shared prerequisites, facilitator-only demo base, and student hands-on environments. Do not blur facilitator demo imports or fallback artifacts into the student hands-on path.
- The facilitator guide now includes a quick runbook for new facilitators. Keep that section sequence-first, concise, and aligned with the more detailed environment checklist.
- `workshop\automation\Common.ps1` is the shared utility module dot-sourced by all PowerShell scripts. It contains config I/O, validation helpers, console and file logging, and building blocks for batch student provisioning (alias derivation, environment GUID resolution, Power Platform Licensing API wrappers, retry logic, and student-environment map persistence).
- `workshop\automation\workshop-config.example.json` defines the full config schema including `EnvironmentBootstrap` (environment creation settings and per-student credit allocation), `SharePoint` (site creation and PnP auth), `Teams` (team prefix for student teams), `Identity` (participant email list for batch provisioning), and `Workshop` (wave and concurrency settings).
- `workshop\assets` contains the Day 2 setup files (`Operative_1_0_0_0.zip`, `job-roles.csv`, `evaluation-criteria.csv`), sample resumes, starter templates, and the `evaluation-test-cases.csv` template for Lab 24. Lab 13 points participants to the local `workshop/assets/` copies first, with facilitator-provided delivery channels as a fallback.
- `workshop\tests` holds manual readiness and validation checklists. Use it as the canonical success/failure reference when editing lab steps or troubleshooting guidance.
- Day 2 assumes Day 1 completion, the Recruit badge, or equivalent Copilot Studio familiarity. Preserve that dependency when restructuring docs.

## Key conventions

- Keep the canonical scenario names unchanged: `Contoso IT`, `Contoso Helpdesk Agent`, `Hiring Agent`, `Operative`, `Hiring Hub`, and `AgentCreators`.
- Preserve the two-day narrative. Day 1 is foundation-building; Day 2 is the governed enterprise extension of that same scenario, not a reset.
- When slide work is in scope, inspect the committed PPTX decks together with the markdown source set: `workshop\assets\slide-deck-outline.md`, `slide-deck-delivery-notes.md`, and `slide-deck-visual-plan.md`. PPTX is the delivery format; the markdown files are companion authoring and review sources.
- Preserve the existing slide formatting when updating PPTX assets. New or revised slides should match the current deck colors, layout patterns, and design treatment rather than creating a new visual system.
- Labs follow a stable structure: time estimate near the top, then `Overview`, `Prerequisites`, detailed steps, `Validation`, `Troubleshooting`, and `Facilitator Notes`, with screenshots stored under each lab's `assets` folder as `lab-NN-*.png`.
- Use `[Maker]`, `[IT Pro]`, and `[Developer]` only when the guidance truly differs. The default workshop flow is shared across roles; Lab 25 is the main developer-only stretch path.
- Keep participant-facing docs flat and scannable. The repo's internal authoring guide in `workshop\facilitator-guide\gpt54-agent-prompting.md` explicitly avoids nested bullets in participant docs and uses callouts only when they improve execution. This file is internal-only and must not be linked from participant-facing lab content.
- Prefer generally available platform guidance. The repo standard is `GPT-5 Chat` as the baseline model when available in the participant's region, with `GPT-4.1` (labeled "Default" in the picker) as the explicit GA fallback. Use current GA terminology such as the unified activity and transcript view, and the in-product MCP onboarding wizard rather than hand-editing secrets or describing non-GA flows. Per-prompt content moderation uses a single Low/Moderate/High slider covering all four harm categories collectively.
- When you change instructions, model guidance, or validation prompts, expect fresh Copilot Studio sessions to matter. Multiple labs and the validation checklist require `New test session` after changes so stale conversation context does not hide regressions.
- If you touch facilitator automation, keep `pac` imports pointed at a separate facilitator demo environment and verify the active `pac` profile first. SharePoint automation assumes PnP PowerShell sign-in with `OSLogin` (Windows native WAM) as the default login mode and automatic fallback to `DeviceLogin`. The bootstrap wizard programmatically creates the SharePoint `oauth2PermissionGrant` (`AllSites.FullControl` scope) to ensure PnP gets `TenantAdmin` connection type — without this grant, all tenant admin operations fail with "unauthorized operation" even for Global Admins. In `Initialize-WorkshopSharePoint.ps1`, preserve an explicit SharePoint admin PnP connection for tenant cmdlets such as `Get-PnPTenantSite`; `DeviceLogin` cannot reliably auto-switch from tenant-root or site context back to the admin center.
- If you edit the MCP or VS Code content, keep the browser-based Copilot Studio path as the core workshop flow. The VS Code extension is optional, and MCP setup should continue to use the supported wizard plus narrow, governed Microsoft 365 servers.
