# Copilot Studio Workshop

## Day 2 — Enterprise Track

### Lab 13 — Loan Processing Agent Setup

⏱ Estimated time: 45 min

#### Overview
In this lab, you will stand up the Day 2 Loan Processing Agent scenario that you will extend throughout the rest of the enterprise track. You will import the lending solution, load starter data, and create the **Loan Processing Agent** that will orchestrate loan application intake, applicant screening, document review, and follow-up tasks for the Woodgrove Bank lending team.

> Note: Keep the same Power Platform environment, solution, and agent names through Labs 13–23 so later labs can build on this setup without rework.

#### Prerequisites
1. [Maker] Sign in to a Microsoft Power Platform environment where you can create solutions, tables, flows, and agents.
2. [Maker] Confirm that you have a Copilot Studio license or trial assigned.
3. [IT Pro] Confirm that your environment allows Dataverse, Power Automate, and Microsoft Teams connections.
4. [Maker] Locate the setup files in your local clone at `workshop/assets/`: `WoodgroveLending_1_0_0_0.zip`, `loan-types.csv`, and `assessment-criteria.csv`. If you do not have a local clone, your facilitator will share these files through the course delivery channel, shared drive, or Teams channel before the session begins.
5. [Developer] Open a browser with both **Copilot Studio** and **Power Apps** available so you can switch between them during setup.
6. Complete all Day 1 labs (Labs 00–12) or confirm equivalent Copilot Studio experience with the facilitator.

#### Step-by-Step Instructions
#### Part 1 — Import the lending solution
1. Open **Copilot Studio** at `https://copilotstudio.microsoft.com` and verify the correct environment in the **environment picker**.
2. In the left navigation, select **...** (More), and then select **Solutions**.
3. Select **Import solution** on the command bar.
4. Select **Browse**, choose `WoodgroveLending_1_0_0_0.zip`, and then select **Next**.
5. Review the package details, keep the default upgrade behavior, and select **Import**.
6. Wait for the green success notification, and then select the imported **WoodgroveLending** solution to open it.
7. Confirm that the solution contains the **Applicant**, **Application Document** (displayed as **Application Documents** in table pickers and Power Automate), **Loan Application**, **Loan Type**, and **Assessment Criteria** tables plus the **Woodgrove Lending Hub** model-driven app.
8. Select **Publish all customizations** before moving to the next section.

![Imported lending solution in Copilot Studio](./assets/lab-13-solution-import.png)

> Tip: If the import appears stalled, stay on the Solutions page and refresh after one minute before attempting a second import.

#### Part 2 — Create sample applicant and loan application data
1. In the **Woodgrove Lending Hub** app navigation, select **Applicants** (or the equivalent contact/applicant view).
2. Select **+ New** and create at least two sample applicant records such as `Avery Cole` (`avery.cole@example.com`) and `Morgan Diaz` (`morgan.diaz@example.com`), including a short financial profile summary for each.
3. In the app navigation, select **Loan Applications**.
4. Select **+ New** and create at least two loan application records so both sample applicants are linked to existing loan types, setting the status to `Active` or the default open state.
5. Confirm both applicant records and their linked loan applications appear in the grid views before continuing.

> **Tip:** These sample records are required by Lab 21 (Document Generation) and Lab 24 (Agent Evaluation). Creating them now avoids data gaps later in the day.

#### Part 3 — Load sample lending data
1. In the **Woodgrove Lending Hub** app navigation, select **Loan Types**.
2. On the command bar, select the **...** (more commands) dropdown, then select **Import from CSV**.
3. Select **Choose File**, upload `loan-types.csv`, confirm the **Owner For Imported Records** is set to your account, and then select **Next**.
4. On the **Delimiter Settings** screen, keep the defaults (Quotation mark data delimiter, Comma field delimiter, First row contains column headings checked, Allow Duplicates set to **No**) and select **Next**.
5. On the **Map Attributes** screen, in the **Primary Fields** section, map **Loan Type Name** by selecting the matching source column from the dropdown. The `loan-types.csv` columns are: `Loan Type Name`, `Description`, `Maximum Term (Months)`, `Minimum Amount`, `Maximum Amount`.
6. Select **Finish Import**.
7. When the confirmation reads **Your data has been submitted for import**, select **Done**. Wait for the import to complete and then select **Refresh** until you see the imported loan type records.
8. In the left navigation, select **Assessment Criteria**.
9. Repeat the CSV import process for `assessment-criteria.csv`.
10. On the mapping screen, verify that the **Primary Fields** section shows **Criteria Name** mapped and **Loan Type (Lookup)** mapped with a lookup icon (🔍). In the **Optional Fields** section, verify **Description** and **Weighting** are mapped. The `assessment-criteria.csv` columns are: `Criteria Name`, `Description`, `Loan Type`, `Weighting`.
11. Select **Finish Import**, select **Done**, and refresh until the assessment criteria rows appear.

