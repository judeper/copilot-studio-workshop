# Copilot Studio Workshop

## Day 2 — Woodgrove Lending Track

### Lab 20 — Dataverse Grounding

⏱ Estimated time: 40 min

> **Model guidance:** See [Model Baseline](../../facilitator-guide/model-baseline.md) for current preferred and fallback models.

#### Overview
In this lab, you will ground the Loan Processing Agent workflow in a live Dataverse table of loan products. You will verify the **Loan Type** (`wgb_loantype`) table, connect that table to a prompt, and produce applicant-to-product matches based on the current Woodgrove Bank product catalog instead of static text.

#### Prerequisites
1. [Maker] Complete **Lab 19** or have a saved financial document analysis prompt available.
2. [Maker] Confirm you are working in the same environment used in Lab 13, which must have Dataverse provisioned. Power Apps Developer Plan environments support custom table creation.
3. [Maker] Have at least one sample financial document available for prompt testing.

#### Step-by-Step Instructions
#### Part 1 — Verify the Loan Type table

> **Note:** The **Loan Type** (`wgb_loantype`) table was imported as part of the Woodgrove Lending solution in Lab 13. In this section you will verify the table exists, review its columns, and confirm it contains sample loan products for grounding.

1. Open **Power Apps** at `https://make.powerapps.com` and confirm the correct environment.
2. Select **Tables** and locate the table named **Loan Type** (`wgb_loantype`).
3. If the table does not exist, return to **Lab 13** and re-import the solution, or create the table manually with the columns listed below.
4. Verify these columns exist: **Loan Type Name**, **Description**, **Minimum Amount**, **Maximum Amount**, **Maximum Term (Months)**, **Interest Rate Range**, **Status**.
5. Confirm that at least two loan products are present (for example, **Mortgage** and **Personal Loan**) with **Status** set to `Active`.
6. If needed, add additional loan products so the agent has a realistic product catalog to match against.

![Dataverse Loan Type table with sample rows](./assets/lab-20-job-requisitions-table.png)

#### Part 2 — Create the grounded matching prompt
1. Return to **Copilot Studio** and open **Tools**.
2. Create a new prompt named `Loan Product Matching` or duplicate your Lab 19 prompt and rename it.
3. Paste the instruction block below into the prompt editor.

```text
Given the applicant's requested loan amount and purpose, identify the most suitable loan type(s) from the Woodgrove Bank product catalog.
Use only the supplied applicant details and grounded Loan Type data.

Return valid JSON in this structure:
{
  "ApplicantName": "string",
  "MatchedLoanProducts": [
    {
      "LoanTypeName": "string",
      "MaximumTerm": "string",
      "AmountRange": "string",
      "Explanation": "string"
    }
  ],
  "RecommendationSummary": "string"
}

Rules:
- Match against active loan products only.
- Do not invent loan product names or identifiers.
- Use the applicant's stated amount, purpose, and financial profile to explain every match.
- If no match is appropriate, return an empty array and explain why in RecommendationSummary.

Loan products: /LoanTypes
Applicant details: /ApplicantFile
```

4. Add an input named `ApplicantFile` with type **Image or document**.
5. Delete the text `/LoanTypes` from the instruction block. Place your cursor where it was, type `/` or select **+ Add content** at the bottom of the editor, and then choose **Dataverse** under the **Knowledge** section.
6. Choose the **Loan Type** (`wgb_loantype`) table.
7. Select the columns **Loan Type Name**, **Description**, **Minimum Amount**, **Maximum Amount**, **Maximum Term (Months)**, **Interest Rate Range**, and **Status**.
8. Set the filter to **Status = Active**.
9. Open the prompt **Settings** menu and raise **Record retrieval** high enough to cover your active loan products.
10. Change the **Model** from **GPT-4.1 mini** (the default) to **GPT-5 Chat** if your environment includes it, because this prompt accepts document and image input. If GPT-5 Chat is not available, select **GPT-4.1**, which is generally available and also supports document and image analysis.
11. Set the **Output** type to **JSON** and save the prompt.

#### Part 3 — Test grounded matching
1. In the test area, type: `The applicant wants $250,000 to buy a house. What loan products are available?`
2. Select **Test**.
3. Open the **Knowledge used** pane and verify that Dataverse loan product rows were injected into the prompt context.
4. Confirm that the JSON output references the **Mortgage** loan type with the correct amount range and maximum term from your Dataverse table.
5. Adjust the loan product data or prompt wording if the match explanations are too vague.

![Grounded prompt showing loan product knowledge in context](./assets/lab-20-grounded-prompt.png)

#### Part 4 — Attach the grounded prompt to the lending workflow
1. [Maker] Save the prompt.
2. [Maker] Add the prompt to **Document Review Agent** or **Loan Processing Agent** as a tool if you want the agent to suggest loan products directly.
3. [Developer] If you need deterministic processing, plan to call this prompt from an **Agent flow** that first stores the applicant details and then returns the matched loan products.

#### Validation
1. The **Loan Type** (`wgb_loantype`) Dataverse table exists with at least two active rows.
2. The grounded prompt references Dataverse content from **Loan Type**.
3. The prompt filter limits data to active loan products.
4. Test output includes real loan product names from Dataverse.
5. The recommendation summary explains why each loan product was selected.

#### Troubleshooting
1. If the table does not appear in the prompt builder, publish your Dataverse changes and refresh Copilot Studio.
2. If no loan products are returned, verify the **Status = Active** filter and check the exact stored values in Dataverse.
3. If the prompt returns invented product names, add a stricter instruction that loan product names must come from grounded data only.
4. If the output is too long, reduce record retrieval or narrow the selected columns.

#### Facilitator Notes
1. Encourage participants to use realistic loan product descriptions, because grounding quality depends on the quality of the source data.
2. This lab is the turning point from generic AI to business-data-aware AI; call that out explicitly.
3. If some participants already have a loan product table in their tenant, let them reuse it instead of creating a new one.

