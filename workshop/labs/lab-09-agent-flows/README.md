# Copilot Studio Workshop
## Day 1 — Foundation Track
### Lab 09 — Agent Flows
⏱ Estimated time: 45 min (core) + 15 min (optional Part 2: Multistage AI-Assisted Loan Approval)

#### Overview
In this lab, you will connect the Adaptive Card from Lab 08 to a Power Automate flow so the form submission creates a service request record in SharePoint and emails the service team. This turns the service request topic from a conversation into a working business process.

![Power Automate flow designer with agent trigger and SharePoint actions](./assets/lab-09-agent-flow.png)

#### Prerequisites
1. Complete Lab 08 and confirm the adaptive card submits values for `customerNameId`, `requestTypeId`, `descriptionId`, and `priorityId`.
2. Confirm the `Customer Accounts` SharePoint list contains at least one item with **AccountStatus** set to `Active`.
3. [Maker] Confirm you can create flows in the same environment as the agent.
4. [IT Pro] Confirm the SharePoint and Office 365 Outlook connectors are allowed by DLP policy.

#### Step-by-Step Instructions
#### Step 1 — Create the SharePoint list that will store service requests

1. Open the `Woodgrove Bank` SharePoint site from Lab 00.
2. Select **New** > **List**.
3. Select **Blank list**.
4. In the **Name** field, enter `Service Requests` and select **Create**.
5. Add the following columns from **+ Add column**: `RequestType` as **Single line of text**, `RequestDescription` as **Multiple lines of text**, `Priority` as **Choice**, `Status` as **Choice**, and `SubmittedOn` as **Date and time**.
6. In the **Priority** choice column, add `Low`, `Normal`, and `High` as choices with `Normal` as the default.
7. In the **Status** choice column, add `New`, `In Progress`, and `Resolved` as choices with `New` as the default.

#### Step 2 — Add a flow after the Adaptive Card submission
1. Open **Woodgrove Customer Service Agent** and then open the `Submit service request` topic.
2. Under the **Ask with adaptive card** node, select **+**.
3. Choose **Add a tool** and then select **Agent flow** under **Create new**.
4. Wait for the Agent flow designer to open in the same window.

#### Step 3 — Define flow inputs from the Adaptive Card
1. Select the **When an agent calls the flow** trigger to expand it.
2. Add a **Text** input named `CustomerName`.
3. Add a **Text** input named `RequestType`.
4. Add a **Text** input named `RequestDescription`.
5. Add a **Text** input named `Priority`.

#### Step 4 — Create the service request record in SharePoint
1. Select the **+** button between the trigger and **Respond to the agent**.
2. Search for the SharePoint **Create item** action and add it.
3. Rename the step to `Create Service Request`.
4. In **Site Address**, select the `Woodgrove Bank` site.
5. In **List Name**, select `Service Requests`.
6. Map **Title** to the `CustomerName` trigger input. SharePoint requires a Title column — using the customer name makes the list view scannable.
7. Map **RequestType** to the `RequestType` trigger input.
8. Map **RequestDescription** to the `RequestDescription` trigger input.
9. Map **Priority** to the `Priority` trigger input.
10. Map **Status** to the value `New`.
11. Map **SubmittedOn** to `utcNow()` if the field is available. To enter this, select the **Expression** tab (not **Dynamic content**) in the field editor and type `utcNow()` exactly as shown, then select **OK**.

#### Step 5 — Notify the service team
1. Add an **Office 365 Outlook – Send an email (V2)** action after the **Create Service Request** step.
2. In **To**, enter a valid email address for the service team or your own test email.
3. In **Subject**, enter `New service request from` followed by the `CustomerName` input.
4. In **Body**, include the customer name, request type, description, and priority level.

#### Step 6 — Return a confirmation message to the topic
1. Add a **Respond to agent** action.
2. Add a **Text** output named `ConfirmationMessage`.
3. Set the output value to `Your service request has been submitted successfully. A team member will review it shortly.`
4. Save the flow and return to the topic.

