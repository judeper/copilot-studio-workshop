# Copilot Studio Workshop
## Day 1 — Recruit Track
### Lab 02 — Copilot Studio Fundamentals
⏱ Estimated time: 30 min

#### Overview
In this lab, you will tour the Copilot Studio interface and locate the four building blocks used throughout the workshop: instructions, knowledge, actions, and topics. You will also find the analytics area and the **Activity** page that you will later use to troubleshoot, pin important sessions, and improve your agent.

![Copilot Studio agent canvas with tabs for overview topics tools and analytics](./assets/lab-02-copilot-studio-navigation.png)

#### Prerequisites
1. Complete Lab 00 and confirm you can open Copilot Studio in the correct environment.
2. Complete Lab 01 so the terms `knowledge`, `actions`, `topics`, and `instructions` are familiar.
3. If you do not yet have an agent, be ready to create a temporary placeholder agent in this lab.

#### Step-by-Step Instructions
#### Step 1 — Open or create an agent for navigation practice
1. Go to `https://copilotstudio.microsoft.com` and verify the environment selector in the upper-right corner shows your workshop environment.
2. If you already have an agent, select **Agents** in the left navigation and open it.
3. If you do not have an agent, select **Create**, choose **Custom agent**, enter `Navigation Tour Agent` in the **Name** field, and select **Create**.
4. Wait until the agent overview page loads before continuing.

#### Step 2 — Find Instructions from the overview page
1. On the agent overview page, stay on the **Overview** tab.
2. In the **Details** section, locate the description and instructions text areas.
3. Select **Edit** if the section is read-only and confirm where you would update the agent purpose, response style, and boundaries.
4. Select **Cancel** or leave the values unchanged after you confirm the location.

#### Step 3 — Find Knowledge without relying on a screenshot
1. Stay on the **Overview** tab and scroll until you see the **Knowledge** section.
2. Confirm the **+ Add knowledge** button is visible.
3. Select **+ Add knowledge** and review the options such as **Public websites**, **SharePoint**, and **Documents**.
4. Close the panel without adding anything if you are using a temporary agent.
5. Say out loud or note down that knowledge sources are configured from the **Knowledge** section on the **Overview** tab.

#### Step 4 — Find Actions and tools without relying on a screenshot
1. In the top tab row, look for **Tools**.
2. If the **Tools** tab is not visible, select the overflow button such as **+ more** or the numeric tab expander and choose **Tools**.
3. On the **Tools** page, locate the **+ Add a tool** button.
4. Select **+ Add a tool** and confirm you can see choices such as **Connector**, **Prompt**, or **Flow** depending on your tenant capabilities.
5. Close the tool picker after you confirm the location.

#### Step 5 — Find Topics without relying on a screenshot
1. In the top tab row, select **Topics**.
2. If **Topics** is hidden, open the overflow control and choose **Topics**.
3. On the **Topics** page, locate the filters for **Custom** and **System** topics.
4. Select **+ Add a topic** and confirm where **From blank** or **From description** appears.
5. Close the create dialog so you can continue the tour.

#### Step 6 — Find Analytics and the Activity page
1. In the top tab row, select **Analytics**.
2. If **Analytics** is hidden, use the overflow control and choose **Analytics**.
3. Review the page sections that show conversation volume, resolution signals, and activity details.
4. Open the **Activity** page or the closest equivalent diagnostics page available in your tenant.
5. Confirm where you would inspect a single session, pin it for follow-up, and submit diagnostic feedback if needed.
6. If your tenant has not collected data yet, note that the page may show empty charts; the location is still correct.
7. Return to the **Overview** tab when you finish.

> **Tip:** Many Copilot Studio pages hide secondary tabs behind an overflow menu when the browser zoom level is high. If you lose **Topics**, **Tools**, or **Analytics**, reduce the browser zoom to 90% or 80% and check again.

#### Validation
1. Starting from the **Overview** tab, point to the exact location of **Knowledge** and say how to add a SharePoint source.
2. Starting from the top tab row, point to the exact location of **Topics** and say how to create a blank topic.
3. Starting from the top tab row, point to the exact location of **Tools** and say how to add a connector action.
4. Starting from the top tab row, point to the exact location of **Analytics** and say what type of data you expect to review there.
5. Starting from the diagnostics area, point to where you would inspect one conversation in the **Activity** tab.

#### Troubleshooting
> **Tip:** If the tab row changes after you resize the browser, use the tab overflow control rather than refreshing the page.

> **Tip:** If you cannot see **Analytics**, confirm the agent has finished provisioning and that you are not still on the home page.

> **Warning:** If Copilot Studio creates your temporary agent in the wrong environment, delete it and switch environments before recreating it.

#### Facilitator Notes
1. Demonstrate the interface once slowly and then ask participants to repeat the navigation themselves.
2. Call out that the UI can move tabs into overflow; this prevents unnecessary “my screen looks different” interruptions later.
3. Point out the **Activity** tab explicitly so later troubleshooting exercises feel familiar instead of hidden.
4. If the group already has agents, use the same agent throughout the tour to reduce setup noise.

