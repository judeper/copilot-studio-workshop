# Copilot Studio Workshop
## Day 1 — Foundation Track
### Lab 04 — Solutions
⏱ Estimated time: 45 min

#### Overview
In this lab, you will create a publisher and a solution for the Woodgrove Bank workshop assets, then validate that the solution can move between environments. The solution becomes the transport container for customizations, and the export/import exercise gives participants a concrete ALM checkpoint before later labs add more components.

![Solution explorer showing Woodgrove Customer Service Agent solution](./assets/lab-04-solution-explorer.png)

#### Prerequisites
1. Complete Lab 00 and confirm you are in the correct developer environment.
2. [Maker] Confirm you have the **Environment Maker**, **System Customizer**, or **System Administrator** role.
3. [IT Pro] Confirm you have a second environment available for import validation, or arrange a facilitator-provided validation environment.

#### Step-by-Step Instructions
#### Step 1 — Open Solution Explorer
1. Go to `https://copilotstudio.microsoft.com`.
2. In the left navigation, select **...** (More) and then select **Solutions**.
3. Wait for the **Solutions** page to load and confirm the correct environment name appears near the top of the page.

#### Step 2 — Create a publisher
1. Select **+ New solution**.
2. In the **Publisher** field, select **+ New publisher**.
3. In the **Display name** field, enter `Woodgrove Bank Solutions`.
4. In the **Name** field, enter `WoodgroveBankSolutions`.
5. In the **Description** field, enter `Copilot Studio workshop publisher for Woodgrove Bank assets`.
6. In the **Prefix** field, enter `cts`.
7. In the **Choice value prefix** field, round the suggested number down to the nearest thousand.
8. Select **Save**.

#### Step 3 — Create the workshop solution
1. Back in the **New solution** pane, confirm `Woodgrove Bank Solutions` is selected in the **Publisher** field.
2. In the **Display name** field, enter `Woodgrove Customer Service Agent`.
3. In the **Name** field, enter `WoodgroveCustomerServiceAgent`.
4. Leave the **Version** field at `1.0.0.0`.
5. Select the **Set as your preferred solution** checkbox. If this option does not appear in Copilot Studio, complete the creation here and then open `https://make.powerapps.com`, navigate to the solution, and set it as preferred from there.
6. Select **Create**.
7. When the new solution opens, confirm the header shows `Woodgrove Customer Service Agent`.

#### Step 4 — Add one transportable component for validation
1. Inside the solution, select **+ New** and choose **Environment variable**.
2. In the **Display name** field, enter `Woodgrove Scenario Name`.
3. In the **Name** field, accept the generated name that starts with `cts_`.
4. Set **Data type** to **Text**.
5. In the **Default value** field, enter `Woodgrove Bank Customer Service`.
6. Select **Save** and confirm the environment variable appears in the solution component list.

#### Step 5 — Export the solution
1. Select **Back** to return to the main **Solutions** list if the solution detail view is still open.
2. Select the row for **Woodgrove Customer Service Agent**.
3. Select **Export**.
4. Choose **Managed** for the package type if you are validating deployment to another environment, or **Unmanaged** if the facilitator instructed you to keep editing after import.
5. Confirm the **Version** is still `1.0.0.0` and start the export.
6. When the export finishes, download the `.zip` package to a known folder such as **Downloads**.

#### Step 6 — Import the solution into a validation environment
1. Switch the environment selector to the target validation environment.
2. Open **Solutions** again and select **Import solution**.
3. Upload the `.zip` file you exported in Step 5.
4. Review the import summary and select **Import**.
5. Wait for the import job to finish and then open the imported **Woodgrove Customer Service Agent** solution.
6. Confirm the **Woodgrove Scenario Name** environment variable is present.

> **Tip:** If your team has only one environment, ask the facilitator for a shared validation environment rather than importing back into the source environment.

#### Validation
1. In the source environment, confirm the solution list contains **Woodgrove Customer Service Agent** and that the **Current preferred solution** indicator points to it.
2. Open the exported `.zip` file location and confirm the package was downloaded successfully.
3. In the target environment, open the imported solution and confirm the `Woodgrove Scenario Name` environment variable exists.
4. Confirm the imported solution version is `1.0.0.0`.
5. State clearly whether you exported a **Managed** or **Unmanaged** solution and why.

#### Troubleshooting
> **Tip:** If **Solutions** is missing from the navigation, confirm your security role includes solution management rights in the current environment.

> **Tip:** If export fails because of pending dependencies, open the solution details and review whether a required component or connection reference is missing.

> **Warning:** Do not import the managed package back into the same source environment where you plan to continue editing the unmanaged version.

#### Facilitator Notes
1. Emphasize that the solution is the ALM boundary for the workshop, even when participants are still working in a trial environment.
2. The added environment variable is intentional; it gives participants a concrete, low-risk component to validate export and import before later labs add agents and flows.
3. If time is tight, demo the import step once and let participants complete the validation checklist rather than waiting for every import job live.

