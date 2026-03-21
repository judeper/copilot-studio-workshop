# Copilot Studio Workshop

## Day 2 — Operative Track

### Lab 20 — Dataverse Grounding

⏱ Estimated time: 40 min

#### Overview
In this lab, you will ground the Hiring Agent workflow in a live Dataverse table of job requisitions. You will create or populate a **Job Requisitions** table, connect that table to a prompt, and produce resume-to-requisition matches based on current openings instead of static text.

#### Prerequisites
1. [Maker] Complete **Lab 19** or have a saved resume-analysis prompt available.
2. [Maker] Confirm you are working in the same environment used in Lab 13, which must have Dataverse provisioned. Power Apps Developer Plan environments support custom table creation.
3. [Maker] Have at least one sample resume file available for prompt testing.

#### Step-by-Step Instructions
#### Part 1 — Create or verify the Job Requisitions table

> **Note:** The **Job Requisitions** table is not included in the Operative solution you imported in Lab 13. You will create it manually in this section so the Hiring Agent can match candidates to live openings.

1. Open **Power Apps** at `https://make.powerapps.com` and confirm the correct environment.
2. Select **Tables** and check whether a table named **Job Requisitions** already exists.
3. If the table does not exist, select **New table** and create `Job Requisitions`.
4. Add these columns: **Requisition Number**, **Job Title**, **Department**, **Location**, **Hiring Manager**, **Must Have Skills**, **Nice to Have Skills**, **Status**.
5. Save and publish the table.
6. Add at least two open requisitions that the Hiring Agent can match against.
7. Set **Status** to `Open` for the rows you want the prompt to use.
8. Open the **Operative** solution, select **+ Add existing** > **Table**, and add **Job Requisitions** so the table is included in the solution for ALM and environment transport.

![Dataverse Job Requisitions table with sample rows](./assets/lab-20-job-requisitions-table.png)

#### Part 2 — Create the grounded matching prompt
1. Return to **Copilot Studio** and open **Tools**.
2. Create a new prompt named `Match Resume to Requisitions` or duplicate your Lab 19 prompt and rename it.
3. Paste the instruction block below into the prompt editor.

```text
You are matching a candidate resume to live Contoso job requisitions.
Use only the supplied resume and grounded Job Requisitions data.

Return valid JSON in this structure:
{
  "CandidateName": "string",
  "MatchedRequisitions": [
    {
      "RequisitionNumber": "string",
      "JobTitle": "string",
      "MatchReason": "string",
      "MatchStrength": "High|Medium|Low"
    }
  ],
  "RecommendationSummary": "string"
}

Rules:
- Match against open requisitions only.
- Do not invent requisition identifiers.
- Use skill evidence from the resume to explain every match.
- If no match is appropriate, return an empty array and explain why in RecommendationSummary.

Open requisitions: /JobRequisitions
Resume: /ResumeFile
```

4. Add an input named `ResumeFile` with type **Image or document**.
5. Delete the text `/JobRequisitions` from the instruction block. Place your cursor where it was, type `/` or select **+ Add content** at the bottom of the editor, and then choose **Dataverse** under the **Knowledge** section.
6. Choose the **Job Requisitions** table.
7. Select the columns **Requisition Number**, **Job Title**, **Department**, **Location**, **Must Have Skills**, **Nice to Have Skills**, and **Status**.
8. Set the filter to **Status = Open**.
9. Open the prompt **Settings** menu and raise **Record retrieval** high enough to cover your open requisitions.
10. Change the **Model** from **GPT-4.1 mini** (the default) to **GPT-5 Chat** if your environment includes it, because this prompt accepts document and image input. If GPT-5 Chat is not available, select **GPT-4.1**, which is generally available and also supports document and image analysis.
11. Set the **Output** type to **JSON** and save the prompt.

#### Part 3 — Test grounded matching
1. Upload a sample resume into the `ResumeFile` input.
2. Select **Test**.
3. Open the **Knowledge used** pane and verify that Dataverse requisition rows were injected into the prompt context.
4. Confirm that the JSON output includes real requisition numbers from your Dataverse table.
5. Adjust the requisition data or prompt wording if the match reasons are too vague.

![Grounded prompt showing requisition knowledge in context](./assets/lab-20-grounded-prompt.png)

#### Part 4 — Attach the grounded prompt to the hiring workflow
1. [Maker] Save the prompt.
2. [Maker] Add the prompt to **Application Intake Agent** or **Hiring Agent** as a tool if you want the agent to suggest roles directly.
3. [Developer] If you need deterministic processing, plan to call this prompt from an **Agent flow** that first stores the resume and then returns the matched requisitions.

#### Validation
1. The **Job Requisitions** Dataverse table exists with at least two open rows.
2. The grounded prompt references Dataverse content from **Job Requisitions**.
3. The prompt filter limits data to open requisitions.
4. Test output includes real requisition numbers from Dataverse.
5. The recommendation summary explains why each match was selected.

#### Troubleshooting
1. If the table does not appear in the prompt builder, publish your Dataverse changes and refresh Copilot Studio.
2. If no requisitions are returned, verify the **Status = Open** filter and check the exact stored values in Dataverse.
3. If the prompt returns invented identifiers, add a stricter instruction that requisition numbers must come from grounded data only.
4. If the output is too long, reduce record retrieval or narrow the selected columns.

#### Facilitator Notes
1. Encourage participants to use realistic requisition text, because grounding quality depends on the quality of the source data.
2. This lab is the turning point from generic AI to business-data-aware AI; call that out explicitly.
3. If some participants already have a requisition table in their tenant, let them reuse it instead of creating a new one.

