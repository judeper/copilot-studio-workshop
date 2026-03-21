# Copilot Studio Workshop
## Day 1 — Recruit Track
### Lab 09 — Agent Flows
⏱ Estimated time: 45 min

#### Overview
In this lab, you will connect the Adaptive Card from Lab 08 to a Power Automate flow so the form submission creates a SharePoint record, updates device availability, and emails the manager. This turns the request topic from a conversation into a working business process.

![Power Automate flow designer with agent trigger and SharePoint actions](./assets/lab-09-agent-flow.png)

#### Prerequisites
1. Complete Lab 08 and confirm the adaptive card submits values for `deviceSelectionId`, `managerEmailId`, and `commentsId`.
2. Confirm the `Devices` SharePoint list contains at least one item with **Status** set to `Available`.
3. [Maker] Confirm you can create flows in the same environment as the agent.
4. [IT Pro] Confirm the SharePoint and Office 365 Outlook connectors are allowed by DLP policy.

#### Step-by-Step Instructions
#### Step 1 — Create the SharePoint list that will store requests

> **Tip:** Before building the flow, open the **Devices** list and confirm the **Status** choice column includes `Requested` as a valid choice. If it is missing, add it now — the flow in Step 6 changes device status to `Requested` after a submission.

1. Open the `Contoso IT` SharePoint site from Lab 00.
2. Select **New** > **List**.
3. Select **Blank list**.
4. In the **Name** field, enter `Device Requests` and select **Create**.
5. Add the following columns from **+ Add column**: `Requested By` as **Single line of text**, `Manager Email` as **Single line of text**, `Comments` as **Multiple lines of text**, `Device Model` as **Single line of text**, `Device ID` as **Number**, `Request Status` as **Choice**, and `Requested On` as **Date and time**.
6. In the **Request Status** choice column, keep `Pending` as the default value and add `Approved` and `Rejected` as additional choices.

#### Step 2 — Add a flow after the Adaptive Card submission
1. Open **Contoso Helpdesk Agent** and then open the `Request device` topic.
2. Under the **Ask with adaptive card** node, select **+**.
3. Choose **Add a tool** and then select **Agent flow** under **Create new**.
4. Wait for the Agent flow designer to open in the same window.

#### Step 3 — Define flow inputs from the Adaptive Card
1. Select the **When an agent calls the flow** trigger to expand it.
2. Add a **Text** input named `DeviceSharePointId`.
3. Add a **Text** input named `ManagerEmail`.
4. Add a **Text** input named `RequesterName`.
5. Add a **Text** input named `AdditionalComments`.
6. Mark `AdditionalComments` as optional if the flow designer provides that option.

#### Step 4 — Retrieve the device details from SharePoint
1. Select the **+** button between the trigger and **Respond to the agent**.
2. Search for the SharePoint **Get item** action and add it.
3. Rename the step to `Get Device`.
4. In **Site Address**, select the `Contoso IT` site.
5. In **List Name**, select `Devices`.
6. In **Id**, insert the `DeviceSharePointId` trigger input.

> **Tip:** The adaptive card outputs the device ID as a text string. If the flow fails with a type error, select the **Expression** tab in the **Id** field and enter `int(triggerBody()?['DeviceSharePointId'])` to convert the text value to an integer before sending it to SharePoint.

#### Step 5 — Create the request record in SharePoint
1. Add a new SharePoint **Create item** action.
2. Rename the step to `Create Device Request`.
3. In **Site Address**, select the `Contoso IT` site.
4. In **List Name**, select `Device Requests`.
5. Map **Title** to an expression such as `concat('Device request - ', RequesterName)` if the list requires a title.
6. Map **Requested By** to `RequesterName`.
7. Map **Manager Email** to `ManagerEmail`.
8. Map **Comments** to `AdditionalComments`.
9. Map **Device Model** to the **Model** output from `Get Device`.
10. Map **Device ID** to the **ID** output from `Get Device`.
11. Map **Request Status** to `Pending`.
12. Map **Requested On** to `utcNow()` if the field is available. To enter this, select the **Expression** tab (not **Dynamic content**) in the field editor and type `utcNow()` exactly as shown, then select **OK**.

