# Copilot Studio Workshop

## Day 2 — Operative Track

### Lab 25 — Developer Workflow with VS Code (Optional)

⏱ Estimated time: 30 min

#### Overview
This optional lab shows how developers can work with an existing Copilot Studio agent in Microsoft Visual Studio Code and then sync the update back to Copilot Studio. You will clone the **Hiring Agent** into a local workspace, edit the agent instructions in YAML, apply the change back to the cloud agent, and validate the new behavior in the browser. This is a generally available developer workflow and is intended for participants who want a code-first authoring loop without introducing non-GA dependencies.

#### Prerequisites
1. [Developer] Complete **Lab 13 — Hiring Agent Setup** and **Lab 14 — Agent Instructions**.
2. [Developer] Install **Microsoft Visual Studio Code** and the **Microsoft Copilot Studio** extension, then sign in to the same tenant and environment used for the workshop.
3. [Developer] Confirm you can open **Hiring Agent** in Copilot Studio in the browser.
4. [Developer] Keep the workshop baseline on generally available features and use **GPT-5 Chat** as the preferred hands-on model when it is available in your region.
5. [Maker] This module is optional. If you are not following the developer workflow, remain on **Lab 23** or **Lab 24** while the developer track completes this exercise.

> Tip: The VS Code extension manages the agent definition and synchronization flow, but applying changes is not the same as publishing. Always validate in Copilot Studio after you sync.

#### Step-by-Step Instructions
1. [Developer] Open **Visual Studio Code**.
2. [Developer] Select the **Copilot Studio** icon in the activity bar, or press `Ctrl+Shift+P` and run `Copilot Studio: Clone Agent`.
3. [Developer] Choose the workshop environment, select **Hiring Agent**, and pick a local workspace folder when prompted.
4. [Developer] Wait for the agent definition to download, then review the workspace in **Explorer**.
5. [Developer] Open the **Agent Changes** pane and review remote changes before you edit anything.
6. [Developer] If the change comparison shows remote updates, select **Get** so your local workspace starts from the latest cloud version.

![Cloning the agent and reviewing changes in VS Code](./assets/lab-25-vscode-clone.png)

7. [Developer] In **Explorer**, open the main agent definition file, typically `agent.mcs.yaml` (older projects may use `agent.yaml`).
8. [Developer] Locate the `instructions:` block. If you do not see it immediately, use global search in VS Code for `Hiring Agent` or `instructions:`.
9. [Developer] Update the instructions with one small but visible improvement, such as adding `Always end recruiter-facing guidance with the next recommended hiring action.` or refining the ambiguity rule to request one focused follow-up question.
10. [Developer] Save the file and review the change in the editor diff or the **Source Control** pane.
11. [Developer] Check the **Problems** pane and confirm there are no YAML validation errors.
12. [Developer] Return to the **Agent Changes** pane and review the local change set.
13. [Developer] Select **Apply** to sync the local change back to Copilot Studio.
14. [Developer] Wait for the extension to confirm that the apply operation completed successfully.

> Note: If your agent contains MCP tools, keep using the supported in-product **MCP onboarding wizard** for connection setup and secrets. Do not hand-edit credentials in the YAML files.

15. [Developer] Switch back to the Copilot Studio browser tab and refresh **Hiring Agent**.
16. [Developer] On the **Overview** page, confirm the updated instruction text appears in the **Instructions** card.
17. [Developer] Open **Test your agent** and start a **New test session**.
18. [Developer] Enter a recruiter-style prompt that should reflect your change, such as a request for candidate guidance or interview preparation.
19. [Developer] Confirm the reply shows the instruction change you synced from VS Code.

![Applying changes and validating in Copilot Studio](./assets/lab-25-vscode-apply.png)

20. [Developer] If you want to continue collaborating after the lab, keep the local workspace and use your normal Git workflow for commits and pull requests.

#### Validation
1. [Developer] The **Hiring Agent** opens successfully in the Copilot Studio extension workspace.
2. [Developer] The local agent definition contains your edited instruction text and shows no validation errors.
3. [Developer] The **Apply** operation completes without unresolved remote-change conflicts.
4. [Developer] The same instruction change is visible in the Copilot Studio **Overview** page after refresh.
5. [Developer] A new browser test session produces a response that reflects the change made in VS Code.

#### Troubleshooting
1. [Developer] If the agent does not appear in VS Code, sign out and sign back in to the extension, then confirm you selected the correct environment.
2. [Developer] If **Apply** is blocked, run **Preview** and then **Get** to bring in remote updates before trying again.
3. [Developer] If the YAML file shows errors, undo the last edit or fix the indentation before you apply changes.
4. [Developer] If the browser still shows the old instructions, refresh the page and reopen the agent before testing again.
5. [Developer] If the test response does not change, start a **New test session** so you are not reusing earlier conversation context.
6. [Developer] If you need to adjust a tool-specific prompt because of content filtering, review that prompt's moderation sensitivity in Copilot Studio rather than loosening the whole agent unnecessarily.

#### Facilitator Notes
1. Keep this module clearly optional and direct non-developers to remain on **Lab 23** or **Lab 24**.
2. Emphasize that this workflow is now generally available and fits real developer team practices such as local editing, search, diff review, and source control.
3. Remind participants that **Apply** updates the cloud agent definition but does not publish the agent to end users.
4. If teams ask how MCP fits the developer workflow, explain that MCP is supported in the agent definition, but setup and authentication should still follow the supported GA onboarding wizard in Copilot Studio.
5. If the Copilot Studio extension cannot be installed due to IT policy or marketplace restrictions, the developer can observe the facilitator demo and follow along in the browser. Confirm extension availability before the session starts.