#### Step 7 — Map the Adaptive Card outputs to the flow inputs
1. In the topic tool node, map `CustomerName` to `customerNameId` from the adaptive card output.
2. Map `RequestType` to `requestTypeId`.
3. Map `RequestDescription` to `descriptionId`.
4. Map `Priority` to `priorityId`.
5. Add a **Send a message** node after the flow.
6. Insert the `ConfirmationMessage` flow output into the message.
7. Save the topic.

![Topic node showing flow inputs mapped from adaptive card outputs](./assets/lab-09-topic-mapping.png)

#### Step 8 — Test the end-to-end process
1. Open the **Test** pane and start a new session.
2. Enter `Show active accounts` and move through the `Account Inquiry` topic.
3. Reply `Yes` to open the adaptive card.
4. Enter a customer name, select a request type, add a description, choose a priority, and submit the card.
5. Wait for the confirmation message from the flow.
6. Open the `Service Requests` SharePoint list and confirm a new item was created with Status set to `New`.

> **Tip:** The Adaptive Card submission is the trigger point. If the flow works but the topic does not, the issue is usually input mapping rather than the actions themselves.

#### Validation
1. Confirm the Power Automate flow contains the trigger, `Create Service Request`, `Send an email (V2)`, and `Respond to agent` steps.
2. Confirm the adaptive card outputs are mapped correctly in the topic tool node.
3. Confirm a new row appears in the `Service Requests` SharePoint list after a test submission with Status set to `New`.
4. Confirm the service team receives the email notification.

#### Troubleshooting
> **Tip:** If the flow runs but the topic returns no message, open the **Respond to agent** step and confirm the `ConfirmationMessage` output exists and is mapped in the topic.

> **Tip:** If the `CustomerName` input is blank, resubmit the adaptive card and verify the `Input.Text` id values match the expected output variable names.

> **Tip:** If the Priority or Status choice columns reject the flow values, open the SharePoint list settings and confirm the exact spelling and casing of each choice matches what the flow sends.

> **Warning:** If the `Service Requests` list does not exist before you save the flow, the SharePoint actions will not populate the expected column pickers.

#### Facilitator Notes
1. Call out explicitly that this lab connects conversational capture to system writeback, which is the turning point for business value.
2. If time is limited, provide a pre-created `Service Requests` list so participants can focus on the flow and topic mapping.
3. The user requirement for this workshop is satisfied only when the Adaptive Card submission writes back to SharePoint, so validate that step carefully.
4. **Four-eyes / SR 11-7 governance — non-negotiable.** When you facilitate Part 2 (or even when you skip it), call out that under Federal Reserve / OCC supervisory guidance **SR 11-7 (Model Risk Management)** and the **OCC AI/ML model risk principles**, AI-generated credit decisions are model output and must always be subject to **independent human review** before customer impact. The agent and the AI summary node are *decision-support* tools — never the decision-maker. The four-eyes principle (two independent humans approve before action) is also baked into ECOA Reg B §1002.9 adverse-action requirements and most banks' internal credit policy. If you only have time for one sentence, say: **"AI proposes, humans approve — and on loans above the policy threshold, two humans approve."**
5. Equivalent guidance in other jurisdictions: **PRA SS1/23 (UK)**, **EBA Guidelines on Internal Governance** and **EU AI Act Article 14 (human oversight of high-risk AI systems)** — useful to mention if your audience is non-US.
---

## Part 2 — Optional extended exercise: Multistage AI-assisted Loan Approval (≈15 min)

> **Optional.** Skip this section if you are running tight on time. The core lab above is the workshop's required outcome; Part 2 is an FSI-native extension that demonstrates the **multistage human approval** pattern facilitators can re-use as a teaching scaffold for any high-stakes banking workflow (KYC review, exception handling, large-payment release, sanctions hits).