#### Step 6 — Update the original device record and notify the manager
1. Add a SharePoint **Update item** action.
2. Rename the step to `Mark Device Requested`.
3. Use the same `Contoso IT` site and the `Devices` list.
4. Map **Id** to the **ID** output from `Get Device`.
5. Map the required fields from the `Get Device` output back into the **Update item** action so the existing values are preserved. At minimum, map **Title**, **Manufacturer**, **Model**, **Asset Type**, **Color**, **Serial Number**, **Purchase Date**, **Purchase Price**, and **Order #** from the `Get Device` step, then change **Status** to `Requested`.
6. Add an **Office 365 Outlook – Send an email (V2)** action.
7. In **To**, insert `ManagerEmail`.
8. In **Subject**, enter `New device request from` followed by the `RequesterName` input.
9. In **Body**, include the requester name, selected device model, and any additional comments.

#### Step 7 — Return a confirmation message to the topic
1. Add a **Respond to agent** action.
2. Add a **Text** output named `ConfirmationMessage`.
3. Set the output value to `Your request for ` plus the **Model** output from `Get Device` plus ` has been submitted for manager review.`
4. Save the flow and return to the topic.

#### Step 8 — Map the Adaptive Card outputs to the flow inputs
1. In the topic tool node, map `DeviceSharePointId` to `deviceSelectionId` from the adaptive card output.
2. Map `ManagerEmail` to `managerEmailId`.
3. Map `RequesterName` to `System.User.DisplayName`.

> **Tip:** `System.User.DisplayName` is only populated when the agent is accessed via a signed-in channel such as Teams or SharePoint. In the unauthenticated test pane, this value will be blank, which causes the flow to create a record with an empty requester name. This is expected during testing — in production the user will always be signed in.

4. Map `AdditionalComments` to `commentsId`.
5. Add a **Send a message** node after the flow.
6. Insert the `ConfirmationMessage` flow output into the message.
7. Save the topic.

![Topic node showing flow inputs mapped from adaptive card outputs](./assets/lab-09-topic-mapping.png)

#### Step 9 — Test the end-to-end process
1. Open the **Test** pane and start a new session.
2. Enter `I need a laptop` and move through the `Available devices` topic.
3. Reply `Yes` to open the adaptive card.
4. Select a device, enter a valid manager email, add a short comment, and submit the card.
5. Wait for the confirmation message from the flow.
6. Open the `Device Requests` SharePoint list and confirm a new item was created.
7. Open the original `Devices` list item and confirm **Status** changed to `Requested`.

> **Tip:** The Adaptive Card submission is the trigger point. If the flow works but the topic does not, the issue is usually input mapping rather than the actions themselves.

#### Validation
1. Confirm the Power Automate flow contains the trigger, `Get Device`, `Create Device Request`, `Mark Device Requested`, `Send an email (V2)`, and `Respond to agent` steps.
2. Confirm the adaptive card outputs are mapped correctly in the topic tool node.
3. Confirm a new row appears in the `Device Requests` SharePoint list after a test submission.
4. Confirm the selected device record changes from `Available` to `Requested`.
5. Confirm the manager receives the email notification.

#### Troubleshooting
> **Tip:** If the flow cannot update the `Devices` item, open the **Update item** action and make sure all required SharePoint columns are mapped, not just **Status**.

> **Tip:** If the flow runs but the topic returns no message, open the **Respond to agent** step and confirm the `ConfirmationMessage` output exists and is mapped in the topic.

> **Tip:** If the `DeviceSharePointId` input is blank, resubmit the adaptive card and verify the `ChoiceSet` values are actual SharePoint item IDs rather than display text.

> **Warning:** If the `Device Requests` list does not exist before you save the flow, the SharePoint actions will not populate the expected column pickers.

#### Facilitator Notes
1. Call out explicitly that this lab connects conversational capture to system writeback, which is the turning point for business value.
2. If time is limited, provide a pre-created `Device Requests` list so participants can focus on the flow and topic mapping.
3. The user requirement for this workshop is satisfied only when the Adaptive Card submission writes back to SharePoint, so validate that step carefully.

