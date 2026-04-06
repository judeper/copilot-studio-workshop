# Validation Checklist

Use this facilitator-facing checklist to validate each lab as it is completed, recover quickly from common setup issues, and decide when a blocker needs escalation instead of more participant troubleshooting. Treat the generally available workshop path as the baseline, use GPT-5 Chat as the hands-on model when it is available, and keep non-GA features out of the core validation path.

## Lab 00 — Environment Setup
### Pre-conditions
- Participant has a work or school Microsoft 365 account.
- Copilot Studio and Microsoft 365 portals are reachable in the browser.
- Participant can create or access the intended Power Platform developer environment.
- SharePoint site creation is permitted or a pre-created workshop site is available.
- Facilitator has backup tenant or backup environment access if self-service setup fails.

### Success Criteria
1. Copilot Studio opens in the intended developer environment without access errors.
2. The Woodgrove Bank SharePoint site exists and the Customer Accounts list contains sample device records.
3. The Service Requests list exists with at least one sample service request and the site URL is captured for later labs.

### Common Failure Modes
| Symptom | Root Cause | Resolution |
| --- | --- | --- |
| Copilot Studio access or trial setup fails. | Tenant policy blocks self-service provisioning or the account lacks the right entitlements. | Move the participant to a pre-provisioned backup environment and log the tenant issue for follow-up. |
| SharePoint site creation stalls or finishes partially. | Site provisioning is still running or the wrong site template was chosen. | Keep the page open until provisioning completes, then confirm the financial services template and retry only if needed. |
| Participant lands in the wrong environment. | The default environment was auto-selected after sign-in. | Reopen the environment selector and switch to the workshop developer environment before proceeding. |

### Facilitator Escalation Trigger
Escalate if the participant cannot obtain a usable Copilot Studio environment or SharePoint site after one guided retry.

## Lab 01 — Intro to Agents
### Pre-conditions
- Lab 00 is complete.
- Participant has a notes app open for scenario answers.
- Facilitator is ready to anchor discussion in the Woodgrove Bank scenario.

### Success Criteria
1. The participant correctly classifies the three sample scenarios as conversational, conversational with actions, or autonomous.
2. The participant records a correct plain-language definition of RAG and actions.
3. The participant identifies one knowledge example and one action example from the workshop scenario.

### Common Failure Modes
| Symptom | Root Cause | Resolution |
| --- | --- | --- |
| Participant labels all scenarios the same way. | They missed the distinction between user-initiated and system-initiated behavior. | Reframe each example around its trigger source and walk through one example aloud. |
| Participant confuses knowledge grounding with actions. | The concepts were explained abstractly without concrete examples. | Use the account lookup as knowledge and SharePoint item creation as the action contrast. |
| Participant can repeat definitions but cannot apply them. | Discussion stayed theoretical instead of scenario-based. | Ask for one organization-specific example and validate it before moving on. |

### Facilitator Escalation Trigger
Escalate only if the whole room is misclassifying agent patterns after a full-group re-teach.

## Lab 02 — Copilot Studio Fundamentals
### Pre-conditions
- Labs 00 and 01 are complete.
- Participant is signed in to the correct Copilot Studio environment.
- A temporary or existing agent is available for interface exploration.

### Success Criteria
1. The participant can locate the Knowledge area and identify where to add a source.
2. The participant can locate the Tools and Topics pages and identify where to add a tool or topic.
3. The participant can open Analytics and identify the **Activity** page location.

### Common Failure Modes
| Symptom | Root Cause | Resolution |
| --- | --- | --- |
| Tabs such as Topics or Analytics appear to be missing. | Browser zoom or overflow behavior is hiding tabs. | Reduce zoom, check the overflow menu, and re-demonstrate the top navigation. |
| The opened agent looks empty or read-only. | Agent provisioning is incomplete or the wrong agent was opened. | Wait for provisioning, refresh the page, and reopen the intended agent. |
| Participant cannot find add-entry points. | They are on the wrong page or lost in navigation. | Guide them back to Overview, then step through Knowledge, Tools, and Topics in order. |

### Facilitator Escalation Trigger
Escalate if multiple participants cannot access the expected Copilot Studio navigation after environment and browser checks.

