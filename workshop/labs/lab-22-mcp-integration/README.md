# Copilot Studio Workshop

## Day 2 — Enterprise Track

### Lab 22 — MCP Integration

⏱ Estimated time: 45 min

#### Overview
In this lab, you will extend the Loan Processing Agent solution with Model Context Protocol (MCP) capabilities. You will browse the pre-built Work IQ MCP server catalog in Copilot Studio, add user profile and calendar servers to your agent, and then use those tools to help schedule an loan review meeting.

> **Note:** MCP integration with pre-built servers uses **Work IQ MCP**, the intelligence layer that grounds agents in real-time Microsoft 365 context. Work IQ MCP requires a **Microsoft 365 Copilot license**. If the MCP servers do not appear in your environment, ask your facilitator whether the required license and access are enabled. If MCP servers are unavailable, the facilitator will demo this lab.

> **Transport guidance:** This lab uses pre-built, Microsoft-hosted Work IQ MCP servers, which are added through the **in-product MCP onboarding wizard** in Copilot Studio. You do not edit JSON manifests, paste secrets, or configure transport settings by hand. If your team later builds a *custom* MCP server for the Loan Processing Agent, use **Streamable HTTP** as the transport — it is the currently recommended MCP transport for new Copilot Studio integrations. **Server-Sent Events (SSE)** is deprecated as a transport for new MCP servers; existing SSE-based servers continue to work but should be migrated to Streamable HTTP.

#### Prerequisites
1. Complete **Lab 15** so you have **Loan Processing Agent** ready for extension.
2. **Microsoft 365 Copilot license** is required for Work IQ MCP servers. Confirm your workshop account has this license before starting.
3. Have a manager configured for your workshop account in the Microsoft 365 Admin Center.
4. Have at least one meeting on your calendar in the upcoming 24 hours.
5. Have one coworker account available for a test meeting invitation.
6. Confirm that your account can create or approve the Microsoft 365 connections required by the MCP tools.
7. Verify MCP server availability: open **Tools** > **+ Add a tool** > select the **Model Context Protocol** filter tab. If no servers appear, notify your facilitator before this lab begins so they can arrange a demo or troubleshoot access.

#### Step-by-Step Instructions
#### Part 1 — Browse the MCP server catalog
1. Open **Loan Processing Agent** in Copilot Studio.
2. Select **Tools** in the top navigation and then select **+ Add a tool**.
3. In the **Add tool** dialog, locate the filter row: **All | Connector | Prompt | Flow | REST API | Model Context Protocol**.
4. Select the **Model Context Protocol** filter tab.
5. Review the pre-built **Work IQ MCP** servers that appear, such as Work IQ Mail, Work IQ Calendar, Work IQ Teams, and others.

#### Part 2 — Add the User Profile MCP server
1. From the filtered MCP server list, select the **Work IQ** user profile server (Microsoft MCP Servers).
2. In the connection dropdown, select **Create new connection**.
3. Select **Create** and then sign in with your workshop account when the pick-your-account popup appears.
4. After authentication, select **Add and configure** to add the server to your agent.
5. Scroll down on the tool overview page to review the MCP tools included in this server (such as *getMyManager*, *getMyProfile*, *getDirectReports*).
6. Select **Test** to open the test pane.
7. Enter `Who is my manager?` and press **Enter**.
8. When the consent card appears, select **Allow** to grant the MCP server access to your data. This consent prompt appears once per agent-and-server combination.
9. Confirm the agent returns your manager\'s name and details.

#### Part 3 — Add the Outlook Calendar MCP server
1. Return to **Tools** and select **+ Add a tool**.
2. Select the **Model Context Protocol** filter tab.
3. Select **Work IQ Calendar** (Microsoft MCP Servers).
4. Select **Add and configure**. If a connection already exists from Part 2, it may be reused automatically.
5. Scroll down to review the MCP tools in this server (such as *findMeetingTimes*, *createEvent*, *getMyCalendarEvents*).
6. In the test pane, enter `Get my meetings for today.`
7. If the consent card appears again for this new server, select **Allow**.
8. Confirm the agent returns your current meeting information.

![Loan Processing Agent with MCP tools configured](./assets/lab-22-mcp-tools.png)

#### Part 4 — Schedule an loan review meeting
1. Start a **New test session**.
2. Enter a prompt such as `Can you find 3 meeting times for a 30 minute meeting with [coworker name] for an loan review meeting?` (replace `[coworker name]` with the name of your test coworker account).
3. Review the returned time slots. The agent uses the *findMeetingTimes* MCP tool to check both calendars for availability.
4. Reply with a selection such as `Please schedule the one at 10:30 AM.`
5. Confirm the agent calls the *createEvent* MCP tool and schedules the meeting.
6. Open Outlook or Teams calendar to verify the meeting invitation was sent and received by the coworker.

#### Part 5 — Review governance and scope
1. Return to the **Tools** page.
2. Open each MCP server entry and review its description, connection, and the list of tools it exposes.
3. In your notes, record one action that the agent should be allowed to perform and one action that should remain out of scope.
4. Note that each MCP server entry covers multiple tools (unlike connectors, which require a separate action per capability). This is a key advantage of MCP.
5. Save your notes for the Day 2 wrap-up discussion.

> **Note:** MCP servers are governed through the **Copilot Control System in Microsoft 365 admin center**. Keep workshop examples scoped to narrow, Microsoft-governed servers (such as the Work IQ catalog) rather than open-internet MCP endpoints, and register them only through the supported in-product wizard.

> **Note:** MCP servers are governed through the **Copilot Control System in Microsoft 365 admin center**. Administrators can allow or block specific servers organization-wide under **Agents and Tools**, scope permissions using Microsoft Entra, and audit all tool calls through Microsoft Defender.

#### Validation
1. The **Model Context Protocol** filter tab in the **Add tool** dialog shows pre-built Work IQ MCP servers.
2. The **Work IQ** user profile MCP server is added and can return manager or profile information.
3. The **Work IQ Calendar** MCP server is added and can return meeting information.
4. The agent can suggest available meeting times and create an loan review meeting.
5. You documented one governance rule about what the MCP-enabled agent should and should not do.

#### Troubleshooting
1. If no MCP servers appear under the **Model Context Protocol** filter tab, your tenant may not have Work IQ MCP servers enabled or the workshop account may not have a Microsoft 365 Copilot license. Ask the facilitator to demo this lab or check whether the required license and access have been configured.
2. If connection setup fails, sign out of the connection prompt and sign back in with the same account used for the workshop.
3. If calendar tests fail, verify that your user has a mailbox and at least one current or future meeting.
4. If the consent card does not appear, the connection may already be authorized from a previous session. Proceed with testing.
5. If the agent does not call the MCP server, review the tool descriptions and test with a more direct request such as `Show my meetings for today.`

#### Facilitator Notes
1. Demonstrate the MCP filter tab and the add-and-configure flow once before the room starts so participants understand the difference between the **Create new** card (for custom MCP servers) and the **Model Context Protocol** filter tab (for pre-built Work IQ MCP servers).
2. If your tenant does not have Work IQ MCP servers available or participants lack a Microsoft 365 Copilot license, demo from a pre-configured environment and let participants observe the end state.
3. Emphasize that one MCP server entry exposes multiple tools — contrast this with classic connectors that require one action per capability.
4. Keep the conversation focused on governed tool use, not unlimited automation.
