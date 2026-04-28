# Copilot Studio Workshop

## Day 2 — Enterprise Track

### Lab 24 — Agent Evaluation

⏱ Estimated time: 55 min

> **Model guidance:** See [Model Baseline](../../facilitator-guide/model-baseline.md) for current preferred and fallback models.

#### Overview
In this lab, you will use Copilot Studio **Evaluation** (generally available since April 2026) to measure the quality of the **Loan Processing Agent** with a repeatable test set instead of relying on manual validation alone. You will create or import test cases, attach **multiple graders per case**, run an evaluation including a **multi-turn** scenario, review graders and detailed results, inspect the **activity map** diagnostic path for one failing case, and improve the agent instructions based on evidence from the run. The workflow connects directly to the operational quality pattern used in transcript-analysis architectures: evaluate behavior, diagnose why it happened, and feed improvements back into the live agent.

> **What's new at April 2026 GA**
> - **Multi-grader** — attach more than one grader to a single test case so you can score quality, tool use, and compliance keywords in the same run.
> - **Multi-turn evaluation** — score a multi-message conversation (clarifying question → follow-up answer) instead of single-shot prompts only.
> - **Auto-generated test inputs** — let Copilot Studio draft starter test cases from your agent instructions, then refine them for lending scenarios.
> - **CI/CD pattern (advanced, take-home)** — for teams ready to wire evaluation into a release pipeline, the **EvalGate** pattern (e.g., the **EvalGateADO** Azure DevOps integration) lets you fail a build when pass rate drops below a threshold. Out of scope for the workshop, but worth flagging for the IT Pro and Developer audiences.

> **Zones of Coverage (PowerCAT framing)**
> Think of every test set as covering three zones, and aim for at least one case in each:
> - **Capability** — does the agent do the lending task correctly when asked plainly? (eligibility, product match, document check)
> - **Regression** — does the behavior you fixed last week still hold? (re-add a previously failing case to lock in the fix)
> - **Safety** — does the agent refuse, redirect, or escalate when a request is unsafe, off-policy, or compliance-sensitive?

#### Prerequisites
1. Complete **Lab 13 — Loan Processing Agent Setup**, **Lab 14 — Agent Instructions**, **Lab 17 — Model Selection**, and **Lab 23 — User Feedback**.
2. Open **Loan Processing Agent** in Copilot Studio in the same environment used for the workshop.
3. On the **Overview** page, confirm the primary model is a generally available model and use **GPT-5 Chat** for this workshop when it is available in your region.
4. If your agent uses authenticated knowledge, Dataverse, or tools such as MCP-connected actions, make sure the evaluation account has working connections.

> Tip: Evaluations are most useful when they cover realistic loan officer prompts such as applicant eligibility screening, loan product matching, document verification, rate comparison, and compliance-safe refusal behavior. Map each case back to the **Capability**, **Regression**, or **Safety** zone above.

#### Step-by-Step Instructions
1. In **Copilot Studio**, open **Loan Processing Agent**, then select the **Evaluation** tab.
2. Select **Create a test set**.
3. Choose either the in-product option to create test cases manually, the import option if you already have a CSV file, or **Generate from instructions** to let Copilot Studio draft starter test cases from the agent instructions you wrote in Lab 14. If you generate, treat the output as a draft and edit each row so it is grounded in the lending scenario. The CSV path expects columns in exactly this order: **Question**, **Expected response**, **Testing method**. A sample template is available at `workshop/assets/evaluation-test-cases.csv`. Valid **Testing method** values map to the seven GA grader types: `General response quality`, `Semantic meaning`, `Keyword presence`, `Text similarity`, `Exact match`, `Capability usage`, or `Custom Graders`.
4. Enter the test set name `Loan Processing Agent - Day 2 QA Baseline`.
5. Add at least six test cases that cover all three Zones of Coverage:
   - **Capability** — applicant eligibility screening, loan product comparison, document verification.
   - **Regression** — one case that locks in behavior you have already validated in an earlier lab (for example, the eligibility summary you used during Lab 14).
   - **Safety** — one ambiguous loan officer request that should trigger a clarifying question, and one compliance-sensitive request that the agent must refuse or escalate.
6. For each test case, attach **two or more graders** using the new **multi-grader** capability so you score the response from multiple angles in a single run — for example, **General response quality** plus **Capability usage** for tool-driven cases, or **Semantic meaning** plus **Keyword presence** for compliance language. If your organization has custom evaluation policies, you can also configure a **Custom Graders** (Classification method) for regulatory checks.
7. Add at least one **multi-turn** test case (loan officer asks an ambiguous question → agent asks one clarifying question → loan officer answers → agent must respond correctly). Use the multi-turn editor to enter each turn in order; the graders will score the full conversation, not just the last message.
8. For the cases that use match-based graders, enter an expected response that rewards lending guidance aligned with regulatory requirements, correct use of configured tools or knowledge, and safe handling of loan officer requests.
9. Select **User profile** and choose the connected workshop account so the evaluation can access the same tools and knowledge that a real maker would use.
10. Select **Evaluate** and wait for the run to finish.

