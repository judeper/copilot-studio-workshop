# Copilot Studio Workshop

## Day 2 — Woodgrove Lending Track

### Lab 21 — Document Generation: Adverse Action Notice

⏱ Estimated time: 45 min

#### Overview
In this lab, you will extend the **Loan Processing Agent** with a regulated document-generation workflow that drafts an **Adverse Action Notice** for a denied loan application. The notice is the written communication a lender must send when it declines, counteroffers, or otherwise takes adverse action on a credit application. You will populate a Word template from structured Dataverse fields, generate the consumer-rights statutory language with a prompt, return the document through an agent flow, and treat the result as a **draft for the compliance officer** — never as something the agent sends on its own.

This scenario keeps the same document-generation mechanic used previously (Word template + prompt + agent flow + topic) and re-anchors it on a workflow every lender recognizes.

> **Important:** The Adverse Action Notice produced in this lab is a **simplified, illustrative draft** for training purposes only. It is not legal-compliance-grade text. Real lenders must use their own legal-approved templates and have qualified compliance and legal staff review every notice before it leaves the institution.

#### Prerequisites
1. Complete **Lab 13** and **Lab 20** in the same environment.
2. Confirm at least one denied **Loan Application** (`wgb_loanapplication`) exists in Dataverse with an associated **Applicant** (`wgb_applicant`). If you do not have a denied record, edit one application and set its status to `Denied` with a decision date and one or more denial reasons before starting.
3. Confirm that you can edit a Word document template and store it in SharePoint or OneDrive.
4. [Maker] You need **Microsoft Word desktop** (not Word Online) to create the template with content controls. If you do not have Word desktop, use the prebuilt `Adverse_Action_Notice_Template.docx` referenced in `assets/adverse-action-template-spec.md` and ask your facilitator for the file. Upload it to SharePoint before starting Part 1.
5. Confirm that the flow account can use **Word Online (Business)** and **Dataverse** connections.

#### Step-by-Step Instructions

#### Part 1 — Build the Word template
1. Open **Microsoft Word** and create a new blank document.
2. If the **Developer** tab is hidden, enable it in **File** > **Options** > **Customize Ribbon**.
3. Add an Adverse Action Notice layout with these sections in order:
   - Lender header block (institution name, address, notice date)
   - Recipient block (applicant name and address)
   - Application reference block (application number, application date, decision, decision date)
   - Principal reasons for adverse action
   - Credit reporting agency disclosure (agency name, address, phone)
   - Consumer rights statement (FCRA §615(a) language)
   - Right-to-dispute and accuracy statement
   - Reviewer signature block (compliance officer name and title)
4. Insert **Plain Text Content Control** fields and set each control title to the matching name:
   - `ApplicantName`
   - `ApplicantAddress`
   - `ApplicationNumber`
   - `ApplicationDate`
   - `DecisionDate`
   - `PrincipalReasons`
   - `CreditBureauName`
   - `CreditBureauAddress`
   - `CreditBureauPhone`
   - `ConsumerRightsStatement`
   - `DisputeRightsStatement`
   - `ReviewerName`
5. Save the file as `Adverse_Action_Notice_Template.docx`.
6. Upload `Adverse_Action_Notice_Template.docx` to a SharePoint document library or OneDrive location that your flow account can access.

#### Part 2 — Create the consumer-rights prompt
1. In **Copilot Studio**, select **Tools**.
2. Select **+ Add a tool** and choose **Prompt**.
3. Name the prompt `Draft Adverse Action Statutory Language`.
4. Paste the instruction block below into the prompt editor.

```text
You are drafting two short statutory paragraphs for an Adverse Action Notice that a U.S. lender will send to a consumer applicant. The lender's compliance officer will review and edit your output before any notice is sent.

Return exactly two labeled paragraphs and nothing else:

ConsumerRightsStatement:
A short paragraph that states the lender obtained information from the consumer reporting agency named below, that the agency did not make the credit decision and cannot explain it, that the consumer has the right to obtain a free copy of the consumer report from that agency within 60 days of receiving this notice, and that the consumer has the right to dispute the accuracy or completeness of any information the agency furnished. Mention that this disclosure is made under the federal Fair Credit Reporting Act.

DisputeRightsStatement:
A short paragraph that explains how the consumer can request the free report and dispute inaccurate or incomplete information by contacting the consumer reporting agency listed in this notice, and that disputed information will be reinvestigated.

Use the values below only as context. Do not invent facts, account numbers, dates, or credit scores. Keep tone neutral, plain-language, and review-ready.

ApplicantName: /ApplicantName
CreditBureauName: /CreditBureauName
CreditBureauAddress: /CreditBureauAddress
CreditBureauPhone: /CreditBureauPhone
```