## Lab 03 — Declarative Agents
### Pre-conditions
- Lab 00 is complete and Copilot Studio is ready.
- Participant can create an agent in Copilot Studio.
- The sample instructions and prompt text from the lab are available to paste.
- A Microsoft 365 Copilot or Teams validation path is available for at least the facilitator.

### Success Criteria
1. A declarative agent named for the Woodgrove Bank support scenario exists with the lab-provided description and instructions saved.
2. The agent has an `Banking Policy Advisor` prompt tool configured and the prompt returns structured IT guidance in the test experience.
3. The published or previewed agent responds to an banking support prompt with banking-related guidance rather than a generic answer.

### Common Failure Modes
| Symptom | Root Cause | Resolution |
| --- | --- | --- |
| The prompt tool does not appear after creation. | The participant did not save the prompt before adding and configuring it. | Re-create the prompt and explicitly save before continuing. |
| The agent ignores the prompt tool during testing. | Instructions do not reference the tool by its exact saved name. | Edit the instructions so the tool name matches exactly and retest in a new session. |
| Publishing or channel validation is blocked. | The environment lacks publishing support or required tenant policy. | Validate in Copilot Studio first and use a facilitator-owned published environment for the end-state demo. |

### Facilitator Escalation Trigger
Escalate if no one in the room has a tenant path that can demonstrate the published declarative-agent experience.

## Lab 04 — Solutions
### Pre-conditions
- Lab 00 is complete.
- Participant has solution-management permissions in the environment.
- A target validation environment or facilitator-run import target is available.

### Success Criteria
1. The participant creates or opens the `Woodgrove Customer Service Agent` solution and exports a solution package.
2. The solution contains the `Workshop Scenario Name` environment variable with the expected default value.
3. The package imports into the target environment and the solution contents are visible after import.

### Common Failure Modes
| Symptom | Root Cause | Resolution |
| --- | --- | --- |
| The Solutions area is missing. | The participant lacks the required security role. | Move them to a facilitator-managed environment or have the role assigned before retrying. |
| Export reports dependency errors. | Required components or connection references are not included. | Review dependencies, add the missing components, and export again. |
| The imported package cannot be edited in the source environment. | A managed package was imported back into the editable environment. | Re-export or re-import as unmanaged for workshop authoring scenarios. |

### Facilitator Escalation Trigger
Escalate if solution permissions or dependency issues block the ALM path for the whole room.

## Lab 05 — Prebuilt Agents
### Pre-conditions
- Labs 00 and 02 are complete.
- Participant is signed in to the correct environment.
- The template gallery is reachable in Copilot Studio.

### Success Criteria
1. The Safe Travels prebuilt agent opens successfully from the template gallery.
2. The EU website knowledge source is added and the test answer reflects grounded travel guidance.
3. The participant can identify the publish or channel path for the template agent.

### Common Failure Modes
| Symptom | Root Cause | Resolution |
| --- | --- | --- |
| The Safe Travels template is not visible. | The gallery did not load correctly or the participant is in the wrong environment. | Refresh the page, recheck the environment, and use a facilitator demo if the gallery remains unavailable. |
| Test answers are generic or off-topic. | Website indexing has not finished yet. | Wait for indexing to complete, confirm the source status, and rerun the test question. |
| Participants assume the template is production-ready. | The template was not framed as a learning baseline. | Remind the room that templates must still be reviewed and adapted before real deployment. |

### Facilitator Escalation Trigger
Escalate if the template gallery is unavailable across the tenant and prevents the planned lab flow.

## Lab 06 — Custom Agent
### Pre-conditions
- Labs 00 and 04 are complete.
- The Woodgrove Bank SharePoint site URL is available.
- Participant can add knowledge sources and edit instructions.
- The facilitator has the quick-reference files ready if the lab uses local documents.

### Success Criteria
1. The `Woodgrove Customer Service Agent` includes the intended web, SharePoint, and file knowledge sources, and web search is turned off.
2. A account-balance or policy support question returns a grounded answer with a visible citation.
3. A account-inquiry or quick-reference question is answered from the configured workshop knowledge instead of hallucinated content.

