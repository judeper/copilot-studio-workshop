# Copilot Studio Workshop
## Day 1 — Recruit Track
### Lab 01 — Introduction to Agents
⏱ Estimated time: 20 min

#### Overview
This lab establishes the concepts used in the rest of the workshop: conversational AI, large language models, retrieval-augmented generation, conversational agents, and autonomous agents. You will use the Contoso IT scenario to decide when each pattern is the right fit before you build anything in Copilot Studio.

> **Note:** This is a discussion-first lab, but it still has concrete participant tasks so you can validate the concepts before moving into hands-on authoring.

![Workshop slide showing conversational versus autonomous agents](./assets/lab-01-agent-types.png)

#### Prerequisites
1. Complete Lab 00 and confirm you can sign in to Copilot Studio.
2. Open a note-taking app such as **OneNote** or **Notepad** for your answers.
3. Join the instructor-led discussion channel in **Microsoft Teams** if your cohort is using one.

#### Step-by-Step Instructions
#### Step 1 — Review the Contoso IT scenario
1. Open this lab and read the **Overview** section aloud or silently.
2. In your note-taking app, create three headings: `Questions`, `Tasks`, and `Triggers`.
3. Under `Questions`, type `What devices are available?`.
4. Under `Tasks`, type `Create a device request and notify my manager.`
5. Under `Triggers`, type `When a new support ticket is created, send an acknowledgment.`

#### Step 2 — Classify the agent experience
1. Next to `What devices are available?`, label the scenario `Conversational agent`.
2. Next to `Create a device request and notify my manager.`, label the scenario `Conversational agent with actions`.
3. Next to `When a new support ticket is created, send an acknowledgment.`, label the scenario `Autonomous agent`.
4. Compare your labels with the facilitator explanation and update your notes if needed.

#### Step 3 — Map the role of the model
1. In your notes, add a fourth heading named `LLM`.
2. Type this sentence under `LLM`: `The model interprets intent, drafts language, and decides what to ask next.`
3. Add a fifth heading named `RAG`.
4. Type this sentence under `RAG`: `The agent retrieves trusted content before it answers so the response is grounded in current business data.`
5. Add a sixth heading named `Actions`.
6. Type this sentence under `Actions`: `Actions let the agent do work in systems such as SharePoint, Outlook, and Power Automate.`

#### Step 4 — Apply the concepts to the workshop flow
1. Open `https://copilotstudio.microsoft.com` in a browser tab.
2. On the home page, identify the **Create** entry point and the **Agents** area.
3. Say or write one example of a knowledge source you will use later, such as `Contoso IT SharePoint site`.
4. Say or write one example of an action you will use later, such as `Create SharePoint item`.
5. Say or write one example of an autonomous trigger you will use later, such as `When a ticket is created`.

#### Validation
1. Explain, in one sentence, the difference between a conversational agent and an autonomous agent.
2. Explain, in one sentence, why RAG is safer than relying on model memory alone for internal policy answers.
3. Identify one place in the Day 1 scenario where an action is required and one place where knowledge grounding is required.
4. If you can answer all three prompts without notes, you are ready for Lab 02.

#### Troubleshooting
> **Tip:** If the terms feel abstract, anchor them to the Contoso IT examples: device lookup is knowledge, device request is an action, and ticket acknowledgment is an autonomous trigger.

> **Tip:** If your group mixes up RAG and actions, remember that RAG helps the agent answer while actions help the agent do.

#### Facilitator Notes
1. Use the Contoso IT story consistently so participants hear the same examples before they build them.
2. Pause after Step 2 and ask one [Maker], one [IT Pro], and one [Developer] participant to explain their classification.
3. Keep the pace brisk; this lab should create shared language, not become a deep AI theory session.