5. Add text inputs for `ApplicantName`, `CreditBureauName`, `CreditBureauAddress`, and `CreditBureauPhone`.
6. Set the model to **GPT-5 Chat** if it is available in your environment. If it is not, select another generally available model that fits the workshop baseline.
7. Keep the output as **Text**.
8. Save the prompt.

> **Why a prompt for statutory language?** The statutory disclosures must be clear, accurate, and consistent. The prompt drafts plain-language wording from a fixed instruction; the compliance officer then compares it against the lender's approved standard text before any notice goes out.

#### Part 3 — Build the document-generation flow
1. In **Tools**, select **+ Add a tool** and choose **Agent flow** under **Create new**.
2. In **When an agent calls the flow**, add text inputs named `ApplicationNumber` and `ReviewerName`.
3. Add Dataverse actions to retrieve the loan application (`wgb_loanapplication`) by application number, and to retrieve the related applicant (`wgb_applicant`). Capture the applicant name, applicant address, application date, decision date, denial reasons, and credit bureau details.
4. Add a **Condition** that checks whether the application status is `Denied`. If it is not, branch to **Respond to the agent** and return a message such as `Adverse action notice not generated. Application status is not Denied.` This guard prevents the agent from generating an adverse-action notice for an approved or in-progress application.
5. On the `Denied` branch, add a **Run a prompt** action and select `Draft Adverse Action Statutory Language`. Map the applicant name and credit bureau values from Dataverse.
6. Add **Word Online (Business)** and choose **Populate a Microsoft Word template**.
7. Select the SharePoint or OneDrive location where you uploaded `Adverse_Action_Notice_Template.docx`.
8. Map the Word template controls:
   - `ApplicantName`, `ApplicantAddress`, `ApplicationNumber`, `ApplicationDate`, `DecisionDate`, `PrincipalReasons`, `CreditBureauName`, `CreditBureauAddress`, `CreditBureauPhone` → Dataverse values
   - `ReviewerName` → flow input
   - `ConsumerRightsStatement` and `DisputeRightsStatement` → parsed from the prompt output (use `Compose` actions or `split()` expressions to separate the two labeled paragraphs)
9. Add **Respond to the agent**.
10. Add a **File** output named `AdverseActionNoticeFile`.
11. Map the file output to the populated Word document content and give it a file name such as `Adverse-Action-Notice-DRAFT-@{triggerBody()['ApplicationNumber']}.docx`. The `DRAFT` token in the file name is intentional — it signals that the document is not a sent notice.
12. Add a second text output named `ReviewReminder` with the value `DRAFT for compliance review only. Do not send to the applicant until the compliance officer approves the notice and confirms the timing requirements under ECOA Regulation B.`
13. Save the flow, rename it `Generate Adverse Action Notice Draft`, add a clear description, and then select **Publish**.

> **Tip:** Keep statutory language in the prompt and structured data in the Word template. This separation makes the document predictable to review and easy to align with the lender's approved text.

#### Part 4 — Add a topic so loan officers can request the draft in chat
1. Open **Loan Processing Agent** and select **Topics**.
2. Select **Add a topic** and choose **From blank**.
3. Name the topic `Draft Adverse Action Notice`.
4. In the trigger description, enter `Generates a DRAFT Adverse Action Notice for a denied loan application, for compliance officer review only`.
5. Add input variables for `ApplicationNumber` and `ReviewerName`.
6. Add the `Generate Adverse Action Notice Draft` flow as a tool in the topic.
7. Map the topic variables to the flow inputs.
8. Add a **Send a message** node that returns the file to the user with the message:

   ```
   Here is the DRAFT Adverse Action Notice for application {ApplicationNumber}. This draft is for the compliance officer to review and edit. Do not send it to the applicant until compliance approves the wording and confirms the ECOA Regulation B timing requirement (notice within 30 days of the adverse action).
   ```
9. Save the topic.

#### Part 5 — Test end to end
1. Start a **New test session** in **Loan Processing Agent**.
2. Ask the agent to draft an Adverse Action Notice for a known denied application number, for example: `Draft an adverse action notice for application LA-1042, reviewer Jordan Lee`.
3. Provide the application number and reviewer name when prompted.
4. Download the generated Word file.
5. Open the file and verify:
   - Applicant name and address match the Dataverse record.
   - The principal reasons section reflects the denial reasons stored on the application.
   - The credit bureau name, address, and phone are populated.
   - The two statutory paragraphs are present and readable.
   - The file name includes `DRAFT` and the chat reply includes the review reminder.