### Common Failure Modes
| Symptom | Root Cause | Resolution |
| --- | --- | --- |
| SharePoint knowledge cannot be connected. | Site permissions or DLP settings block the connector. | Grant access or move to a known-good environment where SharePoint is allowed. |
| The agent answers without grounding from the Customer Accounts list. | SharePoint indexing is incomplete or the filter excludes the needed content. | Wait for indexing, loosen the filter, and ask a more specific test question. |
| Web search stays on and masks workshop knowledge behavior. | The participant missed the toggle location. | Return to the agent settings or overview area and explicitly switch web search off. |

### Facilitator Escalation Trigger
Escalate if SharePoint access or DLP policy blocks the custom-agent grounding path for the workshop environment.

## Lab 07 — Topics and Triggers
### Pre-conditions
- Lab 06 is complete.
- The Customer Accounts list contains active accounts to query.
- Participant can create topics and connector-based actions.

### Success Criteria
1. The `Account Inquiry` topic exists and includes a SharePoint action that retrieves active customer account records.
2. Asking for active customer accounts returns a structured list from SharePoint.
3. The topic asks the user whether they want to request one of the returned devices.

### Common Failure Modes
| Symptom | Root Cause | Resolution |
| --- | --- | --- |
| The topic does not trigger for account inquiry questions. | The description is too vague or orchestration is off. | Turn orchestration on, add concrete account inquiry keywords, and retest in a new session. |
| The SharePoint action returns no items. | The site, list name, or OData filter is wrong. | Re-select the site and list from the picker, simplify the filter, and confirm available records exist. |
| The topic returns blank or static output instead of the account list. | Variable storage or formula usage is incorrect. | Start with a simpler output, confirm the action data is present, then reintroduce dynamic formatting. |

### Facilitator Escalation Trigger
Escalate if the topic cannot retrieve any live SharePoint account data after connector and list validation.

## Lab 08 — Adaptive Cards
### Pre-conditions
- Lab 07 is complete and returns active accounts.
- The adaptive card designer is available.
- Participant can edit a topic that uses card inputs.

### Success Criteria
1. The `Submit service request` topic contains an adaptive card node with account, manager email, and comments inputs.
2. The card appears after the user opts to submit a service request and the account choices are populated correctly.
3. Submitting the card captures the selected account and text inputs for downstream automation.

### Common Failure Modes
| Symptom | Root Cause | Resolution |
| --- | --- | --- |
| The card JSON saves but dynamic choices fail. | Formula syntax is invalid or not supported in the environment. | Save a static version first, then add dynamic expressions incrementally. |
| The card shows empty or incorrect account choices. | The prior topic did not populate the account variable or field names do not match. | Run the availability topic in the same session and confirm the field references before retesting. |
| The card renders incorrectly in a channel test. | The schema or layout is incompatible with the target renderer. | Validate the JSON in the designer, keep the schema conservative, and retest in the intended channel. |

### Facilitator Escalation Trigger
Escalate if the environment cannot render or submit adaptive cards consistently after a known-good static card check.

## Lab 09 — Agent Flows
### Pre-conditions
- Lab 08 is complete and card outputs are available.
- The Customer Accounts list contains at least one available device.
- SharePoint and Outlook connectors are allowed in the environment.
- The Service Requests list exists or can be created during the lab.

### Success Criteria
1. The Service Requests list exists with the fields needed to track a request.
2. The service-request flow is published and includes the expected retrieval, create, update, notification, and respond-to-agent steps.
3. A full test run creates a pending service service request record, updates the original account status, sends the notification, and returns a confirmation in chat.

### Common Failure Modes
| Symptom | Root Cause | Resolution |
| --- | --- | --- |
| The flow cannot update the Customer Accounts item. | Required SharePoint fields were not mapped in the update step. | Map all required columns from the original item, not just the status field. |
| The topic receives no confirmation after the flow runs. | The flow does not return a response payload to the agent. | Add or fix the respond-to-agent step and remap the confirmation output in the topic. |
| The flow fails when trying to create the service request item. | The Service Requests list or expected columns do not exist yet. | Create or correct the list first, refresh the flow designer, and retest from the start. |

