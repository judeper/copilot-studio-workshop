# Model Baseline

This page is the single source of truth for which Copilot Studio model the workshop targets. When platform model availability changes, update only this file — the labs link here instead of duplicating the guidance.

## Preferred — GPT-5 Chat

GPT-5 Chat (GA in the Copilot Studio model picker since **August 7, 2025**) is the workshop preferred model whenever it is available in the participant's region and tenant. It delivers the strongest instruction-following and reasoning quality across the agent scenarios used in Day 1 and Day 2, handles multimodal inputs (documents and images), and aligns with the demo flows captured in the slide decks. Use it whenever the model picker exposes it.

## GA Fallback — GPT-4.1

When GPT-5 Chat is not available (region rollout, tenant policy, or admin restriction), use **GPT-4.1**. In the Copilot Studio model picker GPT-4.1 is the entry labeled **Default**. It is the GA fallback that the workshop is guaranteed to function on end-to-end, and it is the right baseline for any tenant that has not yet enabled the newer models.

## Multimodal-capable

Both **GPT-5 Chat** and **GPT-4.1** support document and image inputs and are valid choices for the multimodal labs. The workshop's multimodal prompt content (Lab 19) is authored against these two models.

## Optional comparison (Lab 17 only) — Claude Sonnet

**Claude Sonnet** went GA in the Copilot Studio model picker in **March 2026** as a rolling, opt-in rollout. It is offered as an optional comparison model in Lab 17 only. Treat it as a discussion point about provider trade-offs rather than a required step.

Claude Sonnet is **not available in GCC, EU, UK, or EFTA tenants at GA**, and even in supported regions it appears only when the **external-model toggle** in the Power Platform admin center is enabled and the model is allow-listed in the Microsoft 365 admin center. If the toggle is off, the region is not yet enabled, or the model is not visible in the picker, skip the Claude branch and complete Lab 17 with the OpenAI baseline.

## Optional reasoning model — Deep Reasoning (OpenAI o1)

**Deep Reasoning** has been GA in Copilot Studio since **March 2025** and is powered by **OpenAI o1** (not o3). It is intended for reasoning-intensive lending analysis where extra deliberation outweighs latency cost. It is not the workshop baseline; demonstrate it in Lab 17 only as a comparison option for complex prompts.

## Optional cheaper sibling — GPT-5 mini

**GPT-5 mini** is a faster, cheaper sibling of GPT-5. It is a reasonable choice when latency and per-message cost matter more than peak reasoning quality. Use it as a comparison data point in Lab 17 if the picker exposes it; it is not the workshop baseline.

## Do not require

- **GPT-4o** — retired from the picker; do not target it.
- **Preview-only or Experimental variants** — visible in the picker but not part of the workshop baseline. Demonstrate them as discussion only.

## Region and admin dependencies

- Some models are US-region only and may not appear in EU, UK, or APAC tenants on the same day.
- The **external-model toggle** (admin center) gates non-OpenAI models, including Claude. If a participant cannot see Anthropic models, this toggle is the most common cause.
- Tenant-level **DLP policies** and **environment routing** can also remove models from the picker.
- Newer GA models can roll out at different times to different tenants — always confirm against the live picker rather than assuming yesterday's availability still applies.

## Per-prompt content moderation

Per-prompt content moderation in Copilot Studio is a single **Low / Moderate / High** slider that covers all four harm categories collectively (hate, sexual, violence, self-harm). There are no per-category sliders. The workshop default is **Moderate**; switch to **High** for regulated-content demos and **Low** only when intentionally demonstrating moderation thresholds.

---

Labs 06, 17, 19, 20, 24 reference this baseline. When platform model availability changes, update only this file.