![Sample data imported into the Woodgrove Lending Hub app](./assets/lab-13-sample-data.png)

> Warning: If the **Loan Type** lookup mapping is incorrect, the assessment criteria import can succeed with missing relationships. Fix the mapping before you continue.

#### Part 4 — Create the Loan Processing Agent
1. Return to **Copilot Studio** and select **Agents**.
2. Select the dropdown arrow next to **Create blank agent**, and then select **Advanced create**.

> **Tip:** If the dropdown arrow is not visible next to **Create blank agent**, navigate to **Solutions**, open the **WoodgroveLending** solution, select **+ New** > **Agent**, and create the agent from within the solution. This ensures it is automatically scoped to the WoodgroveLending solution.

3. In the **Agent settings** dialog, under **Advanced settings**, set **Solution** to **WoodgroveLending**.
4. Leave the **Schema name** at its default value. If the **Confirm and create** button is grayed out after changing the schema name, revert to the default — you will rename the agent in the next step.
5. Select **Confirm and create**.
6. In the new agent, open the **Details** card and select **Edit**.
7. In **Name**, enter `Loan Processing Agent`.
8. In **Description**, enter `Central orchestrator for the Woodgrove Bank lending process`.
9. Select **Save** and wait for the updated details to appear.
10. Select **Settings** and confirm these values before selecting **Save**: **Orchestration** = **Yes** (use generative AI orchestration), **File uploads** = **On**, **Use information from the Web** = **Off**, **Use general knowledge** = **Off**, **Content moderation level** slider = toward **High**, and **Collect user reactions to agent messages** = **On**.

> **Tip:** The content moderation setting is a slider rather than a dropdown. Slide it toward **High** for this workshop. The **User Feedback** section may show a **Preview** label, but the core reaction-collection feature is functional and used in Lab 23.

![Loan Processing Agent details and settings](./assets/lab-13-agent-details.png)

#### Validation
Use this post-setup checklist before you move to Lab 14.

1. The **WoodgroveLending** solution appears on the **Solutions** page with a successful import status.
2. The **Woodgrove Lending Hub** model-driven app opens and shows navigation for **Loan Types** and **Assessment Criteria**.
3. The **Loan Types** view contains imported sample records.
4. The **Assessment Criteria** view contains imported sample records that reference loan types.
5. The **Loan Processing Agent** appears on the **Agents** page with the correct name and description.
6. The **Loan Processing Agent** settings show **Generative AI orchestration** and **File uploads** enabled.
7. A new test session opens for the **Loan Processing Agent** without setup errors.

#### Troubleshooting
1. If the solution import fails, delete the failed import from **Solutions**, confirm you are in the correct environment, and import the ZIP again.
2. If the CSV import wizard does not appear, open the **Woodgrove Lending Hub** app in a new browser tab and retry the import from the table command bar.
3. If sample data imports but does not show in the app, select **Refresh** in the grid and then hard refresh the browser.
4. If the agent settings page shows disabled options, ask a facilitator or tenant admin to confirm your environment policies and licensing.
5. If the agent name does not update immediately, wait for the save operation to finish and then reload the agent page.

#### Facilitator Notes
1. Confirm before class that the import package and CSV files are distributed through your course delivery channel.
2. Keep one completed environment available so you can demonstrate the expected table relationships if a participant mapping issue occurs.
3. Encourage participants to keep the exact object names from this lab, because later labs reference **Loan Processing Agent** and the imported lending tables directly.
4. If time is tight, pre-stage the data import and focus class time on validating the solution contents and creating the agent.
