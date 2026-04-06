# Copilot Studio Workshop
## Day 1 — Foundation Track
### Lab 08 — Adaptive Cards
⏱ Estimated time: 45 min

#### Overview
In this lab, you will replace a plain-text follow-up with an interactive Adaptive Card so users can submit a service request directly in the conversation. You will prototype the card visually, capture form values, and prepare the outputs for the automation you build in Lab 09.

![Adaptive card shown in Copilot Studio topic designer](./assets/lab-08-adaptive-card.png)

#### Prerequisites
1. Complete Lab 07 and confirm the `Account Inquiry` topic works.
2. Confirm `Global.VarAccounts` is being populated by the SharePoint **Get active accounts** action.
3. Open the Adaptive Card Designer at `https://adaptivecards.io/designer/` in a second browser tab.

#### Step-by-Step Instructions
#### Step 1 — Create the service request topic shell
1. Open **Woodgrove Customer Service Agent** and select the **Topics** tab.
2. Select **+ Add a topic** and choose **From blank**.
3. In the **Name** field, enter `Submit service request`.
4. In the **Description** field, enter `This topic collects a service request after the user says yes to submitting one from the account inquiry results.`
5. Save the topic shell if your tenant prompts you to do so.

#### Step 2 — Prototype the card in the external designer
1. In the browser tab for `https://adaptivecards.io/designer/`, select **New card**.
2. Add a **TextBlock** element and set the text to `Submit a Service Request`.
3. Add an **Input.Text** element with the label `Customer name`.
4. Add an **Input.ChoiceSet** element and label it `Request type`. Add three choices: `Dispute`, `Address Change`, and `Fee Reversal`.
5. Add an **Input.Text** element with the label `Description` and enable multiline mode.
6. Add a second **Input.ChoiceSet** element and label it `Priority`. Add three choices: `Low`, `Normal`, and `High`.
7. Add an **Action.Submit** button with the title `Submit request`.
8. Copy the JSON from the **Card Payload Editor**.

> **Tip:** The external designer is the fastest way to understand the card structure before you move the card into Copilot Studio.

#### Step 3 — Add the card to the topic
1. Return to Copilot Studio and open the `Submit service request` topic.
2. Select **+** on the canvas and choose **Ask with adaptive card**.
3. Click on the **Adaptive Card** node to open its properties panel on the right.
4. Select **Edit adaptive card** to open the built-in **Adaptive card designer**.
5. In the **Card payload editor** at the bottom, paste the JSON from the external designer (or type it directly).
6. Select **Save** and then **Close** to return to the topic canvas. The output variables become visible under the card node.

#### Step 4 — Build the card with form fields
1. Reopen the **Adaptive Card** node and select **Edit adaptive card**.
2. In the **Card payload editor**, click the **JSON card** dropdown at the top of the properties panel and switch to **Formula** mode.
3. Use the sample formula below as a starting point, then adjust field names if your SharePoint schema differs.

```powerfx
{
  type: "AdaptiveCard",
  version: "1.5",
  body: [
    { type: "TextBlock", text: "Submit a Service Request", weight: "Bolder", size: "Medium" },
    {
      type: "Input.Text",
      id: "customerNameId",
      label: "Customer name",
      isRequired: true,
      placeholder: "e.g. Sarah Johnson"
    },
    {
      type: "Input.ChoiceSet",
      id: "requestTypeId",
      label: "Request type",
      isRequired: true,
      choices: [
        { title: "Dispute", value: "Dispute" },
        { title: "Address Change", value: "Address Change" },
        { title: "Fee Reversal", value: "Fee Reversal" }
      ]
    },
    {
      type: "Input.Text",
      id: "descriptionId",
      label: "Description",
      isMultiline: true,
      placeholder: "Describe the service request details..."
    },
    {
      type: "Input.ChoiceSet",
      id: "priorityId",
      label: "Priority",
      isRequired: true,
      choices: [
        { title: "Low", value: "Low" },
        { title: "Normal", value: "Normal" },
        { title: "High", value: "High" }
      ]
    }
  ],
  actions: [
    { type: "Action.Submit", title: "Submit request" }
  ]
}
```

4. Save the card and close the editor.
5. Confirm the output variables `customerNameId`, `requestTypeId`, `descriptionId`, and `priorityId` appear under the node.

#### Step 5 — Route users into the card from the previous topic
1. Return to the **Overview** tab and select **Edit** in the **Details** section.
2. Add the instruction `If the user answers yes when asked whether they want to submit a service request, use the Submit service request topic.`
3. Save the instructions.
4. Return to the `Account Inquiry` topic and confirm the yes/no question is still present.

#### Step 6 — Test the adaptive card experience
1. Open the **Test** pane and select **Start new test session**.
2. Enter `Show active accounts` and wait for the **Account Inquiry** topic to return results.
3. Reply `Yes`.
4. Confirm the **Submit service request** adaptive card appears.
5. Enter a customer name, select a request type, add a description, choose a priority, and submit the card.

![Adaptive card in test pane with service request fields](./assets/lab-08-card-test.png)

#### Validation
1. Confirm the **Submit service request** topic exists in the **Topics** list.
2. Confirm the adaptive card node exposes `customerNameId`, `requestTypeId`, `descriptionId`, and `priorityId` outputs.
3. Confirm a test conversation can move from `Account Inquiry` into `Submit service request`.
4. Confirm the submitted card returns values instead of a blank response.

#### Troubleshooting
> **Tip:** If the adaptive card editor rejects the formula, save a static JSON version first and then introduce the dynamic expressions in small edits.

> **Tip:** If the card layout looks wrong, prototype again in the external designer at `https://adaptivecards.io/designer/` and then paste the cleaned payload back into Copilot Studio.

> **Tip:** If output variables do not appear, confirm the `id` property is set on each input element in the card JSON.

#### Facilitator Notes
1. Participants often understand cards faster when they see the external designer first and the in-product card editor second.
2. Reinforce that the card outputs are the bridge to automation in Lab 09.
3. If formula mode is unavailable in a tenant, use static placeholder choices for the live build and explain how the dynamic pattern works conceptually.
