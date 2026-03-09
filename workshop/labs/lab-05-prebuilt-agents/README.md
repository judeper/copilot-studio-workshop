# Copilot Studio Workshop
## Day 1 — Recruit Track
### Lab 05 — Prebuilt Agents
⏱ Estimated time: 30 min

#### Overview
In this lab, you will deploy a Microsoft-provided agent template and adapt it to the workshop scenario. Prebuilt agents help teams accelerate delivery, understand product patterns, and prototype faster than starting from a blank canvas.

![Agent template gallery with Safe Travels highlighted](./assets/lab-05-template-gallery.png)

#### Prerequisites
1. Complete Lab 00 and Lab 02.
2. Confirm you are signed in to Copilot Studio in the correct environment.
3. If you completed Lab 04, confirm `Contoso Helpdesk Agent` is still the preferred solution.

#### Step-by-Step Instructions
#### Step 1 — Open the template gallery
1. Go to `https://copilotstudio.microsoft.com`.
2. On the home page, select **Create**.
3. Scroll to the **Start with an agent template** section.
4. Find the **Safe Travels** template and select it.

#### Step 2 — Review the template before you create it
1. On the template setup page, review the prefilled **Description**, **Instructions**, and **Knowledge** sections.
2. Note which pieces are already configured so you can compare them with the custom agent you build later.
3. Select **Create**.

#### Step 3 — Customize the prebuilt agent
1. After the agent provisions, go to the **Overview** tab.
2. In the **Knowledge** section, select **+ Add knowledge**.
3. Choose **Public websites**.
4. In the website field, enter `https://european-union.europa.eu/` and select **Add**.
5. Select **Add to agent**.
6. Review the updated knowledge list and confirm the public site now appears alongside the template content.

#### Step 4 — Test the prebuilt experience
1. Open the **Test** pane.
2. Enter `Do I need a visa to travel from the US to Amsterdam?` and press **Enter**.
3. Enter `How long does it take to get a US passport?` and review the response.
4. If the tenant allows activity details, open the **Activity map** to inspect how the answer was grounded.

#### Step 5 — Publish the template agent
1. Select **Publish** in the top-right corner.
2. Review the publish dialog and select **Publish** again.
3. If the environment supports channels, note that you can later add **Teams and Microsoft 365** from the **Channels** area.

> **Tip:** Template agents are useful learning assets even if you never deploy them to production. Use them to study naming patterns, starter prompts, and tool choices.

#### Validation
1. Confirm the **Safe Travels** agent opens successfully.
2. Confirm the **Knowledge** section includes `https://european-union.europa.eu/`.
3. Confirm the test pane returns at least one grounded answer about travel.
4. Confirm you can reach the **Publish** action without navigation help.

#### Troubleshooting
> **Tip:** If the template gallery does not show **Safe Travels**, refresh the home page and confirm you are in a Copilot Studio-enabled environment.

> **Warning:** If test responses are vague, confirm the website knowledge source finished indexing before retesting.

#### Facilitator Notes
1. Use this lab to show the tradeoff between speed and control: templates are fast, but custom agents offer tighter fit.
2. Encourage participants to study what Microsoft preconfigures, especially starter prompts and instructions.

