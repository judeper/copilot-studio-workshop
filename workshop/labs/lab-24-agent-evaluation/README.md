# Copilot Studio Workshop

## Day 2 — Enterprise Track

### Lab 24 — Agent Evaluation

⏱ Estimated time: 45 min

> **Model guidance:** See [Model Baseline](../../facilitator-guide/model-baseline.md) for current preferred and fallback models.

#### Overview
In this lab, you will use Copilot Studio evaluation capabilities to measure the quality of the **Loan Processing Agent** with a repeatable test set instead of relying on manual validation alone. You will create or import test cases, run an evaluation, review graders and detailed results, inspect the **activity map** diagnostic path for one failing case, and improve the agent instructions based on evidence from the run. The workflow connects directly to the operational quality pattern used in transcript-analysis architectures: evaluate behavior, diagnose why it happened, and feed improvements back into the live agent.

#### Prerequisites
1. Complete **Lab 13 — Loan Processing Agent Setup**, **Lab 14 — Agent Instructions**, **Lab 17 — Model Selection**, and **Lab 23 — User Feedback**.
2. Open **Loan Processing Agent** in Copilot Studio in the same environment used for the workshop.
3. On the **Overview** page, confirm the primary model is a generally available model and use **GPT-5 Chat** for this workshop when it is available in your region.
4. If your agent uses authenticated knowledge, Dataverse, or tools such as MCP-connected actions, make sure the evaluation account has working connections.

> Tip: Evaluations are most useful when they cover realistic loan officer prompts such as applicant eligibility screening, loan product matching, document verification, rate comparison, and compliance-safe refusal behavior.

#### Step-by-Step Instructions
1. In **Copilot Studio**, open **Loan Processing Agent**, then select the **Evaluation** tab.
2. Select **Create a test set**.
3. Choose either the in-product option to create test cases manually or the import option if you already have a CSV file. The CSV must have columns in exactly this order: **Question**, **Expected response**, **Testing method**. A sample template is available at `workshop/assets/evaluation-test-cases.csv`. Valid **Testing method** values map to the seven GA grader types: `General response quality`, `Semantic meaning`, `Keyword presence`, `Text similarity`, `Exact match`, `Capability usage`, or `Custom Graders`.
4. Enter the test set name `Loan Processing Agent - Day 2 QA Baseline`.
5. Add at least five test cases that reflect the Loan Processing Agent scenario, including one question about applicant eligibility, one about loan product comparison, one about document verification, one ambiguous loan officer request, and one intentionally difficult case that should expose a weakness.
6. For each test case, choose one or more graders that fit the scenario, such as **General response quality**, **Semantic meaning**, **Capability usage**, **Keyword presence**, **Text similarity**, or **Exact match**. If your organization has custom evaluation policies, you can also configure a **Custom Graders** (Classification method) for compliance or regulatory checks.
7. For the cases that use match-based graders, enter an expected response that rewards lending guidance aligned with regulatory requirements, correct use of configured tools or knowledge, and safe handling of loan officer requests.
8. Select **User profile** and choose the connected workshop account so the evaluation can access the same tools and knowledge that a real maker would use.
9. Select **Evaluate** and wait for the run to finish.

![Evaluation page and new evaluation flow](./assets/lab-24-evaluation-start.png)

10. In **Recent results**, open the run you just completed and review the overall **Pass rate**.
11. Filter the **Test cases** list to **Fail** and open one failed case.
12. In the detailed result pane, review the expected response, actual response, grader reasoning, and the list of knowledge sources, topics, and tools used.
13. Select **Show activity map** to inspect the sequence of inputs, decisions, and outputs for the failed case.
14. Record one concrete issue that explains the failure, such as vague instructions, missing scope boundaries, weak clarifying behavior, or an incorrect tool choice.

> Note: This diagnostic review is the same quality habit you use in production operations when you analyze conversation transcripts, identify failure patterns, and improve the agent with evidence instead of guesswork.

15. Return to the **Overview** page for **Loan Processing Agent** and select **Edit** in the **Instructions** card.
16. Improve the instructions to address the failure you found. If you need a workshop-safe remediation, add or refine guidance such as `Ask one targeted clarifying question when the loan officer request is ambiguous.` and `Base lending guidance only on applicant qualifications, configured tools, and approved knowledge sources.`
17. Save the instructions and wait for the confirmation message.
18. Return to **Evaluation**, open the same test set, and select **Evaluate test set again**.
19. When the second run completes, open it and use **Compare with** to compare the new run to the baseline.
20. Confirm whether the failing case improved, whether the pass rate changed, and whether the new grader reasoning matches the behavior you intended.

![Detailed test result with activity map and comparison](./assets/lab-24-evaluation-results.png)

21. If your agent uses a custom prompt and a case is blocked by filtering rather than logic, review that prompt's **Content moderation level** for the specific prompt or tool instead of assuming the whole agent is wrong.

#### Validation
1. The **Evaluation** page shows at least one completed run for `Loan Processing Agent - Day 2 QA Baseline`.
2. You can open a failed test case and show evidence from the detailed result, including grader reasoning and the **activity map**.
3. The **Loan Processing Agent** instructions include a targeted improvement based on the failing case you analyzed.
4. A second evaluation run exists for the same test set, showing one improvement cycle rather than a single one-time check.
5. The comparison between runs shows either a higher pass rate, an improved individual case, or a clearly documented reason why the issue still needs more work.

#### Troubleshooting
1. If the **Evaluation** tab is unavailable, refresh the browser and reopen the agent before retrying.
2. If the run fails because tools or knowledge cannot authenticate, reopen **User profile** and repair the broken connection before rerunning the test set.
3. If import fails, verify the CSV column order is exactly **Question**, **Expected response**, and **Testing method**, then save the file as `.csv` and import it again.
4. If all cases pass too easily, tighten the expected responses or add **Capability usage**, **Semantic meaning**, **Text similarity**, or **Exact match** so the graders measure operational quality instead of surface-level politeness.
5. If a valid test case is blocked by safety filtering, review the prompt or tool settings that generated the blocked content and adjust the per-prompt moderation sensitivity only where justified.
6. If the agent keeps failing the same case after you edit instructions, simplify the instruction wording and make the expected behavior more explicit and lending-related.

#### Facilitator Notes
1. Emphasize that agent evaluation is an operational control, not just a workshop demo, because it reduces dependence on manual validation alone.
2. Connect the failing-case analysis to the transcript-analysis reference architecture: both use real interactions, structured review, and iterative improvement to raise quality over time.
3. Encourage participants to keep the same test set after the workshop so they can rerun it after future changes and detect regressions.
4. If participants ask about unsupported extras, steer them back to the workshop baseline of GA capabilities, with **GPT-5 Chat** as the preferred hands-on model.

