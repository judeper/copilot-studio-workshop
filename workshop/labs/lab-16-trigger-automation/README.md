# Copilot Studio Workshop

## Day 2 — Enterprise Track

### Lab 16 — Trigger Automation

⏱ Estimated time: 40 min

#### Overview
In this lab, you will automate the first step of the Loan Processing Agent pipeline. When a loan officer or lending coordinator uploads a new loan document PDF to SharePoint, the automation will capture the file, create an **Application Document** row in Dataverse, and notify the lending team so the Loan Processing Agent can continue processing the applicant.

#### Prerequisites
1. [Maker] Complete **Lab 13**, **Lab 14**, and **Lab 15** in the same environment.
2. [Maker] Confirm that you can create a SharePoint document library and a Power Automate connection.
3. [Maker] Confirm that the **Application Document** Dataverse table (displayed as **Application Documents** in Power Automate table pickers) exists from the imported lending solution.
4. [IT Pro] Confirm that your tenant policies allow SharePoint, Dataverse, and Microsoft Teams connections.
5. [Maker] Download or locate one sample loan document PDF for testing. Two fictitious sample documents are available in `workshop/assets/` (`MORGAN CHEN (FICTITIOUS).pdf` and `ALEX RIVERA (FICTITIOUS).pdf`).

#### Step-by-Step Instructions
#### Part 1 — Create the SharePoint drop-off location
1. Open **SharePoint** and navigate to the team site you created in Lab 00 (the same site used throughout Day 1).
2. Select **New** and then select **Document library**.
3. Name the library `Loan Documents` and select **Create**.
4. Upload one sample PDF so you can verify the library works.
5. Keep the library open in a browser tab for later testing.

![SharePoint library for loan documents](./assets/lab-16-sharepoint-library.png)

#### Part 2 — Add an event trigger to Loan Processing Agent
1. Open **Loan Processing Agent** in Copilot Studio.
2. In the **Overview** tab, scroll to **Triggers** and select **+ Add trigger**.
3. In the **Add trigger** dialog, search for or browse to a SharePoint file-created trigger such as **When a file is created (properties only)** (SharePoint), and select it.
4. Name the trigger `When a loan document is uploaded to SharePoint`.
5. Create or select the required connection references.
6. Set the **Site Address** to your workshop SharePoint site.
7. Set the **Library Name** to `Loan Documents`.
8. Select **Create trigger**.
9. On the trigger card, select **Edit in Power Automate**.

#### Part 3 — Filter for PDF documents and create the Dataverse record
1. In **Power Automate**, locate the new SharePoint trigger flow.
2. Add a **Condition** action directly under the trigger.
3. In the left condition field, select the SharePoint **File name with extension** dynamic value.
4. In the operator field, select **ends with**.
5. In the right condition field, enter `.pdf`.
6. In the **Yes** branch, add a **Get file content** action for the same SharePoint file.
7. Add a **Dataverse - Add a new row** action.
8. Set **Table name** to **Application Documents** (the plural display name for the Application Document table).
9. Set **Document Name** to the uploaded file name.
10. Set **Document Type** to `Financial Summary`.
11. Set **Upload Date** by using the `utcNow()` expression.
12. Add a **Dataverse - Upload a file or an image** action.
13. Set **Table name** to **Application Documents**, map the **Row ID** from the row you just created, select the file column, and map the SharePoint file content.

> Tip: If your library stores documents in mixed formats, keep the PDF check in place so unrelated file types do not enter the lending pipeline.

#### Part 4 — Notify the lending team

> **Note:** The Office 365 Outlook and Microsoft Teams connectors must be in the **Business** data group of your environment's DLP policy. If email or Teams actions fail with a policy error, contact your Power Platform admin or ask your facilitator.

1. In the **Yes** branch, add a **Microsoft Teams - Post card in a chat or channel** action after the Dataverse upload action.
2. Set **Post as** to **Flow bot**.
3. Set **Post in** to **Channel**.
4. Select the team and channel used by your lending group.
5. In the adaptive card body, include the message: `New loan document uploaded: [filename]. Ready for review.` along with the created document row identifier.
6. Save the flow.
7. Return to the trigger details, confirm the plan is associated with **Copilot Studio** if that option is available in your environment, and publish the flow.

![Loan document automation flow in Power Automate](./assets/lab-16-trigger-flow.png)

#### Part 5 — Test the automation
1. Return to the **Loan Documents** SharePoint library.
2. Upload a new sample PDF file.
3. Wait one to two minutes for the trigger flow to execute.
4. Open the **Woodgrove Lending Hub** app and go to **Application Documents**.
5. Confirm that a new row exists with the uploaded file name, document type of "Financial Summary", and a recent upload timestamp.
6. Open Microsoft Teams and confirm that the lending channel received the notification card.

#### Validation
1. The SharePoint library named **Loan Documents** exists and accepts PDF uploads.
2. The Copilot Studio trigger appears on the **Loan Processing Agent** overview page.
3. Uploading a PDF creates a new row in the **Application Documents** Dataverse table.
4. The new Dataverse row contains a file in the document file column.
5. The lending Teams channel receives a notification after the upload.

#### Troubleshooting
1. If the trigger does not fire, open the Power Automate flow run history and confirm the SharePoint connection is valid.
2. If the Dataverse row is created without a file, recheck the **Upload a file or an image** action and confirm you mapped file content rather than metadata.
3. If non-PDF files are being processed, confirm the condition uses the file name or content type field you intended.
4. If the Teams post fails, recreate the Teams connection and verify that you selected a channel you can post to.
5. If the flow saves but does not publish, remove any empty placeholder fields and save again before publishing.

#### Facilitator Notes
1. Pre-stage a SharePoint site and Teams channel if your participants do not have permission to create them during class.
2. Remind participants that this lab automates the trigger only; later labs add richer AI analysis and downstream lending actions.
3. Have one known-good PDF ready for a live demo so you can quickly prove the end-to-end flow when troubleshooting.
