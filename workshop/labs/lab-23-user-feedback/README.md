# Copilot Studio Workshop

## Day 2 — Enterprise Track

### Lab 23 — User Feedback

⏱ Estimated time: 20 min (core) — Part 5 is optional and can be skipped if time-constrained

#### Overview
In this lab, you will close the loop on the Loan Processing Agent scenario by collecting post-conversation feedback. You will confirm the built-in reaction experience, add a custom adaptive card for dissatisfied users, and review where both reaction data and card responses can be inspected after a conversation.

#### Prerequisites
1. [Maker] Complete **Lab 13** and confirm that **Collect user reactions to agent messages** is enabled.
2. [Maker] Publish **Loan Processing Agent** if you want to test in Microsoft Teams or another external channel.
3. [Maker] Open **Loan Processing Agent** in Copilot Studio with permission to edit system topics.

#### Step-by-Step Instructions
#### Part 1 — Confirm built-in reactions are enabled
1. Open **Loan Processing Agent** and select **Settings**.
2. Locate the **User feedback** or **Generative AI** settings section.
3. Confirm that **Collect user reactions to agent messages** is turned **On**.
4. Save the settings if you made any changes.

#### Part 2 — Create the dissatisfied-feedback adaptive card topic
1. Select **Topics** and then select **Add a topic**.
2. Select **From blank**.
3. Name the topic `Capture Dissatisfied Feedback`.
4. Change the trigger to **It's redirected to**.
5. Add an **Ask with adaptive card** node.
6. Open the card designer, clear the default JSON, and paste the JSON below.

```json
{
  "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
  "type": "AdaptiveCard",
  "version": "1.5",
  "body": [
    {
      "type": "TextBlock",
      "text": "Thanks for the rating. What should we improve in the Loan Processing Agent experience?",
      "wrap": true,
      "weight": "Bolder"
    },
    {
      "type": "Input.ChoiceSet",
      "id": "reasonId",
      "style": "expanded",
      "choices": [
        { "title": "The answer was incomplete", "value": "Incomplete" },
        { "title": "The answer was inaccurate", "value": "Inaccurate" },
        { "title": "The answer was not relevant", "value": "Irrelevant" },
        { "title": "The workflow was confusing", "value": "Confusing" }
      ]
    },
    {
      "type": "Input.Text",
      "id": "commentsId",
      "placeholder": "Add a short comment for the lending team",
      "isMultiline": true
    }
  ],
  "actions": [
    {
      "type": "Action.Submit",
      "title": "Send feedback"
    }
  ]
}
```

7. Save the card.
8. Review the output variables and note the generated values for `reasonId` and `commentsId`.
9. Save the topic.

![Adaptive card for dissatisfied feedback](./assets/lab-23-feedback-card.png)

#### Part 3 — Redirect low CSAT ratings to the feedback card
1. Open **System** topics and select **End of Conversation**.
2. Add a **Topic**-scoped numeric variable named `VarCSATRating` and initialize it to `0`.
3. Open the **CSAT Question** node properties and store the response in `Topic.VarCSATRating`.
4. Add a **Condition** node after the CSAT question.
5. Configure the condition to check whether `VarCSATRating` is **greater than or equal to** `3`. This means scores of 3, 4, or 5 proceed normally through the main branch. Scores of 1 or 2 fall into the **All other conditions** branch and will be redirected to the dissatisfied feedback card.
6. In the **All other conditions** branch, add **Go to another topic**.
7. Select `Capture Dissatisfied Feedback`.
8. Save the **End of Conversation** system topic.

#### Part 4 — Test the feedback experience
1. Start a **New test session**.
2. Ask the Loan Processing Agent any normal lending-related question.
3. Type `end conversation` to trigger the end-of-conversation system flow.
4. Confirm the end-conversation prompts.
5. Select a **1-star** or **2-star** CSAT score.
6. Complete the adaptive card and submit it.
7. *Optional — skip if time-constrained.* Start a second short session and provide a positive rating so you can compare both paths.

#### Part 5 — Review the results (Optional — skip if time-constrained)
1. Open the **Analytics** tab for **Loan Processing Agent**.
2. Scroll to **Satisfaction** and open **Reactions** details to review built-in thumbs data if you collected any during testing.
3. Note that the custom adaptive card responses are not automatically summarized in the same chart.
4. Open the relevant session in the **Activity** tab, then inspect the adaptive card submission values for `reasonId` and `commentsId`.
5. [Developer] If you need structured reporting later, create a follow-up flow or table to persist the adaptive card outputs in Dataverse.

![Loan Processing Agent analytics and transcript review](./assets/lab-23-feedback-review.png)

> Tip: Built-in reactions are ideal for quick trend reporting. Adaptive cards are better when you want richer, targeted feedback from users who had a poor experience.

#### Validation
1. Built-in reactions remain enabled on **Loan Processing Agent**.
2. The `Capture Dissatisfied Feedback` topic exists and contains the adaptive card.
3. The **End of Conversation** topic routes low CSAT scores to the custom topic.
4. A low CSAT test shows the feedback card.
5. *(Optional, only if Part 5 was completed.)* You can review built-in reactions in **Analytics** and inspect adaptive card responses in the **Activity** tab.

#### Troubleshooting
1. If the adaptive card does not appear, confirm that the **End of Conversation** topic condition routes low scores to the custom topic.
2. If the card renders incorrectly in Teams, keep the schema at **Adaptive Card 1.5** and retest.
3. If no reaction analytics appear, wait a few minutes and refresh the **Analytics** page.
4. If the activity record is hard to inspect, repeat the test with a short conversation so the card submission is easy to find.

#### Facilitator Notes
1. Explain clearly that built-in reactions and custom adaptive card feedback solve different reporting needs.
2. Demo one negative CSAT path live so participants can see the redirect happen.
3. If time allows, discuss how to persist the adaptive card outputs into a Dataverse table for long-term analysis.
4. **Compressed in v2 to absorb Module 13b and the Lab 14 Component Collections extension.** The core lab is now Parts 1–4 (low-CSAT happy path only), targeting ~20 minutes. Part 5 (Analytics and Activity review) and the positive-rating comparison test in Part 4 step 7 are explicitly optional. The trimmed steps remain in the README for facilitators who have headroom or for self-paced study.