### Facilitator Escalation Trigger
Escalate if connector policy or SharePoint schema issues prevent the automation path from working for the room.

## Lab 10 — Event Triggers
### Pre-conditions
- Lab 06 is complete.
- The Service Requests list exists.
- SharePoint and Outlook connectors are allowed.
- Agent orchestration is enabled.

### Success Criteria
1. A SharePoint-based trigger is configured to react to new service service request items.
2. The agent has an email action configured for service request acknowledgment.
3. Creating a new service request causes an acknowledgment email to be sent without a user starting a chat session.

### Common Failure Modes
| Symptom | Root Cause | Resolution |
| --- | --- | --- |
| Creating a new service request does not trigger any activity. | The trigger is disabled, unpublished, or was created after the test item. | Enable and publish the trigger, then create a brand-new test service request. |
| The trigger fires but the email is never sent. | The Outlook connector is disconnected or the tool reference is wrong. | Reconnect Outlook, confirm the tool name, and test the action independently if needed. |
| The email is sent with blank service request details. | The trigger payload mapping uses the wrong SharePoint fields. | Rebuild the field mapping using dynamic content from the current list schema. |

### Facilitator Escalation Trigger
Escalate if autonomous trigger execution fails broadly because the environment cannot run the SharePoint-to-agent flow.

## Lab 11 — Publish Agent
### Pre-conditions
- Labs 06 through 10 are complete enough to demonstrate meaningful behavior.
- The environment has a publish path for at least the facilitator.
- Participant can sign in to Teams with the workshop account if channel testing is in scope.

### Success Criteria
1. The agent publishes successfully in Copilot Studio.
2. The Teams and Microsoft 365 channel path is visible from the Channels area.
3. The agent can be opened in Teams and respond to a basic support request.

### Common Failure Modes
| Symptom | Root Cause | Resolution |
| --- | --- | --- |
| Publish is unavailable or errors out. | The environment lacks publishing support. | Validate in the test pane and use a facilitator environment to show the published experience. |
| Teams installation fails. | The participant is using the wrong account or policy blocks the app install. | Reauthenticate in Teams, confirm the agent is published, and retry from a clean browser path. |
| The agent opens in Teams but fails at runtime. | A knowledge source or connector used by the agent is broken. | Re-test in Copilot Studio, repair the failing dependency, then republish. |

### Facilitator Escalation Trigger
Escalate if the tenant cannot demonstrate any end-to-end publish path needed for the workshop outcome.

## Lab 12 — Licensing
### Pre-conditions
- Day 1 labs are complete enough for participants to reference concrete examples.
- Participant has a notes app open.
- Facilitator is ready to keep the conversation at the planning level rather than quoting tenant-specific pricing.

### Success Criteria
1. The participant can distinguish Copilot Credits, capacity packs, pay-as-you-go, and user licensing in workshop terms.
2. The participant can map at least one Day 1 scenario to expected Copilot Studio credit consumption.
3. The participant records the estimator link and a short recommendation for capacity planning or ROI follow-up.

### Common Failure Modes
| Symptom | Root Cause | Resolution |
| --- | --- | --- |
| Participant assumes Microsoft 365 Copilot licensing covers all workshop automations. | They do not connect actions and autonomous workflows to Copilot Studio consumption. | Re-anchor the explanation in the service-request and trigger examples. |
| Participant treats the trial environment as a production plan. | Trial limits and expiry were not emphasized. | Call out the temporary nature of the trial and the need to move to paid capacity. |
| Participant cannot tell which labs consume credits. | The discussion stayed conceptual instead of scenario-based. | Walk through Day 1 labs and label which steps use actions, flows, or autonomous execution. |

### Facilitator Escalation Trigger
Escalate only if licensing questions become tenant-contract specific and cannot be answered within workshop scope.

## Lab 13 — Loan Processing Agent Setup
### Pre-conditions
- Participant is in the same environment that will be used for Day 2.
- The Woodgrove Lending solution package and CSV files are downloaded locally.
- Dataverse, Teams, and Power Automate access is available in the tenant.

### Success Criteria
1. The Woodgrove Lending solution imports successfully and the Woodgrove Lending Hub model-driven app opens.
2. Loan Types and Assessment Criteria data are visible after the CSV imports.
3. The Loan Processing Agent exists with the expected baseline settings, including orchestration, file uploads, moderation, and user reactions.

