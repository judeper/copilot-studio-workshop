# Copilot Studio Workshop
## Day 1 — Foundation Track
### Lab 09 — Agent Flows
⏱ Estimated time: 45 min

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