6. Test the guard: ask for an adverse action notice on an **approved** application and confirm the flow refuses and returns the guard message instead of a Word file.

#### Validation
1. `Adverse_Action_Notice_Template.docx` exists in SharePoint or OneDrive and contains all 12 required Plain Text Content Controls listed in Part 1.
2. The `Draft Adverse Action Statutory Language` prompt is saved and uses a generally available model.
3. The `Generate Adverse Action Notice Draft` agent flow is published and refuses to generate a notice when the application status is not `Denied`.
4. The `Draft Adverse Action Notice` topic returns a Word file in chat with `DRAFT` in the file name.
5. The chat reply includes the compliance review reminder and references ECOA Regulation B timing.
6. The downloaded document populates applicant, application, decision, principal reasons, credit bureau, and statutory language sections.

#### Troubleshooting
1. If Word fields are not available in the flow, reopen the template and confirm you used **Plain Text Content Controls** with saved titles.
2. If the statutory paragraphs are blank or merged into one cell, review the `Compose` or `split()` expression that separates `ConsumerRightsStatement:` and `DisputeRightsStatement:` from the prompt output.
3. If the flow generates a notice for an approved application, recheck the Condition node and confirm it branches on the `Denied` status value as stored in Dataverse.
4. If the document downloads but Dataverse fields are blank, review the Dataverse actions and confirm the application number lookup returns the expected record and related applicant.
5. If the topic does not return a file, recheck the **Respond to the agent** file mapping in the flow.
6. If the prompt invents content (account numbers, scores, dates), tighten the prompt instruction to forbid fabrication and re-run with a single denied application as input.

#### Facilitator Notes

##### Delivery
1. This lab keeps the stable GA document-generation pattern (prompt + Word template + flow + topic) and only changes the **scenario** to a regulated lending workflow every banker recognizes.
2. Have one known-good **denied** application number ready so you can demonstrate the end-to-end draft quickly.
3. Have one **approved** application number ready so you can demonstrate the guard branch refusing to generate a notice.
4. If time is short, provide the prebuilt `Adverse_Action_Notice_Template.docx` and spend class time on the prompt design, the guard condition, and the compliance framing.

##### Compliance & Governance Notes
1. **Never auto-send.** Reinforce throughout the lab that the agent produces a **draft** for the compliance officer. The agent must never send an Adverse Action Notice to a consumer on its own. The chat reply, the `DRAFT` token in the file name, and the `ReviewReminder` flow output all reinforce this.
2. **ECOA Regulation B (12 CFR §1002.9) — timing and notification.** Under the Equal Credit Opportunity Act, Regulation B, a creditor must notify an applicant of action taken on a completed application within **30 days**. This timing requirement is a human-and-process responsibility, not an AI responsibility. The lab calls this out in the chat reply.
3. **FCRA §615(a) (15 U.S.C. §1681m) — content of the notice when consumer report information is used.** The Fair Credit Reporting Act requires that when adverse action is based in whole or in part on information in a consumer report, the notice must include:
   - The name, address, and toll-free telephone number of the consumer reporting agency that furnished the report.
   - A statement that the consumer reporting agency did not make the credit decision and cannot explain the specific reasons.
   - The consumer's right to obtain a free copy of the report from the agency within **60 days**.
   - The consumer's right to dispute the accuracy or completeness of information the agency furnished.
   The prompt in Part 2 is written to draft these elements into plain language for compliance review.
4. **Principal reasons disclosure.** ECOA Reg B also requires a statement of the **principal reasons** for the adverse action (or notice of the right to obtain them). Reasons in this lab come from structured Dataverse fields on the loan application, not from the model. The agent never invents reasons.
5. **Illustrative, not legal-grade.** The lab text is a simplified training draft. Lenders must use their own legal-approved templates, must align principal-reason language with ECOA Reg B Appendix C model forms or their equivalent, and must obtain qualified legal and compliance review before any notice is sent to a consumer.
6. **Audit trail.** Encourage participants to think about how they would log every generated draft (who requested it, which application, when, who reviewed it, when it was sent) — that audit trail is what makes the workflow defensible to examiners.

##### Sample data hint
If your environment needs sample identities, use fictitious values such as applicant `Jordan Lee`, email `jordan.lee@example.com`, address `100 Example Street, Redmond WA 98052`, and credit bureau `Equifax Information Services LLC, P.O. Box 740241, Atlanta GA 30374, 1-800-685-1111`. Do not use real consumer data in the workshop environment.
