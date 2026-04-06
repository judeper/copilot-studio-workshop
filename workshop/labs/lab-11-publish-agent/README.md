# Copilot Studio Workshop
## Day 1 — Foundation Track
### Lab 11 — Publish Agent
⏱ Estimated time: 30 min

#### Overview
In this lab, you will publish the Woodgrove Customer Service Agent, add the Teams and Microsoft 365 Copilot channel, and validate that the latest version is available where users actually work. You will also review the broader channel landscape, including WhatsApp, so the workshop can end with a production-minded release discussion.

![Publish dialog and Teams channel configuration for the agent](./assets/lab-11-publish.png)

#### Prerequisites
1. Complete Labs 06 through 10 so the agent has meaningful capabilities to publish.
2. Confirm your environment supports publishing. Trial environments may require extra admin steps or may block the final publish action.
3. Confirm you can sign in to Microsoft Teams with the same workshop account.

#### Step-by-Step Instructions
#### Step 1 — Publish the latest agent version
1. Open **Woodgrove Customer Service Agent** in Copilot Studio.
2. Select **Publish** in the upper-right corner.
3. Review the confirmation dialog and select **Publish** again.
4. Wait for the completion notification at the top of the page.

#### Step 2 — Add the Teams and Microsoft 365 channel
1. Select the **Channels** tab in the top navigation.
2. Under **Microsoft channels**, select **Teams and Microsoft 365 Copilot**.
3. Select **Add channel**.
4. Wait for the green success notification.
5. Select **See agent in Teams** to open the installation experience in a new browser tab.

#### Step 3 — Add the agent to Teams for yourself
1. In the Teams installation page, select **Add**.
2. Wait for the app installation to finish.
3. Select **Open** to launch the agent in Microsoft Teams.
4. In Teams, pin the app if the option appears so you can find it easily during testing.

#### Step 4 — Review availability options for broader rollout
1. Return to the Copilot Studio browser tab.
2. In the **Teams and Microsoft 365** channel pane, select **Availability options**.
3. Review **Copy link**, **Show to my teammates and shared users**, and **Show to everyone in my org**.
4. If your tenant process allows it, select **Show to everyone in my org** and then select **Submit for admin approval**.
5. Note that a Teams administrator must publish the submitted app before it appears broadly in the app store.
6. Return to the main **Channels** page and confirm that **WhatsApp** appears in the **Other channels** section for later rollout planning, even though this workshop does not configure it hands-on.

> **Tip:** If the **Other channels** section shows channels as unavailable, check the banner at the top of the Channels page. When the agent uses **Microsoft authentication**, only Teams, Microsoft 365, and SharePoint channels are active. To enable other channels, select **change your authentication settings** in the banner.

> **Warning:** If you are using a trial environment that blocks publishing, complete the page review and validation steps with a facilitator demo or a paid environment. Do not spend workshop time repeatedly retrying a blocked publish action.

![Agent opened inside Microsoft Teams after successful install](./assets/lab-11-teams-open.png)

#### Validation
1. Confirm the Copilot Studio **Publish** notification indicates the latest version is live.
2. Confirm the **Channels** tab shows **Teams and Microsoft 365 Copilot** under **Microsoft channels**.
3. Confirm you can install the app in Microsoft Teams and open it successfully.
4. In Teams, send a validation prompt such as `I need help with a VPN issue` and confirm the agent responds.
5. Confirm the Teams publishing path is clear by identifying whether your app is self-installed, shared with teammates, or submitted for admin approval.
6. Confirm you can identify WhatsApp as an additional supported publish channel for future rollout planning.

#### Troubleshooting
> **Tip:** If the **Channels** tab is hidden, use the top tab overflow control to locate it.

> **Tip:** If Teams opens but the app does not install, sign out and back in to Teams with the same account you used in Copilot Studio.

> **Tip:** If your org-wide submission stays pending, ask the Teams administrator to review the app in **Teams Admin Center** > **Apps**.

#### Facilitator Notes
1. Participants often think publishing and channel configuration are the same task. Demonstrate the difference explicitly.
2. Keep the validation focused on Teams because the user requirement for this workshop specifically calls for Teams publishing validation.
3. Mention WhatsApp briefly as a GA channel so participants see that channel strategy is broader than Teams alone.
4. If the environment cannot publish, provide screenshots or a live tenant demo so participants still see the end state.