#### Part 2 Overview
You will extend the Agent Flow pattern from Part 1 with a **two-tier human approval workflow** for a loan application submitted through the agent. AI summarizes the application for a human reviewer at each stage; humans always make the final approve/reject call. This re-skins the standard Power Automate Approvals pattern as a **Loan Approval Workflow** for `Woodgrove Bank`.

The pattern:
1. Loan application submitted via the agent (re-uses the Adaptive Card pattern from Lab 08).
2. Agent Flow extracts structured fields (amount, purpose, applicant, debt-to-income).
3. AI summarizes the application for a **Tier-1 Underwriter** approval.
4. If amount > **$250,000**, escalate to a **Tier-2 Senior Underwriter** approval.
5. On final approval, the agent confirms the decision back to the originating user.

> **Governance callout — read this to the room before building.** AI is the *summarizer and router*, never the *approver*. SR 11-7 and OCC AI guidance require independent human review of model output before any customer-impacting credit decision. The conditional escalation above $250K implements **four-eyes governance** — two independent humans must approve large loans. Never wire the agent or any AI step to send `Approve` automatically.

#### Part 2 Prerequisites
1. Complete Part 1 (the `Submit service request` flow works end-to-end).
2. Confirm the **Approvals** connector is allowed by your tenant DLP policy. The Approvals action requires a Power Automate (Process) license or the Approvals capacity that ships with most Microsoft 365 plans.
3. Pick two test approver email addresses you can monitor — for example `underwriter@example.com` and `senior-underwriter@example.com`. In a workshop tenant, you can use your own email for both tiers; for a realistic demo, use two separate facilitator accounts.

#### Step-by-Step Instructions (Part 2)

#### Step 9 — Create the Loan Applications SharePoint list
1. In the `Woodgrove Bank` SharePoint site, select **New** > **List** > **Blank list**.
2. Name the list `Loan Applications` and select **Create**.
3. Add the following columns:
   - `ApplicantName` — **Single line of text**
   - `LoanAmount` — **Number** (Currency format, USD)
   - `LoanPurpose` — **Single line of text**
   - `DebtToIncomeRatio` — **Number** (decimal, 2 decimal places)
   - `ApprovalStage` — **Choice** with `Tier-1 Pending`, `Tier-2 Pending`, `Approved`, `Rejected`
   - `Tier1Decision` — **Single line of text**
   - `Tier2Decision` — **Single line of text**
   - `SubmittedOn` — **Date and time**

#### Step 10 — Create the Loan Approval agent flow
1. Open the `Loan Processing Agent` topic where loan applications are submitted (or, for a quick demo, add a new topic to the Woodgrove Customer Service Agent named `Submit loan application`).
2. Add a node, choose **Add a tool** > **Agent flow** > **Create new**.
3. In the trigger **When an agent calls the flow**, add these inputs:
   - `ApplicantName` (Text)
   - `LoanAmount` (Number)
   - `LoanPurpose` (Text)
   - `DebtToIncomeRatio` (Number)
   - `OriginatingUserEmail` (Text)