### Common Failure Modes
| Symptom | Root Cause | Resolution |
| --- | --- | --- |
| Solution import fails or hangs. | A dependency, connection, or previous failed import is blocking progress. | Check import history, clear the failed attempt, and retry from the package. |
| CSV import finishes with bad mappings. | Lookup fields or headers were mapped incorrectly. | Re-import with explicit field mapping and verify the Loan Type lookup target. |
| Required agent settings cannot be enabled. | Environment policy or licensing does not allow the feature set. | Move the participant to a prepared environment and capture the tenant limitation. |

### Facilitator Escalation Trigger
Escalate if Dataverse or solution import issues block the Loan Processing Agent foundation for Day 2.

## Lab 14 — Agent Instructions
### Pre-conditions
- Lab 13 is complete.
- The Loan Processing Agent is open for editing.
- Participant can run immediate tests in the Copilot Studio test pane.

### Success Criteria
1. The Loan Processing Agent contains the balanced instruction set from the lab, including next-action guidance and scoped behavior.
2. An in-scope lending prompt gets a lending-focused answer and an off-topic prompt is redirected appropriately.
3. An ambiguous lending prompt causes the agent to ask a clarifying question instead of guessing.

### Common Failure Modes
| Symptom | Root Cause | Resolution |
| --- | --- | --- |
| The updated instructions do not seem to affect answers. | The participant reused an older test session. | Save the instructions and start a new test session before retesting. |
| The agent becomes too restrictive. | The instructions over-emphasize prohibitions without positive guidance. | Restore the balanced set from the lab and avoid overly absolute wording. |
| The participant saves the wrong instruction variant. | They treated all example sets as interchangeable. | Confirm the balanced set is the working baseline before moving on. |

### Facilitator Escalation Trigger
Escalate if instruction updates cannot be saved or applied consistently in the participant environment.

## Lab 15 — Multi-Agent
### Pre-conditions
- Labs 13 and 14 are complete.
- Participant can create or connect additional agents.
- The Loan Processing Agent is ready to orchestrate to child or connected agents.

### Success Criteria
1. The Loan Processing Agent is configured to let other agents connect and includes delegation guidance in its instructions.
2. Document Review Agent and Loan Advisory Agent are present with scoped responsibilities.
3. Test prompts route to the appropriate agent path and the activity map reflects the delegation.

### Common Failure Modes
| Symptom | Root Cause | Resolution |
| --- | --- | --- |
| A connected agent cannot be selected. | The target agent was not saved, published, or allowed to connect. | Open the target agent, enable connections, save, and retry the connection flow. |
| The parent agent answers everything itself. | Delegation instructions and descriptions are too weak. | Strengthen the routing language with explicit examples for each child agent. |
| Routing is inconsistent or overlaps. | Agent scopes are too similar. | Narrow each child agent to a distinct responsibility and retest with targeted prompts. |

### Facilitator Escalation Trigger
Escalate if agent-to-agent connection capability is unavailable in the environment needed for the lab.

## Lab 16 — Trigger Automation
### Pre-conditions
- Labs 13 through 15 are complete.
- The Application Documents Dataverse table exists.
- A sample PDF loan document is available.
- SharePoint and Teams connectors are permitted.

### Success Criteria
1. The Loan Documents library exists and the upload trigger is configured against it.
2. The automation flow is published with PDF filtering, Dataverse row creation, file upload, and Teams notification steps.
3. Uploading a new PDF creates the application document record, stores the file, and posts the notification.

### Common Failure Modes
| Symptom | Root Cause | Resolution |
| --- | --- | --- |
| The Dataverse row is created without the file. | The upload step is mapped to metadata instead of file content. | Remap the file-content output into the Dataverse file column and retest. |
| Non-PDF files are processed. | The file-type condition checks the wrong field or operator. | Filter on file name ending in `.pdf` and validate with both file types. |
| Uploading a new file does nothing. | The trigger is disabled, unpublished, or was tested with an older file. | Publish the flow and upload a brand-new file after the trigger is active. |

