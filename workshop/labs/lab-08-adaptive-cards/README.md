# Copilot Studio Workshop
## Day 1 — Recruit Track
### Lab 08 — Adaptive Cards
⏱ Estimated time: 45 min

#### Overview
In this lab, you will replace a plain-text follow-up with an interactive Adaptive Card so users can request a device directly in the conversation. You will prototype the card visually, capture form values, and prepare the outputs for the automation you build in Lab 09.

![Adaptive card shown in Copilot Studio topic designer](./assets/lab-08-adaptive-card.png)

#### Prerequisites
1. Complete Lab 07 and confirm the `Available devices` topic works.
2. Confirm `Global.VarDevices` is being populated by the SharePoint **Get available devices** action.
3. Open the Adaptive Card Designer at `https://adaptivecards.io/designer/` in a second browser tab.

#### Step-by-Step Instructions
#### Step 1 — Create the request topic shell
1. Open **Contoso Helpdesk Agent** and select the **Topics** tab.
2. Select **+ Add a topic** and choose **From blank**.
3. In the **Name** field, enter `Request device`.
4. In the **Description** field, enter `This topic collects a device request after the user says yes to requesting one of the available devices.`
5. Save the topic shell if your tenant prompts you to do so.

#### Step 2 — Prototype the card in the external designer
1. In the browser tab for `https://adaptivecards.io/designer/`, select **New card**.
2. Add a **TextBlock** element and set the text to `Request a device`.
3. Add an **Input.ChoiceSet** element and label it `Choose a device`.
4. Add an **Input.Text** element with the label `Manager email`.
5. Add a second **Input.Text** element with the label `Additional comments` and enable multiline mode.
6. Add an **Action.Submit** button with the title `Submit request`.
7. Copy the JSON from the **Card Payload Editor**.

> **Tip:** The external designer is the fastest way to understand the card structure before you move the card into Copilot Studio.

#### Step 3 — Add the card to the topic
1. Return to Copilot Studio and open the `Request device` topic.
2. Select **+** on the canvas and choose **Ask with adaptive card**.
3. Click on the **Adaptive Card** node to open its properties panel on the right.
4. Select **Edit adaptive card** to open the built-in **Adaptive card designer**.
5. In the **Card payload editor** at the bottom, paste the JSON from the external designer (or type it directly).
6. Select **Save** and then **Close** to return to the topic canvas. The output variables become visible under the card node.

#### Step 4 — Replace the static device list with dynamic choices
1. Reopen the **Adaptive Card** node and select **Edit adaptive card**.
2. In the **Card payload editor**, click the **JSON card** dropdown at the top of the properties panel and switch to **Formula** mode.
3. Replace the static `choices` array with a formula that loops over `Global.VarDevices.value`.
3. Use the sample formula below as a starting point, then adjust field names if your SharePoint schema differs.

```powerfx
{
  type: "AdaptiveCard",
  version: "1.5",
  body: [
    { type: "TextBlock", text: "Request a device", weight: "Bolder", size: "Medium" },
    {
      type: "Input.ChoiceSet",
      id: "deviceSelectionId",
      label: "Choose a device",
      isRequired: true,
      choices: ForAll(Global.VarDevices.value, { title: If(IsBlank(Model), Title, Model), value: Text(ID) })
    },
    { type: "Input.Text", id: "managerEmailId", label: "Manager email", placeholder: "manager@contoso.com" },
    { type: "Input.Text", id: "commentsId", label: "Additional comments", isMultiline: true }
  ],
  actions: [
    { type: "Action.Submit", title: "Submit request" }
  ]
}
```

4. Save the card and close the editor.
5. Confirm the output variables `deviceSelectionId`, `managerEmailId`, and `commentsId` appear under the node.

#### Step 5 — Route users into the card from the previous topic
1. Return to the **Overview** tab and select **Edit** in the **Details** section.
2. Add the instruction `If the user answers yes when asked whether they want to request a device, use the Request device topic.`
3. Save the instructions.
4. Return to the `Available devices` topic and confirm the yes/no question is still present.

#### Step 6 — Test the adaptive card experience
1. Open the **Test** pane and select **Start new test session**.
2. Enter `I need a laptop` and wait for the **Available devices** topic to return results.
3. Reply `Yes`.
4. Confirm the **Request device** adaptive card appears.
5. Select a device, enter a manager email, add a short note, and submit the card.

![Adaptive card in test pane with device manager and comments fields](./assets/lab-08-card-test.png)

#### Validation
1. Confirm the **Request device** topic exists in the **Topics** list.
2. Confirm the adaptive card node exposes `deviceSelectionId`, `managerEmailId`, and `commentsId` outputs.
3. Confirm a test conversation can move from `Available devices` into `Request device`.
4. Confirm the submitted card returns values instead of a blank response.

#### Troubleshooting
> **Tip:** If the adaptive card editor rejects the formula, save a static JSON version first and then introduce the dynamic `choices` expression in small edits.

> **Tip:** If no devices appear, rerun the `Available devices` topic first so `Global.VarDevices` is populated before the card renders.

> **Tip:** If the card layout looks wrong, prototype again in the external designer at `https://adaptivecards.io/designer/` and then paste the cleaned payload back into Copilot Studio.

#### Facilitator Notes
1. Participants often understand cards faster when they see the external designer first and the in-product card editor second.
2. Reinforce that the card outputs are the bridge to automation in Lab 09.
3. If formula mode is unavailable in a tenant, use static placeholder choices for the live build and explain how the dynamic pattern works conceptually.

