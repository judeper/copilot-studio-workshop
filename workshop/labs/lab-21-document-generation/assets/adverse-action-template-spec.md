# Adverse_Action_Notice_Template.docx — content control spec

This spec describes the Word template participants build (or use the prebuilt copy of) in **Lab 21 — Document Generation: Adverse Action Notice**. It is intentionally text-only so the workshop repo does not commit a binary `.docx`. Facilitators who maintain the prebuilt template should keep it aligned with this spec.

## Document layout

1. **Lender header block** — institution name, mailing address, notice date.
2. **Recipient block** — applicant name and mailing address.
3. **Application reference block** — application number, application date, decision (`Denied`), decision date.
4. **Principal reasons for adverse action** — bulleted reasons sourced from the Dataverse loan application record.
5. **Credit reporting agency disclosure** — name, address, and toll-free phone number of the consumer reporting agency that furnished the report used in the decision.
6. **Consumer rights statement** — the FCRA §615(a) plain-language paragraph drafted by the `Draft Adverse Action Statutory Language` prompt.
7. **Right-to-dispute and accuracy statement** — the second paragraph drafted by the same prompt.
8. **Reviewer signature block** — compliance officer name and title, with a signature line.

## Plain Text Content Controls (titles must match exactly)

| # | Control title | Source |
|---|---------------|--------|
| 1 | `ApplicantName` | Dataverse — applicant full name |
| 2 | `ApplicantAddress` | Dataverse — applicant mailing address |
| 3 | `ApplicationNumber` | Flow input |
| 4 | `ApplicationDate` | Dataverse — `wgb_loanapplication` application date |
| 5 | `DecisionDate` | Dataverse — `wgb_loanapplication` decision date |
| 6 | `PrincipalReasons` | Dataverse — denial reasons on the loan application |
| 7 | `CreditBureauName` | Dataverse — credit bureau used |
| 8 | `CreditBureauAddress` | Dataverse — credit bureau mailing address |
| 9 | `CreditBureauPhone` | Dataverse — credit bureau toll-free phone |
| 10 | `ConsumerRightsStatement` | Prompt output (FCRA §615(a) consumer-rights paragraph) |
| 11 | `DisputeRightsStatement` | Prompt output (right-to-dispute paragraph) |
| 12 | `ReviewerName` | Flow input — compliance officer or reviewing loan officer |

## Document footer guidance

Include a fixed footer such as:

```
DRAFT — for compliance officer review only. Do not send to the applicant until compliance approves the wording and confirms ECOA Regulation B timing (notice within 30 days of adverse action).
```

The `DRAFT` watermark and footer are non-negotiable for the workshop template. They make the review intent visible on every page.
