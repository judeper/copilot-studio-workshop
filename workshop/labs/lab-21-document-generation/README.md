# Copilot Studio Workshop

## Day 2 — Operative Track

### Lab 21 — Document Generation

⏱ Estimated time: 45 min

#### Overview
In this lab, you will extend the Hiring Agent scenario with an offer-letter generation workflow that uses generally available capabilities only. You will create a Word template, use a prompt to draft the narrative section, populate the template through an agent flow, and return the finished document to the recruiter.

#### Prerequisites
1. Complete **Lab 13** and **Lab 20** in the same environment.
2. Confirm that you have at least one candidate, one job application, and one job requisition available for testing.
3. Confirm that you can edit a Word document template and store it in SharePoint or OneDrive.
4. [Maker] You need **Microsoft Word desktop** (not Word Online) to create the template with content controls. If you do not have Word desktop, the prebuilt `OfferLetterTemplate.docx` is included in `workshop/assets/Operative09StarterSolution.zip`. Extract it and upload it to SharePoint before starting Part 1.
5. Confirm that the flow account can use **Word Online (Business)** and **Dataverse** connections.

#### Step-by-Step Instructions
#### Part 1 — Build the Word template
1. Open **Microsoft Word** and create a new blank document.
2. If the **Developer** tab is hidden, enable it in **File** > **Options** > **Customize Ribbon**.
3. Add a simple offer-letter layout with a company header, greeting, body section, and signature block.
4. Insert **Plain Text Content Control** fields for these values and set each control title to the matching name: `CandidateName`, `JobTitle`, `Department`, `HiringManager`, `StartDate`, `SalaryText`, `BonusText`, `Location`, `ExpirationDate`, `OfferNarrative`, and `RecruiterName`.
5. Save the file as `OfferLetterTemplate.docx`.
6. Upload `OfferLetterTemplate.docx` to a SharePoint document library or OneDrive location that your flow account can access.

![Offer letter template with Word content controls](./assets/lab-21-offer-template.png)

#### Part 2 — Create the narrative prompt
1. In **Copilot Studio**, select **Tools**.
2. Select **+ Add a tool** and choose **Prompt**.
3. Name the prompt `Draft Offer Letter Narrative`.
4. Paste the instruction block below into the prompt editor.

```text
You are drafting the narrative section of a Contoso offer letter.
Use only the supplied hiring details.
Keep the tone professional, encouraging, and ready for recruiter review.
Do not invent compensation, benefits, or dates.
Return two short paragraphs only.

CandidateName: /CandidateName
JobTitle: /JobTitle
Department: /Department
Location: /Location
StartDate: /StartDate
SalaryText: /SalaryText
BonusText: /BonusText
ExpirationDate: /ExpirationDate
```

5. Add text inputs for `CandidateName`, `JobTitle`, `Department`, `Location`, `StartDate`, `SalaryText`, `BonusText`, and `ExpirationDate`.
6. Set the model to **GPT-5 Chat** if it is available in your environment. If it is not, select another generally available model that fits the workshop baseline.
7. Keep the output as **Text**.
8. Save the prompt.

#### Part 3 — Build the document-generation flow
1. In **Tools**, select **+ Add a tool** and choose **Agent flow** under **Create new**.
2. In **When an agent calls the flow**, add text inputs named `ApplicationNumber`, `StartDate`, `SalaryText`, `BonusText`, `ExpirationDate`, and `RecruiterName`.
3. Add the Dataverse actions needed to retrieve the job application, candidate, and requisition values that belong to the selected application number.
4. Add a **Run a prompt** action and select `Draft Offer Letter Narrative`.
5. Map the Dataverse and flow values to the prompt inputs.
6. Add **Word Online (Business)** and choose **Populate a Microsoft Word template**.
7. Select the SharePoint or OneDrive location where you uploaded `OfferLetterTemplate.docx`.
8. Map the Word template controls to your flow values and map `OfferNarrative` to the prompt output.
9. Add **Respond to the agent**.
10. Add a **File** output named `OfferLetterFile`.
11. Map the file output to the populated Word document content and give it a file name such as `Offer-Letter-@{triggerBody()['ApplicationNumber']}.docx`.
12. Save the flow, rename it `Generate Offer Letter`, add a clear description, and then select **Publish**.

> **Tip:** Use the Word template step to keep the final document format stable while the prompt generates only the narrative text that truly benefits from AI assistance.

#### Part 4 — Add a topic so recruiters can request the document in chat
1. Open **Hiring Agent** and select **Topics**.
2. Select **Add a topic** and choose **From blank**.
3. Name the topic `Create Offer Letter`.
4. In the trigger description, enter `Generates an offer letter document for a specific hiring application`.
5. Add input variables for `ApplicationNumber`, `StartDate`, `SalaryText`, `BonusText`, `ExpirationDate`, and `RecruiterName`.
6. Add the `Generate Offer Letter` flow as a tool in the topic.
7. Map the topic variables to the flow inputs.
8. Add a **Send a message** node that returns the file to the user with the message `Here is the draft offer letter for review.`
9. Save the topic.

![Offer letter flow and topic connection](./assets/lab-21-offer-flow.png)

#### Part 5 — Test end to end
1. Start a **New test session** in **Hiring Agent**.
2. Request an offer letter for a real application number from your environment.
3. Provide the requested start date, salary text, bonus text, expiration date, and recruiter name if the topic asks for them.
4. Download the generated Word file.
5. Open the file and verify that the fields are filled correctly and the narrative reads naturally.

#### Validation
1. `OfferLetterTemplate.docx` exists in SharePoint or OneDrive and contains the required Word content controls.
2. The `Draft Offer Letter Narrative` prompt is saved and uses a generally available model.
3. The `Generate Offer Letter` agent flow is published.
4. The `Create Offer Letter` topic returns a Word file in chat.
5. The downloaded document contains the expected candidate, requisition, and narrative values.

#### Troubleshooting
1. If Word fields are not available in the flow, reopen the template and confirm you used **Plain Text Content Controls** with saved titles.
2. If the flow returns a blank narrative, test `Draft Offer Letter Narrative` directly and confirm the prompt inputs are mapped correctly.
3. If the document downloads but fields are blank, review the Dataverse actions and confirm they return the expected application data.
4. If the topic does not return a file, recheck the **Respond to the agent** file mapping in the flow.

#### Facilitator Notes
1. This lab intentionally uses a stable GA document-generation pattern: prompt for narrative, Word template for layout, flow for assembly.
2. Have one known-good application number ready so you can demonstrate the finished document quickly.
3. If time is short, provide a prebuilt template and spend class time on prompt, flow, and topic wiring. A starter solution is available at `workshop\assets\Operative09StarterSolution.zip` which includes a prebuilt `OfferLetterTemplate.docx` for participants who do not have Word desktop or need a head start.

