# Copilot Studio Workshop
## Day 1 — Recruit Track
### Lab 12 — Licensing
⏱ Estimated time: 20 min

#### Overview
This lab is presentation-first and closes the day with the commercial model behind Copilot Studio. You will review Copilot Credits, understand when Microsoft 365 Copilot user licensing is enough, identify when Copilot Studio capacity is still consumed, and answer common customer questions about trials, production rollout, and cost planning.

![Licensing decision slide with credits packs pay as you go and Microsoft 365 Copilot](./assets/lab-12-licensing-overview.png)

#### Prerequisites
1. Complete the earlier Day 1 labs so you have concrete examples of knowledge, actions, topics, flows, and publishing.
2. Open a note-taking app for the scenario answers in this lab.
3. [IT Pro] Be ready to capture follow-up questions about tenant capacity, billing ownership, and governance.

#### Step-by-Step Instructions
#### Step 1 — Record the core licensing terms
1. In your notes, create four headings: `Copilot Credits`, `Capacity packs`, `Pay-as-you-go`, and `User licenses`.
2. Under `Copilot Credits`, write `Usage currency for work performed by Copilot Studio agents.`
3. Under `Capacity packs`, write `Prepaid monthly credit capacity pooled at the tenant level.`
4. Under `Pay-as-you-go`, write `Azure-billed usage for actual credits consumed.`
5. Under `User licenses`, write `Makers need Copilot Studio user access, and end users may still trigger Copilot Studio credits when agents perform advanced work.`

#### Step 2 — Map the workshop scenarios to licensing behavior
1. Under a new heading named `Scenario mapping`, list `Basic internal Q&A in Microsoft 365 Copilot` and mark it `Often covered by user license for basic interaction`.
2. List `Device request with SharePoint writeback and manager email` and mark it `Consumes Copilot Studio credits`.
3. List `Autonomous ticket acknowledgment trigger` and mark it `Consumes Copilot Studio credits`.
4. List `Maker building and editing agents` and mark it `Requires Copilot Studio maker access`.

#### Step 3 — Review the planning checklist
1. Open a browser tab and go to `https://aka.ms/copilotstudioestimator`.
2. Review the estimator landing page and note where you would model projected workload.
3. In your notes, list three planning actions: `Estimate usage`, `Disable unused tools`, and `Monitor capacity in admin center`.
4. Add a fourth action: `Mix prepaid capacity with pay-as-you-go for burst protection when appropriate`.

#### Step 4 — Review Savings analytics
1. If your environment already has analytics data, open the agent **Analytics** tab and locate the **Savings** section in the upper right.
2. Select **Calculate savings** to see how the agent tracks time and money saved, or review the section description if no data is available yet.
3. If the Savings section is not populated in your environment, use the facilitator demo or screenshot for this section.
4. In your notes, add three metrics leadership would care about: `Time saved`, `Cost avoided`, and `Adoption by business process`.
5. Add one sentence that says `Savings analytics matter because they connect agent behavior to measurable business value, not only technical usage.`

#### Step 5 — Work through the FAQ prompts
1. Write the question `Do Microsoft 365 Copilot user licenses remove the need for Copilot Studio credits?` and answer `No, advanced actions, triggers, connectors, and external publishing can still consume Copilot Studio credits.`
2. Write the question `What happens when a trial expires?` and answer `Authoring and testing access may end or be reduced, and published experiences should be moved to a paid capacity model before production use.`
3. Write the question `What is the safest production planning habit?` and answer `Estimate first, monitor after launch, and review capacity regularly.`
4. Write the question `Who needs a maker license or maker access?` and answer `Anyone who creates or manages agents in Copilot Studio.`

> **Note:** Trial environments are ideal for workshops and proof of concept work, but they are not a durable production strategy. Plan the move to paid capacity before the trial clock becomes a delivery risk.

#### Step 6 — Summarize your recommendation for Contoso
1. In your notes, write a two-sentence recommendation for the Contoso IT scenario.
2. Include one sentence on why the device request and event trigger workflows need Copilot Studio capacity planning.
3. Include one sentence on why monitoring after publish, including ROI analytics, is part of the implementation and not an afterthought.

#### Validation
1. Explain the difference between pay-as-you-go and capacity packs in one sentence each.
2. Identify which Day 1 lab first introduced an experience that clearly consumes Copilot Studio credits beyond a basic chat answer.
3. Explain what happens when the trial expires and what the customer should do before that date.
4. Confirm you can answer the FAQ question about Microsoft 365 Copilot user licenses versus Copilot Studio credits.
5. Explain why Savings analytics is valuable for leadership conversations about adoption and investment.

#### Troubleshooting
> **Tip:** If participants think `chat equals free`, bring them back to the Day 1 examples where the agent created SharePoint items, ran flows, and sent email.

> **Tip:** If the group confuses maker access with end-user access, separate the conversation into two lists: `who builds` and `who uses`.

> **Warning:** Avoid promising exact pricing outcomes during the workshop unless you are using current customer-approved numbers and the official estimator.

#### Facilitator Notes
1. Keep this lab anchored to the workshop scenario, not abstract licensing theory.
2. Use the FAQ answers as discussion prompts and let [IT Pro] participants add tenant governance considerations.
3. Spend five focused minutes on Savings analytics because this is often the bridge from technical success to leadership buy-in.
4. End by reminding participants that technical success and commercial readiness are both required for a credible customer deployment.

