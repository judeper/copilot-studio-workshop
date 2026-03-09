# Copilot Studio Workshop
## Day 1 — Recruit Track
### Lab 03 — Declarative Agents
⏱ Estimated time: 60 min

#### Overview
In this lab, you will create a declarative agent for Microsoft 365 Copilot and Microsoft Teams. You will define the agent mission, add a reusable prompt tool, test the orchestration, and publish the experience so participants can see how declarative agents extend Microsoft 365 Copilot with focused skills.

![Declarative agent setup screen with name instructions and starter prompts](./assets/lab-03-create-agent.png)

#### Prerequisites
1. Complete Lab 00 and confirm your environment is ready.
2. Complete Lab 02 so you can navigate to **Overview**, **Tools**, and **Publish**.
3. [Maker] Confirm you have permission to create agents in Copilot Studio.
4. [IT Pro] If participants will test in Microsoft Teams, confirm the tenant allows Teams app usage.

#### Step-by-Step Instructions
#### Step 1 — Create a declarative agent shell
1. Go to `https://copilotstudio.microsoft.com` and select **Agents** in the left navigation.
2. Select **Microsoft 365 Copilot** from the agents list, then select **+ Add** on the Overview page.
3. In the **Name** field, enter `Contoso Tech Support Pro`.
4. In the **Description** field, enter `Provides concise, step-by-step IT support with empathy, encouragement, and interactive feedback for common IT issues.`
5. In the **Instructions** field, paste the sample text below and then select **Create**.

```text
- Diagnose and resolve common issues in IT, networking, endpoint devices, and cybersecurity basics.
- Respond with short numbered steps.
- Ask one focused follow-up question if the user did not provide enough detail.
- Summarize the recommended fix at the end of each answer.
- Stay professional, approachable, and supportive.
- Do not answer unrelated creative requests.
- Never ask for passwords, one-time codes, or bypasses to company security controls.
```

#### Step 2 — Add starter prompts participants can reuse
1. In the **Starter prompts** area, add a prompt titled `Cybersecurity Advice` with the text `What are some best practices to keep my computer secure?`.
2. Add a prompt titled `Software Installation Help` with the text `I need help installing a new application on my computer.`
3. Add a prompt titled `Explain IT Terms` with the text `Can you explain what a VPN is and why I might need one?`.
4. Add a prompt titled `Resolve Printer Problem` with the text `My printer is not working. Can you help me fix it?`.
5. Add a prompt titled `Password Reset Guidance` with the text `How do I reset my password securely?`.

#### Step 3 — Add a prompt tool
1. After the agent finishes provisioning, open the **Tools** tab.
2. Select **+ Add a tool**, then choose **Prompt**.
3. In the **Name** field, enter `IT Expert`.
4. In the prompt authoring experience, choose **Manual instructions** and paste the sample prompt below.

```text
I want you to act as an IT Expert. I will provide the problem description. Use clear, understandable language, explain the recommended fix step by step, and include bullet points where helpful. Avoid unnecessary jargon. My problem is [Problem]
```

5. In the input area, add a **Text** input named `Problem` and enter `My laptop restarted unexpectedly. Any advice?` as the sample value.
6. Select **Test** to preview the prompt output.
7. Select **Save**, then select **Add and configure**.

#### Step 4 — Update the agent instructions to call the prompt tool
1. Return to the **Overview** tab.
2. In the **Details** section, select **Edit**.
3. Replace the instructions with the text below, then select **Save**.

```text
When a user asks an IT support question about devices, software, networking, or cybersecurity, run the "IT Expert" prompt. Use the user's latest message as the Problem input. Respond with the prompt output and preserve any troubleshooting sequence already requested by the user.
```

#### Step 5 — Test the declarative agent in Copilot Studio
1. In the **Test** pane, select **Start new test session** to begin with a clean conversation.
2. Enter `My laptop restarted unexpectedly. Any advice?` in the message box and press **Enter**.
3. Review the response and confirm the answer is structured, short, and focused on IT support.
4. Select one of the **Starter prompts** and confirm the same instruction pattern is followed.

#### Step 6 — Publish and test in Microsoft 365 Copilot or Teams
1. Select **Publish** in the top-right corner.
2. In the publish pane, review the **Channels** section and confirm **Microsoft 365 Copilot** and **Microsoft Teams** are listed.
3. Update the **Short description** to `Contoso IT support assistant for fast troubleshooting guidance.`
4. Update the **Developer name** field with your name or team name.
5. Select **Publish** and wait for the completion message.
6. Select **Copy link** or **See agent in Teams** and open the published agent in the chosen client.
7. In Microsoft 365 Copilot or Teams, enter `Can you help me, my laptop is showing a blue screen?` and review the response.

> **Tip:** If you have access to Microsoft 365 Copilot developer mode, enter `-developer on` in Copilot Chat before testing so you can inspect which tool was selected at runtime.

![Published declarative agent shown inside Microsoft 365 Copilot](./assets/lab-03-published-agent.png)

#### Validation
1. Confirm the agent name shown in Copilot Studio is `Contoso Tech Support Pro`.
2. Confirm the **Tools** tab lists the `IT Expert` prompt.
3. Confirm the published experience answers at least one starter prompt and one free-form IT question.
4. If developer mode is available, confirm the `IT Expert` prompt appears in the executed action details.

#### Troubleshooting
> **Tip:** If the prompt does not appear in the **Tools** list, return to the prompt authoring screen and make sure you selected **Save** before **Add and configure**.

> **Tip:** If the response ignores your prompt, reopen the **Details** section and verify the tool name in the instructions matches the saved tool name exactly.

> **Warning:** If publishing is blocked in a trial environment, finish the creation and validation steps in Copilot Studio and ask the facilitator to demo the published experience from a paid environment.

#### Facilitator Notes
1. Encourage participants to keep the declarative agent focused; the point is to extend Microsoft 365 Copilot with a narrow business capability.
2. If the group is mixed, call out that [Maker] tasks happen in Copilot Studio while [IT Pro] participants should pay attention to channel and publishing constraints.
3. Keep the custom prompt lightweight because later labs introduce knowledge sources, topics, adaptive cards, and automation.

