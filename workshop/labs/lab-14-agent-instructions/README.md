# Copilot Studio Workshop

## Day 2 — Enterprise Track

### Lab 14 — Agent Instructions

⏱ Estimated time: 25 min

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
