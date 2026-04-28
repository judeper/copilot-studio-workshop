# Copilot Studio Workshop
## Day 1 — Foundation Track
### Lab 03 — Declarative Agents
⏱ Estimated time: 60 min (core) + 15 min (optional Agent Builder section)

#### Overview
In this lab, you will create a declarative agent for Microsoft 365 Copilot and Microsoft Teams. You will define the agent purpose, add a reusable prompt tool, test the orchestration, and publish the experience so participants can see how declarative agents extend Microsoft 365 Copilot with focused skills.

![Declarative agent setup screen with name instructions and starter prompts](./assets/lab-03-create-agent.png)

#### Prerequisites
1. Complete Lab 00 and confirm your environment is ready.
2. Complete Lab 02 so you can navigate to **Overview**, **Tools**, and **Publish**.
3. [Maker] Confirm you have permission to create agents in Copilot Studio.
4. [IT Pro] If participants will test in Microsoft Teams, confirm the tenant allows Teams app usage.

> **Note:** This lab creates a declarative agent for Microsoft 365 Copilot, which requires a **Microsoft 365 Copilot license** (such as the Copilot add-on for Microsoft 365 E3/E5). If your workshop account does not have this license, your facilitator will demonstrate this lab. You can observe the pattern without hands-on access.

#### Step-by-Step Instructions
#### Step 1 — Create a declarative agent shell
1. Go to `https://copilotstudio.microsoft.com` and select **Agents** in the left navigation.
2. Select **Microsoft 365 Copilot** from the agents list, then select **+ Add** on the Overview page.
3. In the **Name** field, enter `Woodgrove Banking Assistant`.
4. In the **Description** field, enter `Provides concise, step-by-step banking policy with empathy, encouragement, and interactive feedback for common IT issues.`
5. In the **Instructions** field, paste the sample text below and then select **Create**.

```text
- Advise on common banking policies, account types, loan products, and regulatory compliance basics.
- Respond with short numbered steps.
- Ask one focused follow-up question if the customer did not provide enough detail.
- Summarize the recommended action at the end of each answer.
- Stay professional, approachable, and supportive.
- Do not answer unrelated creative requests.
- Never share specific account balances, SSNs, or bypasses to compliance controls.
```

#### Step 2 — Add starter prompts participants can reuse
1. In the **Starter prompts** area, add a prompt titled `Account Types` with the text `What types of savings accounts does the bank offer?`.
2. Add a prompt titled `Loan Products` with the text `Can you explain the different mortgage options available?`
3. Add a prompt titled `Banking Terms` with the text `Can you explain what an APR is and how it affects my loan?`.
4. Add a prompt titled `Wire Transfer Policy` with the text `What is the policy for international wire transfers?`.
5. Add a prompt titled `Fraud Prevention` with the text `What should I do if I suspect fraudulent activity on my account?`.

#### Step 3 — Add a prompt tool
1. After the agent finishes provisioning, open the **Tools** tab.
2. Select **+ Add a tool**, then choose **Prompt**.
3. In the **Name** field, enter `Banking Policy Advisor`.
4. In the prompt authoring experience, choose **Manual instructions** and paste the sample prompt below.

```text
I want you to act as an Banking Policy Advisor. I will provide the problem description. Use clear, understandable language, explain the recommended fix step by step, and include bullet points where helpful. Avoid unnecessary jargon. My problem is [Problem]
```

5. In the input area, add a **Text** input named `Question` and enter `What are the eligibility requirements for a home equity line of credit?` as the sample value.
6. Select **Test** to preview the prompt output.
7. Select **Save**, then select **Add and configure**.

#### Step 4 — Update the agent instructions to call the prompt tool
1. Return to the **Overview** tab.
2. In the **Details** section, select **Edit**.
3. Replace the instructions with the text below, then select **Save**.

```text
When a user asks a banking policy question about accounts, loans, compliance, or financial products, run the "Banking Policy Advisor" prompt. Use the user's latest message as the Question input. Respond with the prompt output and preserve any advisory sequence already requested by the user.
```

#### Step 5 — Test the declarative agent in Copilot Studio
1. In the **Test** pane, select **Start new test session** to begin with a clean conversation.
2. Enter `What are the eligibility requirements for a home equity line of credit?` in the message box and press **Enter**.
3. Review the response and confirm the answer is structured, short, and focused on banking policy.
4. Select one of the **Starter prompts** and confirm the same instruction pattern is followed.

#### Step 6 — Publish and test in Microsoft 365 Copilot or Teams
1. Select **Publish** in the top-right corner.
2. In the publish pane, review the **Channels** section and confirm **Microsoft 365 Copilot** and **Microsoft Teams** are listed.
3. Update the **Short description** to `Woodgrove Bank assistant for fast banking policy and account guidance.`
4. Update the **Developer name** field with your name or team name.
5. Select **Publish** and wait for the completion message.
6. Select **Copy link** or **See agent in Teams** and open the published agent in the chosen client.
7. In Microsoft 365 Copilot or Teams, enter `Can you explain the requirements for opening a business checking account?` and review the response.

> **Tip:** If you have access to Microsoft 365 Copilot developer mode, enter `-developer on` in Copilot Chat before testing so you can inspect which tool was selected at runtime.

![Published declarative agent shown inside Microsoft 365 Copilot](./assets/lab-03-published-agent.png)

