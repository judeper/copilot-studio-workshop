# Screenshot Capture Checklist for Computer-Use Agent

## Instructions for the Computer-Use Agent

You are assisting a workshop facilitator who is doing a dry-run of a Microsoft Copilot Studio workshop. As the facilitator works through each lab, you will capture screenshots at specific moments. Each screenshot must be saved with the EXACT filename listed below, in the corresponding lab's `assets` subdirectory.

**Base path:** `C:\Dev\copilot-studio-workshop\workshop\labs\`

**Rules:**
- Capture the browser viewport showing the Copilot Studio UI (or other specified app)
- Crop to the relevant area described — don't include the full desktop unless specified
- Save as PNG format with the exact filename specified
- Focus on clarity: the screenshot should help a first-time user confirm they're on the right screen

---

## Day 1 Screenshots (Labs 00–12)

### Lab 00 — Environment Setup
**Directory:** `lab-00-environment-setup\assets\`

| # | Filename | When to Capture | What Should Be Visible |
|---|----------|----------------|----------------------|
| 1 | `lab-00-copilot-studio-home.png` | After signing in to Copilot Studio and selecting the workshop environment | The Copilot Studio home page with the environment selector visible in the top bar, showing the correct workshop environment name. The Create button and agent list area should be visible. |
| 2 | `lab-00-sharepoint-site.png` | During SharePoint site creation, after filling in the form | The SharePoint "Create a team site" form with: Site name = "Contoso IT", Description = "Copilot Studio workshop data source", the site address field, and the Language dropdown set to English. |

### Lab 01 — Intro to Agents
**Directory:** `lab-01-intro-to-agents\assets\`

| # | Filename | When to Capture | What Should Be Visible |
|---|----------|----------------|----------------------|
| 3 | `lab-01-agent-types.png` | During the concepts discussion | A slide or diagram showing the three agent types: conversational, conversational with actions, and autonomous. This can be a facilitator slide screenshot or a whiteboard diagram. |

### Lab 02 — Copilot Studio Fundamentals
**Directory:** `lab-02-copilot-studio-fundamentals\assets\`

| # | Filename | When to Capture | What Should Be Visible |
|---|----------|----------------|----------------------|
| 4 | `lab-02-copilot-studio-navigation.png` | After opening any agent in Copilot Studio | The agent canvas showing the top navigation tabs: Overview, Topics, Tools, Knowledge, Analytics, Channels, and Publish. The left sidebar should show the agent name. |

### Lab 03 — Declarative Agents
**Directory:** `lab-03-declarative-agents\assets\`

| # | Filename | When to Capture | What Should Be Visible |
|---|----------|----------------|----------------------|
| 5 | `lab-03-create-agent.png` | After filling in the declarative agent creation form | The agent setup screen with: Name = "Contoso Tech Support Pro", the Description field filled in, the Instructions text area with IT support instructions, and any starter prompt configuration. |
| 6 | `lab-03-published-agent.png` | After publishing and opening in M365 Copilot or Teams | The agent responding to an IT support question inside Microsoft 365 Copilot or Teams. The agent name should be visible and the response should show IT troubleshooting guidance. |

### Lab 04 — Solutions
**Directory:** `lab-04-solutions\assets\`

| # | Filename | When to Capture | What Should Be Visible |
|---|----------|----------------|----------------------|
| 7 | `lab-04-solution-explorer.png` | After creating the workshop solution | The Solution Explorer in make.powerapps.com showing the "Contoso Helpdesk Agent" solution with its components listed (agent, tables, flows, etc.). Publisher should show "Contoso Solutions". |

### Lab 05 — Prebuilt Agents
**Directory:** `lab-05-prebuilt-agents\assets\`

| # | Filename | When to Capture | What Should Be Visible |
|---|----------|----------------|----------------------|
| 8 | `lab-05-template-gallery.png` | After opening the template gallery | The agent template gallery in Copilot Studio with the "Safe Travels" template visible and highlighted. The gallery should show multiple template cards. |

### Lab 06 — Custom Agent
**Directory:** `lab-06-custom-agent\assets\`

| # | Filename | When to Capture | What Should Be Visible |
|---|----------|----------------|----------------------|
| 9 | `lab-06-custom-agent.png` | After creating the agent from natural language | The newly created custom agent's Overview page showing the agent name, the natural language description that was used to create it, and the initial configuration. |
| 10 | `lab-06-knowledge-sources.png` | After adding all knowledge sources | The Knowledge section showing: public website sources (Microsoft Support, Microsoft Learn), the SharePoint site source (Contoso IT) with its status indicator, and any file-based sources. The status should ideally show "Ready" for at least one source. |

### Lab 07 — Topics and Triggers
**Directory:** `lab-07-topics-triggers\assets\`

| # | Filename | When to Capture | What Should Be Visible |
|---|----------|----------------|----------------------|
| 11 | `lab-07-topic-canvas.png` | After building the "Available devices" topic | The topic authoring canvas showing: the trigger phrases at the top, the VarDeviceType input variable, the message node, and the SharePoint Get Items connector action with the filter for Status = 'Available'. |
| 12 | `lab-07-topic-test.png` | After successfully testing the topic | The Test pane showing: the user's test message "What laptops are available?", the agent's response listing available devices from SharePoint, and the yes/no follow-up question. |

### Lab 08 — Adaptive Cards
**Directory:** `lab-08-adaptive-cards\assets\`

| # | Filename | When to Capture | What Should Be Visible |
|---|----------|----------------|----------------------|
| 13 | `lab-08-adaptive-card.png` | After adding the Adaptive Card to the topic | The Adaptive Card displayed in the Copilot Studio topic designer, showing the card with device selection dropdown, manager email field, comments text input, and Submit button. |
| 14 | `lab-08-card-test.png` | After testing the card in the Test pane | The Test pane showing the Adaptive Card rendered with: a device selected in the dropdown, a manager email entered, a comment typed, and the Submit button visible. The conversation flow before the card should show the device query results. |

### Lab 09 — Agent Flows
**Directory:** `lab-09-agent-flows\assets\`

| # | Filename | When to Capture | What Should Be Visible |
|---|----------|----------------|----------------------|
| 15 | `lab-09-agent-flow.png` | After building the Power Automate flow | The Power Automate flow designer showing: the agent trigger at the top, the SharePoint "Get Item" action, the "Create Item" action for Device Requests, the "Update Item" action for Devices, and the "Send an Email" action. All actions should be connected in sequence. |
| 16 | `lab-09-topic-mapping.png` | After mapping Adaptive Card outputs to flow inputs | The topic node in Copilot Studio showing the flow tool with input mappings: DeviceSharePointId mapped from the card, ManagerEmail mapped, RequesterName mapped from System.User.DisplayName, and AdditionalComments mapped. |

### Lab 10 — Event Triggers
**Directory:** `lab-10-event-triggers\assets\`

| # | Filename | When to Capture | What Should Be Visible |
|---|----------|----------------|----------------------|
| 17 | `lab-10-event-trigger.png` | After configuring the SharePoint event trigger | The trigger configuration showing: trigger name "New Support Ticket Created in SharePoint", the SharePoint connector, Site Address set to the Contoso IT site, and List Name set to "Tickets". |

### Lab 11 — Publish Agent
**Directory:** `lab-11-publish-agent\assets\`

| # | Filename | When to Capture | What Should Be Visible |
|---|----------|----------------|----------------------|
| 18 | `lab-11-publish.png` | After publishing and adding the Teams channel | The Channels tab showing Microsoft Teams channel added, with the publish confirmation visible or the channel status showing as active. |
| 19 | `lab-11-teams-open.png` | After opening the agent in Microsoft Teams | The agent running inside Microsoft Teams, showing the agent name in the chat header and a response to a test message. The Teams interface should be clearly visible. |

### Lab 12 — Licensing
**Directory:** `lab-12-licensing\assets\`

| # | Filename | When to Capture | What Should Be Visible |
|---|----------|----------------|----------------------|
| 20 | `lab-12-licensing-overview.png` | During the licensing discussion | A facilitator slide or diagram showing the licensing decision tree: Copilot Credits, Capacity packs, Pay-as-you-go, and Microsoft 365 Copilot user licenses. This can be a presentation screenshot. |

---

## Day 2 Screenshots (Labs 13–25)

### Lab 13 — Hiring Agent Setup
**Directory:** `lab-13-hiring-agent-setup\assets\`

| # | Filename | When to Capture | What Should Be Visible |
|---|----------|----------------|----------------------|
| 21 | `lab-13-solution-import.png` | After successfully importing the Operative solution | The Solutions page showing the imported Operative solution with a success indicator. The solution name, publisher, and version should be visible. |
| 22 | `lab-13-sample-data.png` | After creating sample candidates and applications | The Hiring Hub model-driven app showing sample data: candidate records (Jordan Lee, Casey Bennett) and their linked job applications. The data grid should show populated rows. |
| 23 | `lab-13-agent-details.png` | After creating and configuring the Hiring Agent | The Hiring Agent's Overview page showing: agent name "Hiring Agent", description "Central orchestrator for the Contoso hiring process", and Settings showing Orchestration=Yes, File uploads=On, Web search=Off, Moderation=High. |

### Lab 14 — Agent Instructions
**Directory:** `lab-14-agent-instructions\assets\`

| # | Filename | When to Capture | What Should Be Visible |
|---|----------|----------------|----------------------|
| 24 | `lab-14-instructions-editor.png` | After opening the instructions editor | The Instructions card in the Hiring Agent Overview, with the instruction text area visible and the edit interface open. |
| 25 | `lab-14-test-pane.png` | After testing instruction behavior | The Test pane showing: a hiring-related question, the agent's response staying within the hiring domain, and evidence that the instructions are shaping the response. |

### Lab 15 — Multi-Agent
**Directory:** `lab-15-multi-agent\assets\`

| # | Filename | When to Capture | What Should Be Visible |
|---|----------|----------------|----------------------|
| 26 | `lab-15-agent-topology.png` | After reviewing the multi-agent architecture | A diagram or the Copilot Studio UI showing the Hiring Agent as orchestrator with Application Intake Agent and Interview Prep Agent as connected specialist agents. |
| 27 | `lab-15-activity-map.png` | After testing delegation between agents | The Activity map in the Test pane showing the delegation flow: user request → Hiring Agent → specialist agent handoff → specialist response. The routing decision should be visible. |

### Lab 16 — Trigger Automation
**Directory:** `lab-16-trigger-automation\assets\`

| # | Filename | When to Capture | What Should Be Visible |
|---|----------|----------------|----------------------|
| 28 | `lab-16-sharepoint-library.png` | After creating the Incoming Resumes library | The SharePoint document library named "Incoming Resumes" with at least one sample PDF uploaded. The library view and column headers should be visible. |
| 29 | `lab-16-trigger-flow.png` | After building the resume automation flow | The Power Automate flow showing: the SharePoint "When a file is created" trigger, the PDF filter condition, Get file content action, Dataverse Create row action, file upload action, and Teams notification card. |

### Lab 17 — Model Selection
**Directory:** `lab-17-model-selection\assets\`

| # | Filename | When to Capture | What Should Be Visible |
|---|----------|----------------|----------------------|
| 30 | `lab-17-model-comparison.png` | After comparing models | The model selector dropdown or a side-by-side comparison view showing different model options (GPT-5 Chat, GPT-4.1, Claude Sonnet 4.5). If no comparison UI exists, capture the model dropdown with available options visible. |

### Lab 18 — Content Moderation
**Directory:** `lab-18-content-moderation\assets\`

| # | Filename | When to Capture | What Should Be Visible |
|---|----------|----------------|----------------------|
| 31 | `lab-18-conversation-start.png` | After updating the Conversation Start topic | The Conversation Start system topic showing the updated greeting message with AI disclosure text, capability list, and the note about responses potentially containing errors. |
| 32 | `lab-18-prompt-sensitivity.png` | After configuring per-prompt content moderation | The prompt builder for "Candidate Screening Notes" showing the content moderation slider set to High. The single Low/Moderate/High slider should be visible in the prompt Settings panel. |
| 33 | `lab-18-red-team-tests.png` | After running the red-team test set | The Test pane showing at least one adversarial prompt being blocked or redirected by the moderation system. The blocking message or refusal should be clearly visible. Alternatively, a worksheet or notes view showing test results across multiple prompts. |

### Lab 19 — Multimodal Prompts
**Directory:** `lab-19-multimodal-prompts\assets\`

| # | Filename | When to Capture | What Should Be Visible |
|---|----------|----------------|----------------------|
| 34 | `lab-19-prompt-builder.png` | After configuring the multimodal prompt | The Prompt builder showing: prompt name "Resume Vision Analysis", the instruction text for extracting resume data, the ResumeFile input parameter configured as Image/Document type, Output type set to JSON, and the model selection. |
| 35 | `lab-19-json-output.png` | After testing with a PDF resume | The prompt test results showing structured JSON output with extracted resume fields (name, skills, experience, education). The JSON should show actual data extracted from the test resume, not placeholder values. |

### Lab 20 — Dataverse Grounding
**Directory:** `lab-20-dataverse-grounding\assets\`

| # | Filename | When to Capture | What Should Be Visible |
|---|----------|----------------|----------------------|
| 36 | `lab-20-job-requisitions-table.png` | After creating and populating the Job Requisitions table | The Dataverse table view in Power Apps showing the Job Requisitions table with columns (Requisition Number, Job Title, Department, Location, Hiring Manager, Status) and at least 2 rows of sample data with Status = "Open". |
| 37 | `lab-20-grounded-prompt.png` | After testing grounded matching | The prompt test results showing: the Knowledge used pane expanded with Dataverse requisition data visible in context, and the JSON output containing real requisition numbers that match the Dataverse table. |

### Lab 21 — Document Generation
**Directory:** `lab-21-document-generation\assets\`

| # | Filename | When to Capture | What Should Be Visible |
|---|----------|----------------|----------------------|
| 38 | `lab-21-offer-template.png` | After creating the Word template | The Word document showing the offer letter layout with visible Plain Text Content Controls. The control tags/labels (CandidateName, JobTitle, Department, etc.) should be visible in design mode. |
| 39 | `lab-21-offer-flow.png` | After building the document generation flow and topic | The Copilot Studio topic "Create Offer Letter" showing the flow connection with input variable mappings, or the Power Automate flow showing the document generation actions connected to the Word template. |

### Lab 22 — MCP Integration
**Directory:** `lab-22-mcp-integration\assets\`

| # | Filename | When to Capture | What Should Be Visible |
|---|----------|----------------|----------------------|
| 40 | `lab-22-mcp-tools.png` | After adding MCP servers to the Interview Prep Agent | The Tools tab of the Interview Prep Agent showing the configured MCP tools: Microsoft 365 User Profile and Outlook Calendar servers. Connection status should show as connected/authenticated. |

### Lab 23 — User Feedback
**Directory:** `lab-23-user-feedback\assets\`

| # | Filename | When to Capture | What Should Be Visible |
|---|----------|----------------|----------------------|
| 41 | `lab-23-feedback-card.png` | After building the feedback Adaptive Card topic | The Adaptive Card rendered in the Test pane or topic designer showing: feedback reason options (Incomplete, Inaccurate, Irrelevant, Confusing), a text input for additional comments, and a Submit button. |
| 42 | `lab-23-feedback-review.png` | After reviewing feedback in Analytics | The Analytics tab showing the Satisfaction section with reactions data, or the Activity tab showing a session where the feedback card was submitted with the captured values visible. |

### Lab 24 — Agent Evaluation
**Directory:** `lab-24-agent-evaluation\assets\`

| # | Filename | When to Capture | What Should Be Visible |
|---|----------|----------------|----------------------|
| 43 | `lab-24-evaluation-start.png` | After creating the test set and starting evaluation | The Evaluation tab showing: the test set "Hiring Agent - Day 2 QA Baseline" with 5+ test cases listed, the selected graders, and the Evaluate button or a running/completed evaluation status. |
| 44 | `lab-24-evaluation-results.png` | After reviewing evaluation results | A detailed test result view showing: a failed test case with expected vs. actual response, the grader reasoning, and the Activity map expanded showing the agent's decision sequence. The "Compare with" option or improvement metrics should be visible if a second run was completed. |

### Lab 25 — VS Code Extension
**Directory:** `lab-25-vscode-extension\assets\`

| # | Filename | When to Capture | What Should Be Visible |
|---|----------|----------------|----------------------|
| 45 | `lab-25-vscode-clone.png` | After cloning the agent into VS Code | The VS Code window showing: the Copilot Studio extension sidebar, the cloned Hiring Agent workspace with YAML files visible in the Explorer, and the Agent Changes pane showing the remote agent state. |
| 46 | `lab-25-vscode-apply.png` | After applying changes and validating | The VS Code Agent Changes pane showing local changes ready to apply, or the Copilot Studio browser showing the updated instructions after syncing from VS Code. |

---

## Summary

| Day | Labs | Screenshots |
|-----|------|:-----------:|
| Day 1 | Labs 00–12 | 20 |
| Day 2 | Labs 13–25 | 26 |
| **Total** | **26 labs** | **46** |

## Capture Tips

- Use browser zoom at 100% for consistency
- Ensure the environment name is visible in the top bar when capturing Copilot Studio screens
- For Test pane screenshots, start a fresh test session so the conversation is clean
- For Power Automate flow screenshots, collapse completed actions and expand the one being documented
- For model-driven app screenshots, sort data so sample records are visible
- Save immediately after capture — don't batch saves
