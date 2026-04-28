# Copilot Studio Workshop

## Day 2 — Enterprise Track

### Lab 14 — Agent Instructions

⏱ Estimated time: 25 min (+10 min optional Component Collections extension)

#### Overview
In this lab, you will turn the baseline Loan Processing Agent into a more reliable orchestrator by writing explicit instructions. You will compare three instruction styles, apply a balanced set to the **Loan Processing Agent**, and test how instruction wording changes scope, tone, and delegation behavior in the Woodgrove Bank lending scenario.

#### Prerequisites
1. [Maker] Complete **Lab 13 — Loan Processing Agent Setup** in the same environment.
2. [Maker] Open the **Loan Processing Agent** in Copilot Studio.
3. [Developer] Keep the **Test your agent** pane available so you can validate each instruction change immediately.

#### Step-by-Step Instructions
#### Part 1 — Review the current instruction surface
1. Open **Copilot Studio**, select **Agents**, and open **Loan Processing Agent**.
2. In the **Overview** tab, locate the **Instructions** card and select **Edit**.
3. Review the existing instruction area and note that the model needs guidance for role, scope, escalation, and output style.
4. Keep the instruction editor open for the next section.

![Loan Processing Agent instructions editor](./assets/lab-14-instructions-editor.png)

#### Part 2 — Compare three sample instruction sets
1. Read the three sample instruction styles below before you paste anything into the agent.
2. Decide which style best fits an instructor-led workshop where participants need consistent, explainable results.
3. Use the **Balanced** set in this lab, and keep the other two as comparison points for testing.

**Restrictive instruction set**
```text
You are the Woodgrove Bank Loan Processing Agent.
Only answer questions about active loan applications in the system.
Only use configured tools, topics, and data sources.
Refuse all requests that are not directly related to active loan applications in the system.
Keep every answer under 120 words.
If required data is missing, ask one clarifying question and stop.
```

**Balanced instruction set**
```text
You are the Woodgrove Bank Loan Processing Agent. You help loan officers manage loan applications, review applicant information, and coordinate the lending workflow.
Answer questions about loan applications, applicant profiles, loan types, and assessment criteria stored in Woodgrove Lending Hub.
Professional, precise, and helpful. Use clear financial terminology appropriate for banking professionals.
Use configured tools, child agents, connected agents, and Dataverse data when they are available and relevant.
Keep responses concise, professional, and action-oriented.
If a request is ambiguous, ask a targeted follow-up question.
Do not provide personal financial advice, make lending decisions, or discuss competitor products.
```

**Open instruction set**
```text
You are a helpful lending assistant.
Be conversational, creative, and proactive.
Use available context to help the user move forward.
Offer suggestions whenever you see an opportunity.
Allow general banking discussion beyond the immediate loan processing workflow.
```

> Tip: The open set feels friendly, but it usually produces less predictable workshop results because it leaves more room for model interpretation.

#### Part 3 — Apply the balanced instructions
1. In the **Instructions** editor for **Loan Processing Agent**, replace any existing text with the **Balanced instruction set**.
2. Add one final line that says `Always identify the next recommended lending action when it helps the loan officer move forward.`
3. Select **Save**.
4. Wait for the save confirmation before starting a new test session.

#### Part 4 — Test instruction behavior
1. Select **Test** and then select **New test session**.
2. Enter an in-scope request in plain language, such as a request to help with loan application review, applicant eligibility assessment, or loan type comparison for the Loan Processing Agent scenario.
3. Confirm that the response stays in the lending domain and ends with a useful next action.
4. Enter an ambiguous lending request and confirm that the agent asks a focused follow-up question instead of guessing.
5. Enter an out-of-scope request unrelated to lending and confirm that the agent politely redirects back to lending tasks.
6. Return to the **Instructions** card and briefly swap in the **Restrictive** set.
7. Repeat the same test inputs and compare the shorter, tighter answers.
8. Return to the **Instructions** card, restore the **Balanced** set, and save again so later labs inherit the correct behavior.

![Testing instruction behavior in the test pane](./assets/lab-14-test-pane.png)

#### Optional 10-min extension — Reference the Woodgrove Product & Fee Disclosures Component Collection

> **Cross-day callback.** In Lab 06 we previewed Component Collections — a reusable bundle of topics, knowledge, and actions owned by a primary agent that other agents can reference. The facilitator has pre-created the **Woodgrove Product & Fee Disclosures** collection in the demo environment. In this extension you will reference it from the **Loan Processing Agent** so its lending answers stay aligned with the same disclosure content the **Woodgrove Customer Service Agent** uses.

1. In the **Loan Processing Agent**, open the **Components** view (top tab row, alongside Knowledge and Tools).
2. Select **+ Add component collection** and choose the collection named per `ComponentCollections.ProductDisclosuresCollectionName` in `workshop-config.example.json` (default `Woodgrove-Product-Disclosures`).
3. Confirm the disclosure topics and knowledge entries appear as referenced (not copied) under the agent's component list.
4. Save the agent.
5. Select **Test** > **New test session** and ask: `What is the maximum term and current advertised rate range for our standard mortgage product?`
6. Confirm the response cites disclosure content from the referenced collection rather than inventing rates or terms.
7. Ask a second question: `Which fee schedule applies to a personal loan early repayment?` and confirm the answer again pulls from the disclosures collection.

> **Why a Component Collection here?** It avoids drift. Mortgage rates, fee schedules, and adverse action wording change frequently and are reviewed by Compliance. Curating them once in a single referenced collection means the **Customer Service Agent** and the **Loan Processing Agent** read identical, current text — a governance and consistency win that single-agent SharePoint grounding cannot provide.

> **FSI guardrail.** The disclosure content lifecycle (drafting, legal sign-off, version control, retirement) is owned by the bank's **Compliance / Disclosures team**. The agent maker only references the approved collection; they do not edit disclosure content. **KYC stays out of this collection** — KYC must remain a system-of-record connector lookup, never static bundled knowledge.

#### Validation
1. The **Loan Processing Agent** instructions show the balanced text and the final "next recommended lending action" line.
2. In-scope questions receive concise lending-focused answers.
3. Ambiguous requests trigger a clarifying question.
4. Out-of-scope requests are refused or redirected without breaking the lending persona.
5. After testing, the balanced instructions remain saved as the final configuration.

#### Troubleshooting
1. If the agent ignores the new instructions, start a **New test session** instead of reusing an old one.
2. If responses feel too generic, add concrete nouns such as **loan application**, **applicant profile**, **assessment criteria**, and **loan type** directly into the instruction text.
3. If multiple behaviors compete, simplify the wording and order the rules from most important to least important.
4. If the agent starts answering unrelated questions, tighten the scope line rather than adding many separate refusal rules.

#### Facilitator Notes
1. Use this lab to explain that instructions are not decorative text; they are operational guidance for orchestration and tool choice.
2. Ask participants to compare the restrictive and balanced outputs verbally so they can hear how small wording changes alter the experience.
3. Keep participants on the balanced set before they continue to Lab 15.
4. **Component Collections extension.** Pre-create the **Woodgrove Product & Fee Disclosures** collection in the demo environment before this lab so the optional extension is a pure reference exercise — participants should not build the collection from scratch. Use the collection name and source URLs configured in `ComponentCollections.ProductDisclosuresCollectionName` and `ComponentCollections.DisclosureSourceUrls` in `workshop-config.example.json`. Skip this extension if the room is behind schedule; it is explicitly optional. Reinforce that disclosure content is Compliance-owned in production, and that **KYC is intentionally excluded** from the collection because KYC must stay a system-of-record connector lookup.
