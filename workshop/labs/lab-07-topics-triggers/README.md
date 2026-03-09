# Copilot Studio Workshop
## Day 1 — Recruit Track
### Lab 07 — Topics and Triggers
⏱ Estimated time: 60 min

#### Overview
In this lab, you will add a structured topic that helps employees discover available devices from the SharePoint **Devices** list. You will define a clear trigger, capture an optional device type, use a connector action to retrieve items, and guide the user toward a follow-up request flow.

![Topic authoring canvas with available devices flow](./assets/lab-07-topic-canvas.png)

#### Prerequisites
1. Complete Lab 06 and confirm `Contoso Helpdesk Agent` exists.
2. Confirm the **Devices** list in SharePoint contains at least four items and at least three items have **Status** set to `Available`.
3. [Maker] Confirm you can add a connector tool from within a topic.

#### Step-by-Step Instructions
#### Step 1 — Create a blank topic
1. Open **Contoso Helpdesk Agent** in Copilot Studio.
2. Select the **Topics** tab. If it is hidden, use the tab overflow control and choose **Topics**.
3. Select **+ Add a topic** and then select **From blank**.
4. In the **Name** field, enter `Available devices`.
5. In the **Description** field, enter `This topic helps users find available devices from the Contoso IT SharePoint Devices list.`

#### Step 2 — Add a topic input for device type
1. In the topic canvas, select **Details** in the top toolbar (next to Topic checker).
2. In the **Input** tab, select **Create a new variable**.
3. Enter `VarDeviceType` in the **Name** field.
4. Set **Variable data type** to **Text**.
5. Leave **How will the agent fill this input?** set to **Dynamically fill with the best option**.
6. Enter `The type of device the user is asking for, such as laptop, tablet, phone, or accessory.` in the **Description** field.
7. Save the input and close the details pane.

#### Step 3 — Add the message and SharePoint retrieval action
1. Add a **Send a message** node after the trigger and enter `I'll check the current list of available devices for you.`
2. Select the **+** under the message node, choose **Add a tool**, and then select the **Connector** tab.
3. Search for the SharePoint **Get items** action and select it.
4. Rename the tool to `Get available devices`.
5. In **Site Address**, select your `Contoso IT` SharePoint site.
6. In **List Name**, select `Devices`.
7. In **Filter Query**, enter `Status eq 'Available'`.
8. Save the connector configuration.

#### Step 4 — Store the results and summarize them for the user
1. In the connector output settings, store the response in a variable named `VarDevices`. Select the variable, open its properties, and change the scope from **Topic** to **Global** so later topics can access the results.
2. Add a **Send a message** node after the connector.
3. Switch the message to **Formula** mode if your tenant supports it.
4. Enter a formula such as `"Available devices:" & Char(10) & Concat(Global.VarDevices.value, "- " & ThisRecord.Title & " | " & ThisRecord.Model & Char(10))`. If the formula editor shows errors with `ThisRecord`, try using the unqualified column names `Title` and `Model` instead.
5. Add an **Ask a question** node after the message.
6. Use the question `Would you like to request one of these devices now?` and choose a **Yes/No** response type.

#### Step 5 — Save and reinforce topic routing
1. Select **Save** in the topic toolbar.
2. Return to the **Overview** tab and select **Edit** in the **Details** section.
3. Add this instruction on a new line: `When a user asks about available laptops, tablets, phones, or devices, use the Available devices topic.`
4. Select **Save**.

![Topic test pane showing available devices and yes no question](./assets/lab-07-topic-test.png)

#### Step 6 — Test the topic
1. Open the **Test** pane and select **Start new test session** for a clean conversation.
2. Enter `What laptops are available?` and press **Enter**.
3. Confirm the topic returns a device list and the yes/no follow-up question.
4. Reply `No` to confirm the topic ends cleanly.

> **Tip:** The topic description is important. Generative orchestration uses it to decide when the topic should run, even if the user wording is slightly different from your example phrases.

#### Validation
1. Confirm the **Topics** list includes `Available devices`.
2. Confirm the topic input `VarDeviceType` exists in the topic details.
3. Confirm the SharePoint action is configured against the `Devices` list.
4. Confirm the test session returns available device records and asks whether the user wants to request one.

#### Troubleshooting
> **Tip:** If the topic does not trigger, confirm the description clearly mentions devices and availability, then add one or two example phrases in the trigger area if your tenant shows that option.

> **Tip:** If the SharePoint connector cannot find the list, refresh the page and reopen the action after confirming the site and list exist in SharePoint.

> **Tip:** If the formula fails, start with a static message, save the topic, and then add the formula again with a smaller expression.

#### Facilitator Notes
1. This is the first lab where the agent becomes structured rather than purely generative; slow down enough for participants to understand why the topic exists.
2. Keep the data retrieval simple. The goal is successful retrieval and routing, not perfect OData filtering by device type.
3. Call out the `Global.VarDevices` variable because Lab 08 reuses it for the adaptive card choices.

