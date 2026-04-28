# Copilot Studio Workshop
## Day 1 — Foundation Track
### Lab 11 — Publish Agent
⏱ Estimated time: 45 min

#### Overview
In this lab, you will prepare the Woodgrove Customer Service Agent for release, then publish it to the channels where users actually work. Specifically, you will:
1. Set **knowledge prioritization** so the agent prefers authoritative Woodgrove sources before falling back to public web content.
2. Configure **suggested prompts** (conversation starters) that surface common banking tasks the moment a user opens the agent.
3. **Publish** the agent and add both the **Microsoft Teams** channel and the **Microsoft 365 Copilot** channel so the agent is discoverable inside the M365 Copilot experience.
4. Review the broader channel landscape, including WhatsApp, so the workshop can end with a production-minded release discussion.

![Publish dialog and Teams channel configuration for the agent](./assets/lab-11-publish.png)

#### Prerequisites
1. Complete Labs 06 through 10 so the agent has meaningful capabilities to publish. Lab 06 in particular adds the SharePoint loan-policy knowledge source you will prioritize in Step 1.
2. Confirm your environment supports publishing. Trial environments may require extra admin steps or may block the final publish action.
3. Confirm you can sign in to Microsoft Teams with the same workshop account.
4. To chat with the agent inside the **Microsoft 365 Copilot** channel, end users need a **Microsoft 365 Copilot** license. A Copilot Studio maker license alone is enough to publish the channel, but is not enough to consume the agent inside M365 Copilot. Confirm at least your own account has a Microsoft 365 Copilot license before validating Step 6.

#### Step-by-Step Instructions
#### Step 1 — Prioritize knowledge sources
Woodgrove has three potential answer sources: the internal Loan Policy SharePoint site (Lab 06), the public Woodgrove Bank product disclosure website, and general web search. You want the agent to prefer the authoritative internal source first and only fall back to public content when needed.

1. Open **Woodgrove Customer Service Agent** in Copilot Studio.
2. Select the **Knowledge** tab in the top navigation.
3. On the **Overview** page, review the list of knowledge sources attached to the agent. You should see at least the Loan Policy SharePoint site from Lab 06.
4. If the public Woodgrove product disclosures and general web search are not already attached, add them now:
   - Select **+ Add knowledge** > **Public website** and enter `https://www.woodgrovebank.com` as a representative public disclosure source. (If your tenant blocks public sites in this lab, skip this addition and prioritize only the sources you have.)
   - Confirm **General knowledge** (web search) is enabled in the agent's generative AI settings if your environment allows it.
5. Set the priority order so the agent consults sources in this sequence. Use the priority control on the **Overview** page (drag the row handle to reorder, or set the numeric priority where the GA UI offers one):
   - **Priority 1 — Loan Policy SharePoint site.** Authoritative internal policy. The agent should ground here first.
   - **Priority 2 — `woodgrovebank.com`.** Public product disclosures and rate sheets. Used when internal policy does not cover the question.
   - **Priority 3 — General web search.** Last-resort fallback for general financial education questions.
6. Save the changes. The Overview page should now show the sources in the order above.

> **Tip:** Knowledge prioritization is a soft preference, not a hard filter. The orchestrator still chooses the best source per turn, but it weights higher-priority sources first. Keep the most authoritative content at the top.

#### Step 2 — Configure suggested prompts
Suggested prompts (also called conversation starters) appear as one-click chips when a user first opens the agent in Microsoft Teams or Microsoft 365 Copilot. Good prompts shorten time to first value.

1. In Copilot Studio, select the **Overview** tab for the agent.
2. Scroll to the **Suggested prompts** (or **Conversation starters**) section and select **Add** or **Edit**.
3. Add the following four banking-specific prompts. For each one, enter a short **Title** that displays on the chip and the full **Prompt** that gets sent when the user selects it.
   - **Title:** Application status — **Prompt:** `What's my loan application status?`
   - **Title:** Mortgage documents — **Prompt:** `What documents do I need for a mortgage?`
   - **Title:** 30-year fixed rates — **Prompt:** `Show me current rates for a 30-year fixed.`
   - **Title:** Dispute a transaction — **Prompt:** `I want to dispute a transaction.`
4. Save the suggested prompts.

> **Tip:** Keep suggested prompts to 3 or 4 high-intent tasks. Long lists dilute discoverability, and channels such as Microsoft 365 Copilot may only render the first few.

#### Step 3 — Publish the latest agent version
1. Select **Publish** in the upper-right corner of Copilot Studio.
2. Review the confirmation dialog and select **Publish** again.
3. Wait for the completion notification at the top of the page. This new published version is what each channel will surface.

#### Step 4 — Add the Microsoft Teams channel
1. Select the **Channels** tab in the top navigation.
2. Under **Microsoft channels**, select **Teams and Microsoft 365 Copilot**.
3. Select **Add channel**.
4. Wait for the green success notification.
5. Select **See agent in Teams** to open the installation experience in a new browser tab.
6. In the Teams installation page, select **Add**, wait for the install to finish, and select **Open** to launch the agent in Microsoft Teams. Pin the app if the option appears.

