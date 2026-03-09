# Copilot Studio Workshop
## Day 1 — Recruit Track
### Lab 10 — Event Triggers
⏱ Estimated time: 25 min

#### Overview
In this lab, you will make the Contoso Helpdesk Agent respond autonomously when a new SharePoint support ticket is created. The event trigger will detect the list item, send ticket details to the agent, and use an email action to acknowledge receipt without waiting for a user to start a chat.

![Event trigger configuration for new SharePoint ticket creation](./assets/lab-10-event-trigger.png)

#### Prerequisites
1. Complete Lab 06 and confirm the agent is working.
2. Confirm the `Tickets` SharePoint list exists in the `Contoso IT` site.
3. Confirm you can create flows or triggers in the environment.
4. [IT Pro] Confirm DLP policy allows SharePoint and Outlook connectors.

#### Step-by-Step Instructions
#### Step 1 — Confirm orchestration is enabled
1. Open **Contoso Helpdesk Agent** in Copilot Studio.
2. Select **Settings**.
3. In the **Orchestration** section, confirm **Use generative AI orchestration for your agent's responses** is set to **Yes**.
4. Select **Save** if you changed the setting.

#### Step 2 — Create the SharePoint event trigger
1. Return to the **Overview** tab.
2. In the **Triggers** section, select **+ Add trigger**.
3. In the **Add trigger** dialog, select the **Featured** filter tab if it is not already selected.
4. Select **When an item is created** (SharePoint).
5. In **Trigger name**, enter `New Support Ticket Created in SharePoint`.
5. Wait for the connections to initialize and select **Next**.
6. In **Site Address**, select the `Contoso IT` site.
7. In **List Name**, select `Tickets`.
8. In **Additional instructions to the agent when it's invoked by the trigger**, paste the text below.

```text
New Support Ticket Created in SharePoint: {Body}

Use the Acknowledge SharePoint ticket tool to generate and send a confirmation email.
Do not wait for user input. Work autonomously.
```

9. Select **Create trigger**.

#### Step 3 — Edit the trigger payload in Power Automate
1. In the **Triggers** section, open the **...** menu for `New Support Ticket Created in SharePoint`.
2. Select **Edit in Power Automate**.
3. Open the step that sends the prompt to the copilot.
4. Replace the default body with an expression that includes the submitter name, submitter email, title, description, priority, and ticket ID.
5. Use the **dynamic content** picker to insert the ticket fields into the prompt body. If your trigger provides dynamic content tokens directly, select them from the picker. If you need an expression, use a concatenation similar to the sample below and then select **Save** or **Publish**.

> **Tip:** The exact expression path depends on how Copilot Studio wraps the SharePoint trigger. If the sample expression below returns null values, use the dynamic content picker instead of manual expressions to select the correct fields.

```text
concat('Submitted By Name: ', triggerOutputs()?['body/Author/DisplayName'], '
Submitted By Email: ', triggerOutputs()?['body/Author/Email'], '
Title: ', triggerOutputs()?['body/Title'], '
Issue Description: ', triggerOutputs()?['body/Description'], '
Priority: ', triggerOutputs()?['body/Priority/Value'], '
Ticket ID: ', triggerOutputs()?['body/ID'])
```

#### Step 4 — Add the email action the trigger will call
1. Return to Copilot Studio and open the **Tools** tab.
2. Select **+ Add a tool** and choose **Connector**.
3. Search for **Send an email (V2)** from **Office 365 Outlook**.
4. Select **Add and configure**.
5. Set **Name** to `Acknowledge SharePoint ticket`.
6. Set **Description** to `Sends an email acknowledgment that a SharePoint support ticket was received.`
7. Customize the **To** parameter so the description says `The email address of the person submitting the SharePoint ticket`.
8. Customize the **Body** parameter so the description says `An acknowledgement that the ticket was received and the team will respond within three working days.`
9. Save the tool.

#### Step 5 — Test the autonomous trigger
1. Go back to the **Overview** tab.
2. Select the **Test trigger** icon next to `New Support Ticket Created in SharePoint`.
3. In a second browser tab, open the `Tickets` SharePoint list and select **New**.
4. Create a ticket with **Title** set to `Unable to connect to VPN`, **Description** set to `Unable to connect after a recent password update`, and **Priority** set to `Normal`.
5. Save the SharePoint item.
6. Return to Copilot Studio, refresh the trigger test panel until the event appears, and select **Start testing**.
7. Allow connector prompts if the test panel asks for permission.
8. Review the activity output and confirm the tool call executes.
9. Check the submitter mailbox and confirm the acknowledgment email arrived.

#### Validation
1. Confirm the **Triggers** section lists `New Support Ticket Created in SharePoint`.
2. Confirm the trigger payload includes ticket metadata rather than a generic body blob.
3. Confirm the `Acknowledge SharePoint ticket` tool exists on the **Tools** tab.
4. Confirm a newly created SharePoint ticket causes an autonomous test run.
5. Confirm the acknowledgment email is delivered.

#### Troubleshooting
> **Tip:** If the trigger never appears in the test panel, verify that the SharePoint item was created after the trigger was enabled and refresh the panel again after a short wait.

> **Tip:** If the email tool does not run, confirm the tool name in the trigger instructions matches the saved tool name exactly.

> **Tip:** If the trigger can read the ticket but cannot send email, reconnect the Office 365 Outlook connector under the tool configuration.

> **Warning:** Event triggers use maker credentials. Review data access carefully before you publish the agent broadly.

#### Facilitator Notes
1. Use this lab to explain the difference between user-initiated topics and system-initiated triggers.
2. Call out the credential model clearly so participants understand the governance implications.
3. If testing is slow, demonstrate one successful trigger and let participants focus on reading the configuration rather than waiting for repeated runs.