#### Validation
1. Confirm the agent name shown in Copilot Studio is `Woodgrove Banking Assistant`.
2. Confirm the **Tools** tab lists the `Banking Policy Advisor` prompt.
3. Confirm the published experience answers at least one starter prompt and one free-form banking question.
4. If developer mode is available, confirm the `Banking Policy Advisor` prompt appears in the executed action details.

#### Troubleshooting
> **Tip:** If the prompt does not appear in the **Tools** list, return to the prompt authoring screen and make sure you selected **Save** before **Add and configure**.

> **Tip:** If the response ignores your prompt, reopen the **Details** section and verify the tool name in the instructions matches the saved tool name exactly.

> **Warning:** If publishing is blocked in a trial environment, finish the creation and validation steps in Copilot Studio and ask the facilitator to demo the published experience from a paid environment.

#### Optional: Build a quick agent with M365 Agent Builder
⏱ Estimated time: 10–15 min — **optional, requires Microsoft 365 Copilot license**

> **Prerequisites:** This walkthrough requires an active **Microsoft 365 Copilot** license assigned to your workshop account. Run `powershell -File .\workshop\automation\Invoke-WorkshopPrereqCheck.ps1` and review the license check output. If the check flags your account as unlicensed, **skip this section** and continue with the Copilot Studio path you just completed. The facilitator may demonstrate the Agent Builder flow from a licensed tenant instead.

This optional section contrasts the lightweight **M365 Agent Builder** authoring surface (inside Microsoft 365 Copilot) with the full **Copilot Studio** experience you used above. Many business users will start in Agent Builder; this exercise helps you explain when each tool is the right choice for Woodgrove Bank scenarios.

##### Step A — Open the Agent Builder experience
1. Open `https://m365.cloud.microsoft/copilot` in a new browser tab and sign in with your licensed workshop account.
2. In the left navigation, select **Agents**, then select **Build an agent** (or **Create agent** depending on your tenant rollout).

##### Step B — Describe the agent in natural language
1. In the **Describe your agent** prompt, enter the following text:

```text
Create an agent that helps Woodgrove Bank customers find the right loan product based on their goals, timeline, and budget. Ask one focused question at a time, summarize the recommended product at the end, and never quote specific rates or eligibility decisions.
```

2. Wait for Agent Builder to generate a draft. Review the auto-generated **Name**, **Description**, **Instructions**, and **Starter prompts**.
3. If Agent Builder offers to attach knowledge from your OneDrive or SharePoint, decline for this walkthrough — keep the agent ungrounded so the contrast with the Copilot Studio version stays clear.

##### Step C — Test the agent inside Microsoft 365 Copilot
1. Select **Test** (or **Try it**) in the right pane.
2. Enter `I am 32, want to buy my first home in 18 months, and have $40,000 saved.` and review the response.
3. Try one of the suggested starter prompts to confirm the generated instructions guide the conversation.

##### Step D — Compare the two authoring surfaces
Use this contrast table to discuss when each tool is appropriate. The Woodgrove Bank scenario in this workshop intentionally uses **Copilot Studio** for the rest of Day 1 and all of Day 2.

| Aspect | M365 Agent Builder | Copilot Studio |
|---|---|---|
| Audience reach | Personal, team, or org-wide inside Microsoft 365 Copilot | Multi-channel: Teams, web, Microsoft 365 Copilot, custom channels |
| Authoring depth | Natural-language description plus light configuration | Full topic designer, Power Fx, flows, actions, MCP, generative orchestration |
| Governance | Sits within Microsoft 365 admin and Copilot sharing scope | Full ALM with environments, solutions, DLP, pipelines, Dataverse security |
| Knowledge sources | Microsoft 365 sources: SharePoint, OneDrive, public web | Wide: SharePoint, Dataverse, files, custom connectors, MCP servers |
| Best for | Quick personal or team productivity helpers | Production-grade enterprise agents with complex workflows |

##### Step E — Reflect on the Woodgrove choice
1. The **Woodgrove Customer Service Agent** you are building across this workshop lives in **Copilot Studio** because Woodgrove Bank needs governed ALM, Dataverse data, multi-channel reach (Teams plus the customer portal), connected and child agent orchestration, and policy-grade moderation. None of those requirements fit Agent Builder's lightweight scope.
2. Note one Woodgrove use case that *would* be a good fit for Agent Builder (for example, a personal assistant that summarizes a relationship manager's recent client emails). Park that idea — you can build it later inside Microsoft 365 Copilot without adding load to the central Copilot Studio environment.

> **Tip:** You can leave the Agent Builder draft saved to your personal Microsoft 365 Copilot scope. It will not interfere with the rest of the workshop labs.

#### Facilitator Notes
1. Encourage participants to keep the declarative agent focused; the point is to extend Microsoft 365 Copilot with a narrow banking capability.
2. If the group is mixed, call out that [Maker] tasks happen in Copilot Studio while [IT Pro] participants should pay attention to channel and publishing constraints.
3. Keep the custom prompt lightweight because later labs introduce knowledge sources, topics, adaptive cards, and automation.
4. **Optional Agent Builder section.** Before starting, ask the room "Who has Microsoft 365 Copilot assigned to their workshop account?" and reference the prereq check output. If fewer than half the room is licensed, skip the hands-on portion and run Step D (the contrast table) as a 5-minute facilitator-led discussion using your own licensed tenant as the demo. The teaching goal is the contrast — when to use which tool — not the click-through.
5. Reinforce the Woodgrove framing in Step E: the rest of the workshop uses Copilot Studio because the bank needs governance, ALM, channel reach, and complex workflows. Agent Builder is a complement, not a competitor.