### Facilitator Escalation Trigger
Escalate if SharePoint-to-Dataverse trigger automation cannot run because of tenant connector or permissions policy.

## Lab 17 — Model Selection
### Pre-conditions
- Labs 13 and 14 are complete.
- The Loan Processing Agent can switch models in the environment.
- Participant has the three comparison prompts copied into notes.
- Facilitator is prepared to treat GPT-5 Chat as the baseline when it is available and otherwise use another GA fallback.

### Success Criteria
1. The participant runs the same three prompts in new test sessions against GPT-5 Chat or the best available GA baseline.
2. The participant compares at least one additional GA model and records observations for accuracy, latency, and relative cost.
3. The participant saves the final working model for the remaining labs and notes whether GPT-5 Chat remained the baseline or a fallback was chosen.

### Common Failure Modes
| Symptom | Root Cause | Resolution |
| --- | --- | --- |
| Only one model appears in the picker. | The tenant exposes a limited GA model set. | Compare the visible options you have, document the gap, and use a facilitator demo if needed. |
| Results vary unpredictably between runs. | The participant reused conversation context. | Start a new test session for every model comparison. |
| The participant cannot explain the final choice. | They used the picker without filling in the scorecard. | Re-run one comparison and frame the decision in terms of quality, speed, and loan officer trust. |

### Facilitator Escalation Trigger
Escalate if the environment hides all model-selection controls needed to set a Day 2 baseline.

## Lab 18 — Content Moderation
### Pre-conditions
- Labs 13 and 14 are complete.
- The Loan Processing Agent is open and editable.
- Participant has a short loan applicant summary for prompt testing.
- Facilitator is using the March 2026 safety path with GA controls only.

### Success Criteria
1. The Conversation Start topic includes the AI disclosure, agent moderation is set to High, and the `Loan Application Review` prompt has the content moderation slider set to High.
2. Red-team prompts 1 through 9 are refused, redirected, or safely constrained.
3. The clean in-scope control prompt returns a normal lending-related answer and the participant notes which protection layer fired for each case.

### Common Failure Modes
| Symptom | Root Cause | Resolution |
| --- | --- | --- |
| Unsafe prompts still get full answers. | Agent moderation, prompt content moderation, or guardrail instructions are too weak. | Raise the relevant safety control, save, and retest in a new session. |
| Safe prompts are blocked too aggressively. | Prompt-specific content moderation level is overfiring. | Keep the agent baseline strong and lower only the specific prompt content moderation level that is too strict. |
| Published behavior differs from the test pane. | The On Error topic or published version is out of sync. | Review the On Error message, republish, and test again in a fresh channel session. |

### Facilitator Escalation Trigger
Escalate if the environment cannot enforce the required moderation controls or produces unsafe lending outputs after guided remediation.

## Lab 19 — Multimodal Prompts
### Pre-conditions
- Lab 13 is complete.
- Participant can create prompt tools with document or image input.
- One text-based PDF loan document and one image-based loan document are available.
- A GA multimodal-capable model is available, with GPT-5 Chat preferred when supported.

### Success Criteria
1. The `Financial Document Analysis` prompt is created with document input and JSON output fields matching the lab schema.
2. Testing with a PDF loan document returns structured JSON without invented values for missing fields.
3. Testing with an image-based loan document also returns valid JSON and records OCR confidence notes.

### Common Failure Modes
| Symptom | Root Cause | Resolution |
| --- | --- | --- |
| The prompt returns prose instead of JSON. | The output type was not set or saved as JSON. | Reopen the prompt, set JSON output, save, and retest. |
| Missing loan document fields are hallucinated. | The instructions do not explicitly forbid guessing. | Strengthen the prompt to return empty strings for missing values. |
| Image-based extraction quality is poor. | The image is skewed, low-contrast, or low-resolution. | Improve the image quality before changing the prompt logic. |

### Facilitator Escalation Trigger
Escalate if no generally available model in the tenant can perform the document-analysis path required by the lab.

## Lab 20 — Dataverse Grounding
### Pre-conditions
- Lab 19 is complete.
- Participant can create or edit Dataverse tables and prompt tools.
- At least two open loan products exist for testing.

