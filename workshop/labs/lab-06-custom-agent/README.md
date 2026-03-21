# Copilot Studio Workshop
## Day 1 — Recruit Track
### Lab 06 — Custom Agent
⏱ Estimated time: 75 min

#### Overview
In this lab, you will create the main workshop agent, `Contoso Helpdesk Agent`, by describing the experience in natural language. You will refine the generated result, add trusted public knowledge, connect the internal SharePoint site created in Lab 00, apply a metadata filter to improve retrieval quality, upload files for focused local references, and test grounded answers.

![Custom agent created from natural language prompt in Copilot Studio](./assets/lab-06-custom-agent.png)

#### Prerequisites
1. Complete Lab 00 and Lab 04.
2. Confirm the **Contoso IT** SharePoint site exists and you copied the site URL.
3. Confirm the **Contoso Helpdesk Agent** solution exists and is set as the preferred solution.
4. [Maker] Confirm you can add knowledge sources in Copilot Studio.
5. [Maker] Have two short facilitator-provided helpdesk reference files available locally, such as a device policy and a VPN guide.

#### Step-by-Step Instructions
#### Step 1 — Create the agent from a natural language description
1. Go to `https://copilotstudio.microsoft.com` and select **Home**.
2. In the natural language create box, paste the sample prompt below.
3. Open the **Settings** gear if available and verify the **Preferred solution** is `Contoso Helpdesk Agent`.
4. Submit the prompt and wait for the agent to provision.

```text
You are an IT Help Desk assistant that helps employees resolve common IT issues and find available devices. Be polite, concise, and helpful. Use Microsoft Support as the primary source: https://support.microsoft.com and Microsoft Learn troubleshooting when needed: https://learn.microsoft.com/troubleshoot/. Do not invent steps. If you cannot verify official guidance, say so and offer safe diagnostics plus escalation.

For troubleshooting:
1) Ask one focused question if details are missing.
2) Try quick fixes first.
3) Provide numbered step-by-step instructions.
4) Offer one or two alternative branches if the first fix fails.
5) After two or three branches, recommend escalation and provide a short ticket summary.

For devices:
1) Ask what type of device the user needs.

Never ask for passwords or one-time codes. Refuse requests to bypass security. Include source links when you use public guidance.
```

#### Step 2 — Rename, set the model, and review the generated agent
1. After provisioning finishes, stay on the **Overview** tab.
2. In the **Details** section, select **Edit**.
3. Replace the generated **Name** with `Contoso Helpdesk Agent`.
4. Review the generated description and instructions, then select **Save**.
5. In the **Select your agent's model** section, open the dropdown and select **GPT-5 Chat** if it is available in your region. This is the workshop baseline model. If GPT-5 Chat is not available, keep the best generally available option (such as **GPT-4.1**) and note the limitation in your workshop notes. GPT-4.1 is a fully supported generally available model that produces equivalent results for all Day 1 exercises — you do not need GPT-5 Chat to complete this workshop successfully.
6. Scroll through the Overview tab and check the top tab row for AI-suggested sections such as Knowledge, Tools, and Topics so you understand what Copilot proposed automatically.

#### Step 3 — Add public knowledge sources and disable open web search
1. In the **Knowledge** section, select **+ Add** next to the suggested `https://support.microsoft.com` website if it appears, or select **+ Add knowledge** > **Public websites** and enter the same URL manually.
2. Add a second website with the value `https://learn.microsoft.com/troubleshoot/`.
3. Select **Add to agent**.
4. Open **Settings** and set **Use information from the Web** to **Off** so the agent uses only the sources you explicitly approved. This toggle may also appear on the **Overview** page depending on your agent configuration.

#### Step 4 — Add the internal SharePoint knowledge source and filter it
1. In the **Knowledge** section, select **+ Add knowledge** and choose **SharePoint**.
2. Paste the **Contoso IT** site URL from Lab 00 into the **SharePoint URL** field.
3. In the **Name** field, enter `Contoso IT`.
4. Select **Add** and then select **Add to agent**.
5. Open the newly added SharePoint source and select the **Advanced settings** tab.
6. Under **Filter this knowledge source**, select an attribute from the dropdown, choose an operator such as `is equal to` or `contains`, and enter a value. For example, use a filename filter such as `File name contains Device` or a scope rule such as `Modified date is within the last 365 days`.
7. Select **Save** and wait for the SharePoint source to finish connecting before you test the agent.

![Knowledge section with public websites and SharePoint source added](./assets/lab-06-knowledge-sources.png)

#### Step 5 — Add file-based knowledge for focused local references
1. In the **Knowledge** section, select **+ Add knowledge** and choose **Files**.
2. Upload at least two facilitator-provided local files, such as a device checkout guide and a VPN quick-reference document.
3. Select **Add** and wait for the files to finish indexing.

> **Tip:** File-based knowledge is useful for focused operational references that are not stored in SharePoint or a public website.

#### Step 6 — Test grounded responses
1. In the **Test** pane, select **New test session**.
2. Enter `How can I check the warranty status of my Surface?` and review the answer.
3. Enter `What devices are available right now?` and observe whether the agent references your connected sources or asks a clarifying question.
4. Enter `What is the fastest approved path for VPN access?` and confirm whether the answer can use the uploaded reference files.
5. If the tenant shows the **Activity map**, inspect the knowledge calls and citations.

#### Step 7 — Tighten the instructions if the answer quality needs work
1. In the **Details** section, select **Edit**.
2. Add a line such as `When answering from SharePoint or Microsoft Support, cite the source in plain language.`
3. Add a line such as `Keep troubleshooting answers under 10 numbered steps unless the user asks for more detail.`
4. Add a line such as `Prefer the most relevant filtered enterprise source before using broader knowledge.`
5. Select **Save** and rerun the same tests.

#### Validation
1. Confirm the agent name is `Contoso Helpdesk Agent`.
2. Confirm the **Knowledge** section lists both public websites, the `Contoso IT` SharePoint source, and uploaded reference files.
3. Confirm **Use information from the Web** is set to **Off** in **Settings**.
4. Confirm the SharePoint source has at least one saved metadata filter or scoped rule.
5. Confirm the test pane returns at least one grounded answer with a trusted source reference.

#### Troubleshooting
> **Tip:** If the SharePoint source shows an authentication prompt, sign in with the same account you used to create the site and then reopen the **Knowledge** section.

> **Tip:** If the SharePoint URL is rejected, copy the site root URL only, such as `https://contoso.sharepoint.com/sites/ContosoIT`, and do not paste a list-specific URL.

> **Tip:** If the SharePoint connection succeeds but answers do not appear, wait for indexing to complete and test again with a question that clearly matches content in the site.

> **Tip:** If you see `You don't have access` or `Connection not authorized`, verify that your account is a member of the SharePoint site and that the environment's DLP policy does not block the connector.

> **Warning:** If responses still come from the open web, confirm **Use information from the Web** is set to **Off** in **Settings** and no extra public sources were added accidentally.

#### Facilitator Notes
1. Remind participants that natural language creation accelerates setup, but human review is still required.
2. Use this lab to reinforce good grounding discipline: trusted sources on, open web off unless the use case explicitly requires it.
3. Call out that stronger enterprise grounding often improves relevance but can slightly increase retrieval latency as more scoped sources are evaluated.
4. The SharePoint troubleshooting section is intentionally detailed because this is the most common blocker in live workshops.

