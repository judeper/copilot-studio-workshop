# Copilot Studio Workshop

## Day 2 — Woodgrove Lending Track

### Lab 19 — Multimodal Prompts

⏱ Estimated time: 35 min

#### Overview
In this lab, you will teach the Loan Processing Agent to read financial documents as uploaded files or images, not just as plain text. You will create a multimodal prompt that extracts structured lending data from a PDF loan application and returns consistent JSON that later labs can reuse.

#### Prerequisites
1. [Maker] Complete **Lab 13** and keep the imported lending tables available.
2. [Maker] Have one text-based PDF financial document and one image-based financial document or phone photo of a printed application available for testing. Sample files `MORGAN CHEN (FICTITIOUS).pdf` and `ALEX RIVERA (FICTITIOUS).pdf` are available in `workshop/assets/`.
3. [Developer] If you want to compare OCR quality, prepare both a clear scan and a lower-quality image sample.

#### Step-by-Step Instructions
#### Part 1 — Create the multimodal prompt
1. Open **Loan Processing Agent** (or **Document Review Agent**) in Copilot Studio and select **Tools**.
2. Select **+ Add a tool** and then select **Prompt**.
3. Rename the prompt to `Financial Document Analysis`.
4. In the instructions area, paste the prompt below.

```text
Analyze the uploaded financial document and extract the following information into structured JSON.
For any field not found in the document, return an empty string.
Do not invent or estimate values.

Return valid JSON with these fields:
{
  "applicant_name": "string",
  "document_type": "string",
  "annual_income": "string",
  "employer_name": "string",
  "employment_duration": "string",
  "monthly_debt_payments": "string",
  "assets_total": "string",
  "liabilities_total": "string",
  "requested_loan_amount": "string",
  "requested_loan_type": "string",
  "notes": "string"
}

Rules:
- Do not invent missing details.
- If a value is missing, return an empty string.
- Keep notes under 120 words.
- Put only evidence-based observations in notes.

Financial document: /DocumentFile
Officer context: /OfficerContext
```

5. Add an input named `DocumentFile` with type **Image or document**.
6. Add an input named `OfficerContext` with type **Text** and sample text `Analyze this financial document for the Woodgrove Bank lending workflow.`
7. Change the **Output** type to **JSON**.
8. The model defaults to **GPT-4.1 mini**. GPT-4.1 mini has limited document and image analysis accuracy compared to full-size models — always upgrade the model for this prompt. Change it to **GPT-5 Chat** if it is available in your environment for document and image analysis. If GPT-5 Chat is not available, select **GPT-4.1**, which is generally available and also supports document and image analysis.

![Prompt builder configured for document and image input](./assets/lab-19-prompt-builder.png)

#### Part 2 — Test with a PDF financial document
1. In the **DocumentFile** input, upload `MORGAN CHEN (FICTITIOUS).pdf` from `workshop/assets/`.
2. Select **Test**.
3. Review the JSON output and confirm that the key fields are populated.
4. Confirm that missing values are blank rather than fabricated.

#### Part 3 — Test with a second financial document
1. Replace the first PDF with `ALEX RIVERA (FICTITIOUS).pdf` from `workshop/assets/`, or use an image-based financial document or a clear phone photo of a printed application.
2. Select **Test** again.
3. Compare the JSON output with the first result.
4. Note any extraction issues in the `notes` field.

> Tip: If the image result is weak, crop the photo, increase contrast, or retake it from a flatter angle before changing the prompt.

#### Part 4 — Make the prompt available to the lending workflow
1. Select **Save**.
2. In the post-save dialog, select **Configure for use in agent** if you want to expose the prompt directly as a tool.
3. [Maker] Add the prompt to **Document Review Agent** if you want a specialist agent to use it later in the day.
4. [Developer] If you prefer deterministic orchestration, plan to call the prompt from an **Agent flow** in a later step rather than from the agent directly.

![JSON output from multimodal financial document analysis](./assets/lab-19-json-output.png)

#### Validation
1. The `Financial Document Analysis` prompt exists and is saved.
2. The prompt accepts **Image or document** input.
3. The output is valid JSON rather than plain text.
4. A PDF financial document returns structured applicant data.
5. A second financial document also returns structured data, with notes where needed.

#### Troubleshooting
1. If the prompt returns plain text, switch the **Output** setting back to **JSON** and test again.
2. If the model hallucinates missing values, reinforce the “return an empty string” rule and retest.
3. If the image-based result is poor, improve the document image before making the prompt more complicated.
4. If fields arrive with inconsistent names, keep the JSON schema exactly aligned with the instruction block.

#### Facilitator Notes
1. Show both a clean PDF and a messy phone photo so participants see why multimodal prompt quality depends on input quality.
2. Emphasize that multimodal extraction is a building block; later labs connect it to grounding and workflow automation.
3. If time is short, have everyone test the PDF path first and demo the image path centrally.
4. A prebuilt starter template is available at `workshop\assets\FSI07StarterTemplate.zip`. Offer it to participants who need help getting started or are falling behind. If they use it, remind them to reconfigure any placeholder Teams routing, Dataverse environment values, and app or view ID placeholders after import.