### Success Criteria
1. The Loan Products table exists with the required columns and open records.
2. The matching prompt is configured to use Dataverse grounding and returns JSON with loan product matches.
3. The test output references real loan product numbers from Dataverse and the knowledge-used view shows grounded records being injected.

### Common Failure Modes
| Symptom | Root Cause | Resolution |
| --- | --- | --- |
| The Loan Products table is not selectable in the prompt builder. | The table changes were not published or the UI cache is stale. | Publish the table changes, refresh Copilot Studio, and retry the selector. |
| The prompt returns no matches or made-up loan product numbers. | The Dataverse filter is wrong or the prompt does not force grounded-only output. | Verify the filter value and add an explicit grounded-data-only instruction. |
| The prompt behaves like generic matching with no visible business data. | Too few fields or records are being retrieved from Dataverse. | Increase retrieval scope and include the loan product fields needed for matching. |

### Facilitator Escalation Trigger
Escalate if Dataverse grounding is unavailable or cannot surface live loan product data in the prompt experience.

## Lab 21 — Document Generation
### Pre-conditions
- Labs 13 and 20 are complete in the same environment.
- At least one loan applicant, application, and loan product record is available.
- Participant can edit Word templates and build agent flows.
- SharePoint or OneDrive storage is available for the template.

### Success Criteria
1. `Loan_Assessment_Template.docx` exists with the required Plain Text Content Controls and the narrative prompt uses GPT-5 Chat or another GA fallback.
2. The `Generate Loan Assessment Report` flow is published and follows the GA Word-template-plus-flow pattern rather than a non-GA path.
3. The `Create Loan Assessment` topic returns a downloadable Word file whose fields and narrative are populated correctly.

### Common Failure Modes
| Symptom | Root Cause | Resolution |
| --- | --- | --- |
| The generated document downloads with blank fields. | Content control titles or flow mappings do not match. | Recheck the Plain Text Content Control titles and remap the populate-template step. |
| The narrative section is empty. | The prompt inputs are not mapped from Dataverse and topic values correctly. | Test the prompt on its own, then repair the flow input mappings. |
| The topic completes without returning a file. | The flow does not send a file output back to the agent. | Add or fix the file output in the respond-to-agent step and retest. |

### Facilitator Escalation Trigger
Escalate if Word Online or template-population capabilities are unavailable, because Lab 21 must stay on the GA template-plus-flow path.

## Lab 22 — MCP Integration
### Pre-conditions
- Lab 15 is complete.
- The GA MCP onboarding wizard is visible in Copilot Studio.
- The workshop account has a manager, mailbox, and at least one calendar meeting.
- Participant can approve the Microsoft 365 connections used by the MCP servers.

### Success Criteria
1. The participant launches the GA MCP onboarding wizard from Tools and adds the Microsoft 365 User Profile MCP server successfully.
2. The Microsoft Outlook Calendar MCP server is added through the wizard and the agent can return current meeting information.
3. The agent suggests loan review meeting options and can create the selected meeting, while the participant records one allowed action and one out-of-scope action.

### Common Failure Modes
| Symptom | Root Cause | Resolution |
| --- | --- | --- |
| The MCP option is missing from the Tools experience. | The participant is in the wrong environment or the feature is unavailable there. | Refresh, reopen the agent, confirm the environment, and fall back to a facilitator demo if needed. |
| The calendar MCP tool can read but not create the meeting. | The Microsoft 365 connection or mailbox permissions are incomplete. | Re-run the connection flow, confirm the account has a mailbox, and retest with the same account. |
| The agent does not call the MCP tools reliably. | The request is too vague or the tool scope and descriptions are unclear. | Use direct calendar or profile prompts first, then retry the scheduling request. |

### Facilitator Escalation Trigger
Escalate if the GA MCP onboarding wizard itself is not available, because Lab 22 is explicitly validating that path.

## Lab 23 — User Feedback
### Pre-conditions
- Lab 13 is complete.
- User reactions are enabled in the Loan Processing Agent settings.
- Participant can edit system topics and add a custom topic.

