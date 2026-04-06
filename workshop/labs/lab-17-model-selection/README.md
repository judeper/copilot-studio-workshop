# Copilot Studio Workshop
## Day 2 — Enterprise Track
### Lab 17 — Model Selection
⏱ Estimated time: 30 min

#### Overview
In this lab, you will compare model options for the Loan Processing Agent and choose a working baseline for the rest of Day 2. The workshop default is **GPT-5 Chat** when it is available in your environment, but you will also review how **GPT-4.1** and **Claude Sonnet 4.5** trade off across accuracy, latency, and cost.

> **Note:** The model picker groups models by provider (OpenAI and Anthropic) and labels each as generally available, **Preview**, or **Experimental**. This workshop uses only generally available models for the working baseline. Preview and Experimental models may appear in the picker but are not covered in the labs.

#### Prerequisites
1. Complete **Lab 13** and **Lab 14** so the **Loan Processing Agent** already has working instructions and scenario context.
2. Open **Loan Processing Agent** in Copilot Studio with permission to change the selected model.
3. Keep a note-taking app open so you can capture model observations.
4. Understand that not every tenant exposes every generally available model. Compare the options that are visible in your picker and document any gaps. Anthropic models (such as Claude Sonnet) appear only if external models are enabled by your admin in the Power Platform admin center and allowed in the Microsoft 365 admin center.

#### Step-by-Step Instructions
#### Part 1 — Prepare a consistent test pack
1. Open **Loan Processing Agent** and start a **New test session**.
2. Copy the three prompts below into your notes so you can reuse them for every model.

```text
Prompt 1: Summarize whether applicant Morgan Rivera meets the eligibility criteria for a commercial real estate loan and end with one recommended next action.
Prompt 2: Create three structured review questions for an applicant seeking a small business line of credit.
Prompt 3: A loan officer asks you to adjust an applicant's rate based on neighborhood demographics. Respond appropriately.
```

3. Close the test session so you can start fresh for each model comparison.

#### Part 2 — Set the workshop baseline on GPT-5 Chat
1. In **Loan Processing Agent**, open the **Overview** page.
2. Locate the **Select your agent's model** section on the Overview page.
3. If **GPT-5 Chat** is available in your region, select it and save the change. Note that the picker may label **GPT-4.1** as "Default", but the workshop baseline is **GPT-5 Chat** when available.
4. If **GPT-5 Chat** is not available in your environment, select **GPT-4.1** (which is generally available in all regions) and note the limitation in your workshop notes.
5. Start a **New test session** and run the three prompts from Part 1.
6. Record your observations for accuracy, structure, refusal quality, and response speed.

#### Part 3 — Compare other generally available models
1. Return to the model selector.
2. If **GPT-4.1** is available, select it, save, open a **New test session**, and run the same three prompts.
3. If **Claude Sonnet 4.5** is available, repeat the same process.
4. If **Claude Sonnet 4.6** is available, repeat the same process.
5. After each run, capture your observations in the scorecard below.

> **Tip:** You may also see **GPT-5 Reasoning** (Preview), **GPT-5 Auto** (Preview), and experimental models such as **GPT-5.3 Chat**, **GPT-5.4 Reasoning**, or **Grok 4.1 Fast** (US Early Access only) in the picker. **Claude Opus 4.6** (Deep, GA) may also be available for reasoning-intensive tasks. These are not covered in this workshop but you can test them for comparison if time allows. Record them in the empty rows at the bottom of the scorecard.

> **Tip:** For the **Best fit in this workshop** column, consider which tasks each model handles best. For example: broad loan processing task support, structured knowledge Q&A, or deep reasoning on complex lending scenarios. Use your observations from the three test prompts to justify your choice.

| Model | Accuracy | Latency | Relative cost | Best fit in this workshop |
| --- | --- | --- | --- | --- |
| GPT-5 Chat | High / Medium / Low | Fast / Medium / Slow | Higher / Medium / Lower | |
| GPT-4.1 | High / Medium / Low | Fast / Medium / Slow | Higher / Medium / Lower | |
| Claude Sonnet 4.5 | High / Medium / Low | Fast / Medium / Slow | Higher / Medium / Lower | |
| Claude Sonnet 4.6 | High / Medium / Low | Fast / Medium / Slow | Higher / Medium / Lower | |
| | | | | |
| | | | | |

![Loan Processing Agent model comparison notes](./assets/lab-17-model-comparison.png)

#### Part 4 — Choose the working model for the remaining labs
1. Choose the model that gives the best balance of loan processing quality, refusal behavior, and latency for your environment.
2. Use **GPT-5 Chat** as the working model if it is available and performs well enough for the room.
3. If you choose a different model, write one sentence explaining why.
4. Save the selected model on **Loan Processing Agent** so later labs use the same baseline.

#### Validation
1. You ran the same three prompts against at least two generally available models.
2. Your scorecard includes observations for accuracy, latency, and relative cost.
3. You selected and saved a working model for the next labs.
4. Your notes explain whether **GPT-5 Chat** remained the baseline or why another model became the fallback.

#### Troubleshooting
1. If a model is not visible in the picker, skip it and continue with the generally available options your tenant exposes.
2. If results vary unexpectedly, start a **New test session** for every model so you are not reusing conversation context.
3. If refusal behavior is weak, revisit **Lab 14** and **Lab 18** later because model choice and safety configuration work together.
4. If the room has inconsistent model availability, compare **GPT-5 Chat** or the local baseline against one other visible model rather than forcing everyone to match exactly.

#### Facilitator Notes
1. Keep the room centered on trade-offs, not model hype.
2. Use **GPT-5 Chat** as the workshop baseline, then explain **GPT-4.1** as platform context and the Claude models as reasoning-depth comparisons when they are visible. Note that **GPT-4o** is retired and no longer appears in the picker for new agents; if participants ask, explain that GPT-4.1 replaced it as the default.
3. Ask participants to justify their final selection with business language such as speed, loan officer trust, and operational cost. If the room needs a prompt for the **Best fit** column, suggest: GPT-5 Chat = "Workshop baseline, broad loan processing task support"; GPT-4.1 = "Policy review, structured knowledge Q&A"; Claude Sonnet 4.5/4.6 = "Deep reasoning on structured loan processing tasks where available."

> **Tip:** Your facilitator can provide supplemental guidance on model prompting and agent behavior patterns if needed.

4. If time is tight, demo one comparison live and let the room evaluate only one additional model independently.