![Evaluation page and new evaluation flow](./assets/lab-24-evaluation-start.png)

11. In **Recent results**, open the run you just completed and review the overall **Pass rate** as well as the per-grader pass rate for any case that has multiple graders attached.
12. Filter the **Test cases** list to **Fail** and open one failed case.
13. In the detailed result pane, review the expected response, actual response, grader reasoning for **each** grader on the case, and the list of knowledge sources, topics, and tools used. Confirm that the multi-turn case shows every turn of the conversation.
14. Select **Show activity map** to inspect the sequence of inputs, decisions, and outputs for the failed case.
15. Record one concrete issue that explains the failure, such as vague instructions, missing scope boundaries, weak clarifying behavior, or an incorrect tool choice.

> Note: This diagnostic review is the same quality habit you use in production operations when you analyze conversation transcripts, identify failure patterns, and improve the agent with evidence instead of guesswork.

16. Return to the **Overview** page for **Loan Processing Agent** and select **Edit** in the **Instructions** card.
17. Improve the instructions to address the failure you found. If you need a workshop-safe remediation, add or refine guidance such as `Ask one targeted clarifying question when the loan officer request is ambiguous.` and `Base lending guidance only on applicant qualifications, configured tools, and approved knowledge sources.`
18. Save the instructions and wait for the confirmation message.
19. Return to **Evaluation**, open the same test set, and select **Evaluate test set again**.
20. When the second run completes, open it and use **Compare with** to compare the new run to the baseline.
21. Confirm whether the failing case improved, whether the pass rate changed per grader, and whether the new grader reasoning matches the behavior you intended.

![Detailed test result with activity map and comparison](./assets/lab-24-evaluation-results.png)

22. If your agent uses a custom prompt and a case is blocked by filtering rather than logic, review that prompt's **Content moderation level** for the specific prompt or tool instead of assuming the whole agent is wrong.

#### Validation
1. The **Evaluation** page shows at least one completed run for `Loan Processing Agent - Day 2 QA Baseline`.
2. The test set covers all three **Zones of Coverage** — at least one Capability case, one Regression case, and one Safety case.
3. At least one test case has **two or more graders** attached and shows a per-grader result in the detailed view.
4. At least one **multi-turn** test case is present and the detailed view shows every turn of the conversation.
5. You can open a failed test case and show evidence from the detailed result, including grader reasoning for each grader and the **activity map**.
6. The **Loan Processing Agent** instructions include a targeted improvement based on the failing case you analyzed.
7. A second evaluation run exists for the same test set, showing one improvement cycle rather than a single one-time check.
8. The comparison between runs shows either a higher pass rate, an improved individual case, or a clearly documented reason why the issue still needs more work.

#### Troubleshooting
1. If the **Evaluation** tab is unavailable, refresh the browser and reopen the agent before retrying.
2. If the run fails because tools or knowledge cannot authenticate, reopen **User profile** and repair the broken connection before rerunning the test set.
3. If import fails, verify the CSV column order is exactly **Question**, **Expected response**, and **Testing method**, then save the file as `.csv` and import it again.
4. If all cases pass too easily, tighten the expected responses or add **Capability usage**, **Semantic meaning**, **Text similarity**, or **Exact match** so the graders measure operational quality instead of surface-level politeness.
5. If a valid test case is blocked by safety filtering, review the prompt or tool settings that generated the blocked content and adjust the per-prompt moderation sensitivity only where justified.
6. If the agent keeps failing the same case after you edit instructions, simplify the instruction wording and make the expected behavior more explicit and lending-related.

#### Facilitator Notes
1. Emphasize that agent evaluation is an operational control, not just a workshop demo, because it reduces dependence on manual validation alone. Evaluation has been generally available since April 2026, so frame it as a release gate rather than a preview feature.
2. Reinforce the **Zones of Coverage** framing (Capability, Regression, Safety) when participants design their test set; a balanced set is more valuable than a longer single-zone set.
3. Use **multi-grader** to model real release criteria: a regulated lending response often has to be helpful, use the right tool, *and* contain mandatory disclosure language. One run, three signals.
4. Use the **multi-turn** case to highlight that ambiguous loan officer requests are the norm, not the exception, and that single-shot evaluation can hide real failure modes.
5. Connect the failing-case analysis to the transcript-analysis reference architecture: both use real interactions, structured review, and iterative improvement to raise quality over time.
6. For the IT Pro and Developer audiences, mention the **EvalGate** CI/CD pattern (and the **EvalGateADO** Azure DevOps integration) as a take-home for teams ready to wire evaluation into a build pipeline. Keep this as awareness only; do not run it in class.
7. Encourage participants to keep the same test set after the workshop so they can rerun it after future changes and detect regressions.
8. If participants ask about unsupported extras, steer them back to the workshop baseline of GA capabilities, with **GPT-5 Chat** as the preferred hands-on model.

