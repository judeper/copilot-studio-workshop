# Copilot Studio Workshop
## Day 1 — Foundation Track
### Lab 06 — Build the Customer Service Agent
⏱ Estimated time: 75 min

#### Overview
In this lab, you will create the main workshop agent, `Woodgrove Customer Service Agent`, by describing the experience in natural language. You will refine the generated result, add trusted public knowledge, connect the internal SharePoint site created in Lab 00, apply a metadata filter to improve retrieval quality, upload files for focused local references, and test grounded answers.

![Custom agent created from natural language prompt in Copilot Studio](./assets/lab-06-custom-agent.png)

#### Prerequisites
1. Complete Lab 00 and Lab 04.
2. Confirm the **Woodgrove Bank** SharePoint site exists and you copied the site URL.
3. Confirm the **Woodgrove Customer Service Agent** solution exists and is set as the preferred solution.
4. [Maker] Confirm you can add knowledge sources in Copilot Studio.
5. [Maker] Have two short facilitator-provided banking reference files available locally, such as an account opening guide and a fee schedule document.

#### Step-by-Step Instructions
#### Step 1 — Create the agent from a natural language description
1. Go to `https://copilotstudio.microsoft.com` and select **Home**.
2. In the natural language create box, paste the sample prompt below.
3. Open the **Settings** gear if available and verify the **Preferred solution** is `Woodgrove Customer Service Agent`.
4. Submit the prompt and wait for the agent to provision.

```text
You are the Woodgrove Customer Service Agent. You help bank employees answer customer inquiries about accounts, service requests, and banking products. Always retrieve information from the Woodgrove Bank SharePoint site. Never invent account numbers, balances, or customer details.

For customer inquiries:
1) Ask one focused question if details are missing.
2) Look up relevant account or service request information first.
3) Provide clear, numbered step-by-step guidance.
4) Offer one or two alternative paths if the first response does not resolve the inquiry.
5) After two or three attempts, recommend escalation and provide a short case summary.

For account lookups:
1) Ask what type of account or information the employee needs.

Never disclose sensitive financial data to unauthorized parties. Refuse requests to bypass compliance controls. Include source references when you use internal guidance.
```

#### Step 2 — Rename, set the model, and review the generated agent
1. After provisioning finishes, stay on the **Overview** tab.
2. In the **Details** section, select **Edit**.
3. Replace the generated **Name** with `Woodgrove Customer Service Agent`.
4. Review the generated description and instructions, then select **Save**.
5. In the **Select your agent's model** section, open the dropdown and select **GPT-5 Chat** if it is available in your region. This is the workshop baseline model. The picker labels **GPT-4.1** as "Default" — you need to actively select GPT-5 Chat. If GPT-5 Chat is not available, keep **GPT-4.1** and note the limitation in your workshop notes. GPT-4.1 is a fully supported generally available model that produces equivalent results for all Day 1 exercises — you do not need GPT-5 Chat to complete this workshop successfully.
6. Scroll through the Overview tab and check the top tab row for AI-suggested sections such as Knowledge, Tools, and Topics so you understand what Copilot proposed automatically.

#### Step 3 — Add public knowledge sources and disable open web search
1. In the **Knowledge** section, select **+ Add knowledge** > **Public websites** and enter the URL `https://support.microsoft.com`.
2. Add a second website with the value `https://learn.microsoft.com/troubleshoot/`.
3. Select **Add to agent**.
4. Open **Settings** and set **Use information from the Web** to **Off** so the agent uses only the sources you explicitly approved. This toggle may also appear on the **Overview** page depending on your agent configuration.
5. Also set **Allow the AI to use its own general knowledge** to **Off** so the agent relies exclusively on the knowledge sources you configure.

#### Step 4 — Add the internal SharePoint knowledge source and filter it
1. In the **Knowledge** section, select **+ Add knowledge** and choose **SharePoint**.
2. Paste the **Woodgrove Bank** site URL from Lab 00 into the **SharePoint URL** field.
3. In the **Name** field, enter `Woodgrove Bank`.
4. Select **Add** and then select **Add to agent**.
5. Open the newly added SharePoint source and select the **Advanced settings** tab.
6. Under **Filter this knowledge source**, select an attribute from the dropdown, choose an operator such as `is equal to` or `contains`, and enter a value. For example, use a filename filter such as `File name contains Account` or a scope rule such as `Modified date is within the last 365 days`.
7. Select **Save** and wait for the SharePoint source to finish connecting before you test the agent.

![Knowledge section with public websites and SharePoint source added](./assets/lab-06-knowledge-sources.png)

#### Step 5 — Add file-based knowledge for focused local references
1. In the **Knowledge** section, select **+ Add knowledge** and choose **Files**.
2. Upload at least two facilitator-provided local files, such as an account opening guide and a fee schedule document.
3. Select **Add** and wait for the files to finish indexing.

> **Tip:** File-based knowledge is useful for focused operational references that are not stored in SharePoint or a public website.

#### Step 6 — Test grounded responses
1. In the **Test** pane, select **New test session**.
2. Enter `What checking accounts are currently active?` and review the answer.
3. Enter `Tell me about Sarah Johnson's account.` and observe whether the agent references your connected sources or asks a clarifying question.
4. Enter `Are there any frozen accounts?` and confirm whether the answer can use the SharePoint data or uploaded reference files.
5. If the tenant shows the **Activity map**, inspect the knowledge calls and citations.

#### Step 7 — Tighten the instructions if the answer quality needs work
1. In the **Details** section, select **Edit**.
2. Add a line such as `When answering from SharePoint, cite the source in plain language.`
3. Add a line such as `Keep customer service answers under 10 numbered steps unless the user asks for more detail.`
4. Add a line such as `Prefer the most relevant filtered enterprise source before using broader knowledge.`
5. Select **Save** and rerun the same tests.

#### Validation
1. Confirm the agent name is `Woodgrove Customer Service Agent`.
2. Confirm the **Knowledge** section lists both public websites, the `Woodgrove Bank` SharePoint source, and uploaded reference files.
3. Confirm **Use information from the Web** is set to **Off** in **Settings**.
4. Confirm the SharePoint source has at least one saved metadata filter or scoped rule.
5. Confirm the test pane returns at least one grounded answer with a trusted source reference.

#### Troubleshooting
> **Tip:** If the SharePoint source shows an authentication prompt, sign in with the same account you used to create the site and then reopen the **Knowledge** section.

> **Tip:** If the SharePoint URL is rejected, copy the site root URL only, such as `https://woodgrovebank.sharepoint.com/sites/WoodgroveBank`, and do not paste a list-specific URL.

> **Tip:** If the SharePoint connection succeeds but answers do not appear, wait for indexing to complete and test again with a question that clearly matches content in the site.

> **Tip:** If you see `You don't have access` or `Connection not authorized`, verify that your account is a member of the SharePoint site and that the environment's DLP policy does not block the connector.

> **Warning:** If responses still come from the open web, confirm **Use information from the Web** is set to **Off** in **Settings** and no extra public sources were added accidentally.

#### Facilitator Notes
1. Remind participants that natural language creation accelerates setup, but human review is still required.
2. Use this lab to reinforce good grounding discipline: trusted sources on, open web off unless the use case explicitly requires it.
3. Call out that stronger enterprise grounding often improves relevance but can slightly increase retrieval latency as more scoped sources are evaluated.
4. The SharePoint troubleshooting section is intentionally detailed because this is the most common blocker in live workshops.