#### Step 5 — Publish to the Microsoft 365 Copilot channel
The same **Teams and Microsoft 365 Copilot** channel pane controls availability inside the Microsoft 365 Copilot app. Enabling this surface lets users invoke the Woodgrove Customer Service Agent from inside their existing M365 Copilot experience instead of switching apps.

1. Return to the Copilot Studio browser tab and reopen the **Teams and Microsoft 365 Copilot** channel pane.
2. In the **Availability options** section, confirm the **Microsoft 365 Copilot** surface is selected (it is included by default with this channel) and that the agent will appear in the M365 Copilot agent picker.
3. Select **Show to my teammates and shared users** or **Show to everyone in my org**, depending on your tenant policy. For org-wide visibility, select **Submit for admin approval** — a Teams administrator must approve the app before it appears for all users.
4. Open **Microsoft 365 Copilot** (`https://m365.cloud.microsoft/copilot`) in a new browser tab using the same workshop account.
5. In the M365 Copilot left navigation, open the **Agents** picker (or the **+ Get agents** experience), search for **Woodgrove Customer Service Agent**, and add it to your sidebar.
6. Open the agent inside Microsoft 365 Copilot and confirm the four suggested prompts you configured in Step 2 appear as one-click chips.

> **Tip:** If your account does not yet have a Microsoft 365 Copilot license, you can still validate the Teams channel in Step 4. Use the facilitator demo tenant to confirm the M365 Copilot channel end state.

#### Step 6 — Review availability options for broader rollout
1. Return to the Copilot Studio **Channels** page.
2. Confirm that **WhatsApp** appears in the **Other channels** section for later rollout planning, even though this workshop does not configure it hands-on.
3. Note that a Teams administrator must publish any submitted app before it appears broadly in the Teams or M365 Copilot app stores.

> **Tip:** If the **Other channels** section shows channels as unavailable, check the banner at the top of the Channels page. When the agent uses **Microsoft authentication**, only Teams, Microsoft 365, and SharePoint channels are active. To enable other channels, select **change your authentication settings** in the banner.

> **Warning:** If you are using a trial environment that blocks publishing, complete the page review and validation steps with a facilitator demo or a paid environment. Do not spend workshop time repeatedly retrying a blocked publish action.

![Agent opened inside Microsoft Teams after successful install](./assets/lab-11-teams-open.png)

#### Validation
1. Confirm the **Knowledge** > **Overview** page shows the Woodgrove sources in the order **Loan Policy SharePoint** (1), **woodgrovebank.com** (2), **General web search** (3).
2. Ask the agent a policy question such as `What is Woodgrove's minimum credit score for a mortgage?` in **Test your agent** and confirm the response cites the Loan Policy SharePoint source first, not the public site.
3. Confirm the four suggested prompts are visible on the agent **Overview** page and each one is configured with both a title and a prompt body.
4. Confirm the Copilot Studio **Publish** notification indicates the latest version is live.
5. Confirm the **Channels** tab shows **Teams and Microsoft 365 Copilot** under **Microsoft channels** and that you can install the app in Microsoft Teams and open it successfully.
6. In Teams, send a validation prompt such as `I need help with a VPN issue` and confirm the agent responds.
7. In **Microsoft 365 Copilot**, confirm the Woodgrove Customer Service Agent appears in the agent picker, the four suggested prompts render on first open, and selecting one returns a grounded response.
8. Confirm the Teams publishing path is clear by identifying whether your app is self-installed, shared with teammates, or submitted for admin approval.
9. Confirm you can identify WhatsApp as an additional supported publish channel for future rollout planning.

#### Troubleshooting
> **Tip:** If the **Channels** tab is hidden, use the top tab overflow control to locate it.

> **Tip:** If Teams opens but the app does not install, sign out and back in to Teams with the same account you used in Copilot Studio.

> **Tip:** If your org-wide submission stays pending, ask the Teams administrator to review the app in **Teams Admin Center** > **Apps**.

> **Tip:** If suggested prompts do not appear in Microsoft 365 Copilot after publish, wait a few minutes for the channel to refresh, then close and reopen the agent in M365 Copilot. New prompts are picked up on the next session start, not mid-conversation.

> **Tip:** If a policy answer cites the public site instead of the SharePoint source, recheck the priority order on the **Knowledge** > **Overview** page and start a **New test session** so cached grounding is cleared.

#### Facilitator Notes
1. Participants often think publishing and channel configuration are the same task. Demonstrate the difference explicitly.
2. Knowledge prioritization is a soft preference. Set expectations that the orchestrator still selects per turn — prioritization shifts behavior, it does not enforce it. Use the SharePoint vs. public site contrast as the visible proof point.
3. Suggested prompts are the cheapest adoption lever in the workshop. Encourage participants to draft prompts that map to real top-of-funnel banking tasks for their own scenarios.
4. The Microsoft 365 Copilot channel requires end users to hold a Microsoft 365 Copilot license. Call this out before Step 5 so participants without the license know to validate via the facilitator demo tenant.
5. Keep the validation focused on Teams and M365 Copilot because the workshop release story spans both surfaces.
6. Mention WhatsApp briefly as a GA channel so participants see that channel strategy is broader than Microsoft surfaces alone.
7. If the environment cannot publish, provide screenshots or a live tenant demo so participants still see the end state.