#### Step 11 — Add the AI summarization step
1. After the trigger, add the **AI Builder** action **Create text with GPT using a prompt** (or **Generate text with GPT** depending on the tenant's AI Builder version).
2. In the prompt field, enter:
   ```
   Summarize this loan application for an underwriter in 3 short bullet points.
   Be neutral. Do NOT recommend approve or reject — that is the underwriter's decision.
   Applicant: {ApplicantName}
   Amount: {LoanAmount}
   Purpose: {LoanPurpose}
   Debt-to-Income: {DebtToIncomeRatio}
   ```
   Map each `{placeholder}` to the matching trigger input via dynamic content.
3. Rename the step to `AI Summary for Underwriter`.

> **Tip:** Notice the prompt explicitly instructs the model **not** to make the approval recommendation. This is the SR 11-7 boundary in practice — the AI summarizes evidence; the human decides.

#### Step 12 — Tier-1 Underwriter approval
1. Add the **Approvals** action **Start and wait for an approval**.
2. Set **Approval type** to `Approve/Reject – First to respond`.
3. **Title:** `Tier-1 Loan Review — [ApplicantName] — $[LoanAmount]` (use dynamic content).
4. **Assigned to:** `underwriter@example.com` (replace with your test approver).
5. **Details:** insert the output of `AI Summary for Underwriter`, then append the raw fields (Applicant, Amount, Purpose, DTI) so the approver can verify the AI summary against the source data.
6. Rename the step to `Tier-1 Underwriter Approval`.

#### Step 13 — Conditional escalation to Tier-2 Senior Underwriter
1. After the Tier-1 approval, add a **Condition** action.
2. Set the condition to: `LoanAmount` **is greater than** `250000` **AND** the Tier-1 `Outcome` **is equal to** `Approve`.
3. In the **If yes** branch:
   1. Add another **Start and wait for an approval** action.
   2. **Title:** `Tier-2 Senior Review — [ApplicantName] — $[LoanAmount]`.
   3. **Assigned to:** `senior-underwriter@example.com`.
   4. **Details:** include the AI summary, the raw fields, and the Tier-1 approver's comments (`Responses Comments` dynamic content).
   5. Rename the step to `Tier-2 Senior Underwriter Approval`.
4. Leave the **If no** branch empty for now — single-tier approval is enough for loans at or below the threshold or for any Tier-1 reject.

#### Step 14 — Write the final decision back to SharePoint
1. After the condition, add a SharePoint **Create item** action targeting the `Loan Applications` list.
2. Map all input fields, set `SubmittedOn` to `utcNow()`, and set `ApprovalStage`:
   - If Tier-1 = Reject → `Rejected`
   - If Tier-1 = Approve and Tier-2 not required → `Approved`
   - If Tier-1 = Approve and Tier-2 = Approve → `Approved`
   - If Tier-1 = Approve and Tier-2 = Reject → `Rejected`
3. The simplest implementation is one final **Compose** action that derives the stage from the two outcomes, then a single **Create item**.

#### Step 15 — Confirm back to the originating user
1. Add a **Respond to agent** action.
2. Add a Text output named `ApprovalConfirmation`.
3. Set the value to a message that includes the final stage, for example: `Loan application for [ApplicantName] is now [ApprovalStage]. Tier-1: [Tier1Outcome]. Tier-2: [Tier2Outcome or Not required].`
4. Save the flow and return to the topic.
5. In the topic, add a **Send a message** node after the flow that surfaces `ApprovalConfirmation` to the user.

#### Validation (Part 2)
1. Submit a test loan with `LoanAmount = 50000`. Confirm only the Tier-1 approval email arrives. Approve it and confirm the SharePoint row is `Approved` with Tier-2 blank.
2. Submit a test loan with `LoanAmount = 500000`. Confirm Tier-1 fires first; after you approve it, Tier-2 fires. Approve both and confirm the SharePoint row is `Approved` with both decisions captured.
3. Submit a test loan with `LoanAmount = 500000` and **reject** at Tier-1. Confirm Tier-2 never fires and the SharePoint row is `Rejected`.
4. Confirm the AI Summary step's prompt does **not** include any "recommend approve/reject" instruction.

#### Troubleshooting (Part 2)
> **Tip:** If approvals never arrive, check the **Approvals** app in Teams or the **Approvals** mailbox in Outlook before assuming the flow is broken — the email notification can be delayed by several minutes in some tenants.

> **Tip:** If the Tier-2 branch never fires, open the **Condition** action and verify `LoanAmount` is being compared as a **Number**, not as text. Use the expression `int(triggerBody()?['LoanAmount'])` if the type is ambiguous.

> **Warning:** Do **not** wire the agent itself, or the AI summary step, to call the Approvals API as the approver. The Approvals action must always be assigned to a real human mailbox. This is the technical enforcement of the four-eyes / SR 11-7 boundary.