### Success Criteria
1. User reactions are enabled and the custom dissatisfied-feedback topic exists with the adaptive card inputs from the lab.
2. The End of Conversation topic routes low CSAT scores into the custom feedback flow and lets higher scores end normally.
3. A low-rating test shows the follow-up card, captures the response, and a high-rating test ends without the extra card.

### Common Failure Modes
| Symptom | Root Cause | Resolution |
| --- | --- | --- |
| Low CSAT ends the chat without the follow-up card. | The condition logic in End of Conversation is reversed or incomplete. | Rebuild the branch logic and retest with a 1-star score. |
| CSAT data does not appear in analytics yet. | Analytics latency or too few completed sessions. | Run multiple sessions, wait, refresh analytics, and verify reactions are still enabled. |
| The follow-up card submits but the detail is hard to find. | The participant is looking in summary analytics instead of activity details. | Open the activity or transcript view for that session and inspect the custom topic execution. |

### Facilitator Escalation Trigger
Escalate if the tenant blocks user reactions or the feedback-routing logic cannot be saved in the agent.

## Lab 24 — Agent Evaluation
### Pre-conditions
- Labs 13, 14, 17, and 23 are complete.
- The Loan Processing Agent is using a GA model baseline, with GPT-5 Chat preferred when available.
- Participant can access the Evaluation page and has working connections for any authenticated tools.

### Success Criteria
1. An evaluation run named `Loan Processing Agent - Day 2 QA Baseline` completes with at least five realistic test cases and a visible pass rate.
2. The participant opens a failing case, reviews grader reasoning, and uses the activity map to identify one concrete quality issue.
3. The participant updates the agent, reruns the same test set, and compares the second run to confirm one improvement cycle.

### Common Failure Modes
| Symptom | Root Cause | Resolution |
| --- | --- | --- |
| The Evaluation page is missing or unusable. | The feature is not available yet in that environment or the agent is still loading. | Refresh the browser, reopen the agent, and use a facilitator environment if the feature remains unavailable. |
| The evaluation run fails because tools or knowledge cannot authenticate. | The selected evaluation user profile lacks valid connections or data access. | Repair the user profile connections and rerun the same test set. |
| Every test passes trivially and yields no insight. | The test cases or graders are too weak. | Tighten the expected responses, add stronger graders, and rerun with the same quality goal. |

### Facilitator Escalation Trigger
Escalate if the room cannot complete an evaluation run or inspect an activity map, because both are core validation outcomes for Lab 24.

## Lab 25 — VS Code Extension
### Pre-conditions
- Labs 13 through 24 are complete, or the participant is otherwise caught up on the shared core path.
- This module is being attempted only by developer-track participants and remains optional for everyone else.
- Visual Studio Code and the Microsoft Copilot Studio extension are installed and signed in to the workshop tenant.
- The participant can open Loan Processing Agent in both VS Code and the browser.

### Success Criteria
1. The developer clones Loan Processing Agent into VS Code, opens `agent.yaml`, and sees no unresolved validation issues before editing.
2. The developer makes one visible instruction improvement locally and applies it back to Copilot Studio successfully.
3. After refreshing the browser and starting a new test session, the agent response reflects the synced change.

### Common Failure Modes
| Symptom | Root Cause | Resolution |
| --- | --- | --- |
| The agent does not appear in the VS Code extension. | The extension is signed in to the wrong environment or not fully authenticated. | Reauthenticate, confirm the environment, and retry the clone flow. |
| Apply fails with a remote-change conflict. | The cloud version changed after the local clone. | Preview, get the latest remote state, resolve the diff, and apply again. |
| The browser still shows the old behavior after apply. | The page or session is stale. | Hard refresh the browser, reopen the agent, and test in a brand-new session. |

### Facilitator Escalation Trigger
Escalate only if the optional GA VS Code workflow cannot clone or apply changes for developer-track participants after reauthentication and refresh checks.

## Day 2 Wrap-up Guidance

On Day 2, use this checklist together with Lab 24 evaluation runs and Lab 23 user-feedback signals: evaluations help you verify expected behavior at scale, while CSAT and dissatisfied-feedback patterns show where live experience still needs improvement. When both signals point to the same weakness, capture one concrete fix, rerun the evaluation set, and use that evidence in the closing facilitator debrief.


