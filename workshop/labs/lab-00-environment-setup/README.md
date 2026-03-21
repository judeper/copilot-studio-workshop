# Copilot Studio Workshop
## Day 1 — Recruit Track
### Lab 00 — Environment Setup
⏱ Estimated time: 45 min

#### Overview
In this lab, you will prepare the shared Contoso IT workshop scenario used throughout Day 1. You will verify participant prerequisites, activate Copilot Studio access, select the correct Power Platform environment, and create the SharePoint site and lists that later labs use for grounding, device requests, and automated ticket handling.

> **Note:** If your organization already provides a Microsoft 365 tenant, a Power Platform environment, and Copilot Studio access, complete the validation steps first and then skip directly to the SharePoint setup section.

![Copilot Studio home page with environment selector and create options](./assets/lab-00-copilot-studio-home.png)

#### Prerequisites
1. Confirm you have a work or school account that can sign in to Microsoft 365. Personal Microsoft accounts are not supported.
2. Confirm you can open `https://copilotstudio.microsoft.com` in Microsoft Edge or Google Chrome.
3. [Maker] Confirm you can create resources in a Power Platform environment.
4. [IT Pro] Confirm self-service trial sign-up is allowed in the tenant, or have an approved alternative environment ready.
5. [Developer] Have a second browser profile or InPrivate window available so you can test sign-in prompts without affecting your daily tenant session.
6. Keep this lab open and record the values you use for the tenant name, environment name, and SharePoint site URL.

#### Step-by-Step Instructions
#### Step 1 — Verify tenant access
1. Open a browser tab, go to `https://www.office.com`, and select **Sign in**.
2. Enter your workshop account in the **Email, phone, or Skype** field, select **Next**, enter your password, and complete any multifactor prompt.
3. Select the **App launcher** in the upper-left corner and confirm you can see Microsoft 365 apps such as **Teams**, **SharePoint**, and **Power Apps**.
4. If you are using a new tenant, open **Admin** from the app launcher, confirm the tenant domain shown in the header, and note it for later validation.

#### Step 2 — Start or confirm Copilot Studio access
1. In a new browser tab, go to `https://aka.ms/TryCopilotStudio` and sign in with the same workshop account.
2. Select **Start free trial** if the page offers a trial, or select **Open Copilot Studio** if access is already provisioned.
3. Wait for the confirmation screen, then open `https://copilotstudio.microsoft.com`.
4. In Copilot Studio, confirm the page loads without an access error and that the top bar shows your signed-in account.

> **Tip:** If you receive a self-service sign-up error, capture the exact message and switch to the troubleshooting section before continuing.

#### Step 3 — Create or confirm a Power Platform development environment
1. Go to `https://aka.ms/PowerAppsDevPlan` and sign in with the same workshop account.
2. Select **Start free** on the **Power Apps Developer Plan** page if you do not already have a developer environment.
3. After the sign-up completes, open `https://make.powerapps.com`.
4. In the environment selector in the upper-right corner, open the dropdown and select your developer environment, such as **Adele Vance's environment**.
5. Return to `https://copilotstudio.microsoft.com`, open the environment selector, and select the same developer environment.
6. Record the exact environment name because you will reuse it in every Day 1 lab.

#### Step 4 — Enable authoring and publishing permissions
1. [IT Pro] Open `https://admin.microsoft.com` and select **Teams & groups** > **Active teams & groups**. Alternatively, use `https://entra.microsoft.com` > **Groups** > **All groups** > **New group** if you manage groups through Microsoft Entra ID. Commercial tenants may also use `https://admin.cloud.microsoft` as an alternative entry point.
2. Select the **Security groups** tab, select **Add a security group**, and create a group named `AgentCreators`.
3. Open the new `AgentCreators` group, select **Members**, select **View all and manage members**, and add the participant accounts.
4. Open `https://admin.powerplatform.com`, select **Manage**, then select **Tenant settings**.
5. Scroll to **Copilot Studio authors**, select the **Edit** pencil, choose the `AgentCreators` security group, and select **Save**.
6. [Maker] Sign out and back in to Copilot Studio if the new permissions do not appear immediately.

> **Warning:** Trial environments may allow authoring but block publishing. Complete this step before Lab 11 if you want participants to finish the Teams publishing exercise.

#### Step 4b — Confirm Copilot Studio credits are available
1. [IT Pro] Open `https://admin.powerplatform.com` and select your workshop environment.
2. In the environment details, look for a **Billing** or **Licensing** section.
3. Confirm that one of the following is in place:
   - **Pay-as-you-go:** An Azure subscription is linked to the environment for usage-based billing. To set this up, select **Billing** > **Link Azure subscription**, choose your subscription, and select **Save**.
   - **Capacity pack:** A Copilot Studio capacity pack is assigned to the tenant and the environment has access to the pooled credits.
   - **Trial:** A Copilot Studio trial is active and has not expired.
