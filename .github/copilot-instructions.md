# Copilot Instructions for Copilot Studio Workshop

## Working context

- The repository root contains a `README.md` with the workshop overview, lab index, and quick start, plus signing artifacts and the `workshop\` package.
- Most editable content lives under `workshop\`; treat this as a documentation-first workshop repository, not a conventional application repo. Most changes are Markdown; the executable code is the facilitator PowerShell in `workshop\automation`.

## Commands

- Before running facilitator automation, copy `workshop\automation\workshop-config.example.json` to `workshop\automation\workshop-config.json` and replace the tenant, environment, SharePoint, and Day 2 asset placeholders.
- Install local prerequisites:
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
- Generate branded PDF files for students and facilitators (requires Node.js and npm):
  - `cd workshop\automation && npm install && node Generate-WorkshopPDFs.js`
  - Output: `workshop\pdf-output\` (10 numbered PDFs: 4 student, 6 facilitator)
  - Selective generation: `node Generate-WorkshopPDFs.js --only S2,F1`
- No package-based build or lint command exists under `workshop`.
- No automated test runner exists. The closest single-test equivalents are:
  - a targeted dry run with `powershell -File .\workshop\automation\Import-WorkshopOperativeAssets.ps1`
  - one check from `workshop\tests\environment-smoke-tests.md`
  - the `Validation` section in the specific lab README you changed

## High-level architecture

- `workshop\participant-guide` defines the learner journey, the mixed audience, and the Day 1 to Day 2 progression.
- `workshop\facilitator-guide` contains delivery flow, environment readiness, fallback paths, and the repo's authoring guardrails.
- `workshop\labs` is the source of truth for hands-on content:
  - Labs `00`-`12` are the Day 1 Recruit track. They establish the environment, build the `Contoso Helpdesk Agent`, and layer SharePoint grounding, topics, Adaptive Cards, flows, triggers, publishing, and licensing.
  - Labs `13`-`24` are the Day 2 Operative track. They import the `Operative` solution, use Dataverse and the `Hiring Hub` app, then extend the `Hiring Agent` with instructions, multi-agent behavior, automation, model selection, moderation, multimodal prompts, document generation, MCP, feedback, and evaluation.
  - Lab `25` is an optional VS Code workflow that edits the cloud agent definition locally and syncs it back to Copilot Studio.
- `workshop\automation` is for facilitator or demo preparation, not for skipping the student journey. `StudentReady` intentionally leaves later student-owned work unfinished, while `FacilitatorDemo` can pre-stage Day 2 assets in a separate demo environment. `Generate-WorkshopPDFs.js` produces 10 branded PDFs (4 student workbooks + 6 facilitator references) from the Markdown sources into `workshop\pdf-output\`.
- `workshop\assets` contains the Day 2 setup files (`Operative_1_0_0_0.zip`, `job-roles.csv`, `evaluation-criteria.csv`), sample resumes, starter templates, and the `evaluation-test-cases.csv` template for Lab 24. Lab 13 points participants to the local `workshop/assets/` copies first, with facilitator-provided delivery channels as a fallback.
- `workshop\tests` holds manual readiness and validation checklists. Use it as the canonical success/failure reference when editing lab steps or troubleshooting guidance.
- Day 2 assumes Day 1 completion, the Recruit badge, or equivalent Copilot Studio familiarity. Preserve that dependency when restructuring docs.

## Key conventions

- Keep the canonical scenario names unchanged: `Contoso IT`, `Contoso Helpdesk Agent`, `Hiring Agent`, `Operative`, `Hiring Hub`, and `AgentCreators`.
- Preserve the two-day narrative. Day 1 is foundation-building; Day 2 is the governed enterprise extension of that same scenario, not a reset.
- Labs follow a stable structure: time estimate near the top, then `Overview`, `Prerequisites`, detailed steps, `Validation`, `Troubleshooting`, and `Facilitator Notes`, with screenshots stored under each lab's `assets` folder as `lab-NN-*.png`.
- Use `[Maker]`, `[IT Pro]`, and `[Developer]` only when the guidance truly differs. The default workshop flow is shared across roles; Lab 25 is the main developer-only stretch path.
- Keep participant-facing docs flat and scannable. The repo's internal authoring guide in `workshop\facilitator-guide\gpt54-agent-prompting.md` explicitly avoids nested bullets in participant docs and uses callouts only when they improve execution. This file is internal-only and must not be linked from participant-facing lab content.
- Prefer generally available platform guidance. The repo standard is `GPT-5 Chat` as the baseline model when available in the participant's region, with `GPT-4.1` (labeled "Default" in the picker) as the explicit GA fallback. Use current GA terminology such as the unified activity and transcript view, and the in-product MCP onboarding wizard rather than hand-editing secrets or describing non-GA flows. Per-prompt content moderation uses a single Low/Moderate/High slider covering all four harm categories collectively.
- When you change instructions, model guidance, or validation prompts, expect fresh Copilot Studio sessions to matter. Multiple labs and the validation checklist require `New test session` after changes so stale conversation context does not hide regressions.
- If you touch facilitator automation, keep `pac` imports pointed at a separate facilitator demo environment and verify the active `pac` profile first. SharePoint automation assumes PnP PowerShell sign-in, with `DeviceLogin` as the default login mode unless `workshop-config.json` says otherwise.
- If you edit the MCP or VS Code content, keep the browser-based Copilot Studio path as the core workshop flow. The VS Code extension is optional, and MCP setup should continue to use the supported wizard plus narrow, governed Microsoft 365 servers.