4. To verify, open Copilot Studio, create a quick test agent, and send a message in the **Test** pane. If you receive a response without a capacity or licensing error, credits are working.

> **Warning:** Without Copilot Studio credits, agent authoring may work but advanced actions, connectors, triggers, and publishing will fail. Set up billing before continuing to Lab 06.

#### Step 5 — Create the Contoso IT SharePoint site
1. In Microsoft 365, select the **App launcher**, then select **SharePoint**.
2. On the SharePoint start page, select **+ Create site**.
3. In the site type dialog, select **Team site**.
4. In the template gallery, select **IT help desk** and then select **Use template**.
5. In the **Site name** field, enter `Contoso IT`.
6. In the **Site description** field, enter `Copilot Studio workshop data source`.
7. In the **Site address** field, enter `ContosoIT` or the nearest available variation.
8. Leave the **Language** field set to **English** and select **Create site**.
9. On the **Add members** screen, add workshop participants if required, then select **Finish**.
10. When the site opens, copy the site URL from the browser address bar and save it in your notes.

![SharePoint team site creation form with Contoso IT values](./assets/lab-00-sharepoint-site.png)

#### Step 6 — Prepare the Devices list for later labs
1. In the **Contoso IT** site, select **Site contents** and open the **Devices** list.
2. Scroll to the far right of the list header, select **+ Add column**, choose **Hyperlink**, enter `Image` in the **Name** field, and select **Save**.
3. Select **New** and create at least four sample items using the values below, keeping **Status** set to `Available` for at least three items.
4. Enter values such as `Surface Laptop 13`, `Surface Laptop 15`, `Surface Pro 12`, and `Surface Studio` in the **Title** field.
5. Populate the remaining fields with realistic values for **Manufacturer**, **Model**, **Asset Type**, **Color**, **Serial Number**, **Purchase Date**, **Purchase Price**, and **Order #**.
6. Open the **Status** column settings and confirm the choices include `Available` and `Requested`. Add `Requested` if it is missing, because Lab 09 uses this value when processing device request flows.
7. If your tenant allows public image links, paste a valid PNG or JPG URL into the new **Image** column; otherwise leave the field blank.
8. Save each item and confirm the list displays the rows.

> **Tip:** If your SharePoint template did not provision a **Devices** list or the columns differ from the steps above, select **New** > **List** > **Blank list**, name it `Devices`, and add the columns manually: Title (default), Manufacturer (Text), Model (Text), Asset Type (Text), Color (Text), Serial Number (Text), Purchase Date (Date), Purchase Price (Currency), Order # (Text), Status (Choice with values Available, Requested, Retired), and Image (Hyperlink).

#### Step 7 — Prepare the Tickets list for later labs
1. Return to **Site contents** and open the **Tickets** list.
2. Select **New** and create a sample ticket with **Title** set to `VPN connection issue`.
3. Enter `User cannot connect after password change` in the **Description** field.
4. Set **Priority** to `Normal`, save the item, and confirm the ticket appears in the list.
5. Keep the **Tickets** list available because Lab 10 uses it for event triggers.

#### Validation
1. Open `https://copilotstudio.microsoft.com` and confirm the correct workshop environment appears in the environment selector.
2. Confirm the **Contoso IT** SharePoint site opens successfully from the saved site URL.
3. Confirm the **Devices** list contains at least four items and the **Image** column is visible.
4. Confirm the **Tickets** list contains at least one sample ticket.
5. Record these four values in your notes: tenant domain, environment name, SharePoint site URL, and one sample device title.

#### Troubleshooting
> **Tip:** If Copilot Studio opens in the wrong environment, select the environment name in the upper-right corner and switch back to your developer environment before creating any agents.

> **Tip:** If the Power Apps Developer Plan does not create an environment, wait five minutes, refresh `https://make.powerapps.com`, and check the environment selector again.

> **Tip:** If SharePoint template provisioning is slow, keep the page open until the site home page loads; creating the site twice often causes duplicate cleanup work.

> **Warning:** If you cannot start the Copilot Studio trial because self-service sign-up is disabled, escalate to your tenant admin and ask for Copilot Studio access or a pre-provisioned environment.

#### Facilitator Notes
1. Complete this pre-event checklist at least one business day before delivery: verify tenant access, verify Copilot Studio trial or paid capacity, verify Power Platform admin access, verify a publishing-capable environment, verify Copilot Studio credits (pay-as-you-go Azure billing, capacity pack, or active trial), and verify SharePoint site creation permissions.
2. Pre-create at least one backup environment and one backup SharePoint site so participants can continue if tenant provisioning fails.
3. Decide whether participants will use their own trial tenants or a shared customer tenant, then communicate the login pattern before the event starts.
4. Prepare a short slide or whiteboard note with the standard values `Contoso IT`, `Contoso Helpdesk Agent`, and `AgentCreators` so naming stays consistent.
5. Ask one [IT Pro] helper to stay available during the first 30 minutes for licensing, MFA, and security-group issues.

