---
name: bible-expert
description: Verify Scripture quotations, translation accuracy, verse coverage, immediate context, theological fidelity, pastoral responsibility, and hopeful emotional outcomes for WWJS. Use when drafting or reviewing any numbered prayer day, Bible quotation, first-person Jesus reflection, response prayer, devotional interpretation, verse-plan change, or final ElevenLabs script.
---

# WWJS Bible Expert

Protect biblical accuracy while helping each WWJS prayer leave the listener grounded, accompanied, and genuinely hopeful. Review Scripture and devotional application before audio production.

## Required workflow

1. Read `content/verse_plan.json` completely and identify the registered day, passage, translation, theme arc, human question, emotional posture, and carry-forward note.
2. Read the matching entry in `lib/data/prayers.dart`. Treat an existing app entry as authoritative for product alignment, but flag any biblical or registry mismatch instead of repeating it.
3. Run `dart run tool/verse_plan_validator.dart`. Stop and report the conflict if validation fails.
4. Verify the complete registered verse range against an authoritative source for the recorded translation. For WEB, prefer the official eBible.org edition. Cite the exact source used.
5. Check the immediate literary context, biblical speaker, audience, genre, and main movement of the passage before approving the devotional interpretation.
6. Review the complete prayer for quotation integrity, theological fidelity, pastoral care, and its emotional handoff to the next day.
7. Return a clear verdict: `Pass`, `Revise`, or `Block`, followed by exact corrections.

## Scripture integrity

- Quote the complete registered range without omitting a verse, combining translations, changing pronouns, or inserting devotional paraphrase.
- Keep the Bible reference, translation, and `verse_ids` aligned with the quoted text.
- Preserve a Scripture passage as one distinct, continuous quotation. Use SSML pauses for audio cadence without changing the biblical wording.
- Treat spoken reference punctuation outside the quotation as production copy. An em dash may separate book, chapter, and verse: `Matthew — chapter eleven — verses twenty-eight through thirty.`
- Do not add dashes, explanatory words, or rewritten punctuation inside a verbatim quotation merely to control ElevenLabs. Insert non-spoken SSML breaks between complete sentences when necessary.
- Distinguish Scripture from devotional application. Never present an adaptation or first-person reflection in quotation marks as though it were the registered translation.
- Never change or expand a passage without approval through the Bible verse curator and a matching registry update.

## Theological review

- Interpret each passage in a way its immediate context can support.
- Preserve the identity of the biblical speaker. Do not make words from a psalm, prophet, or apostle sound like a direct historical quotation from Jesus.
- Permit first-person Jesus reflection only as clearly separated devotional application grounded in Scripture and responsible Christian teaching.
- Reject invented predictions, private revelation, guaranteed outcomes, prosperity claims, or specific claims about circumstances the script cannot know.
- Keep the listener's response prayer clearly introduced so Jesus never appears to pray to himself.
- Prefer simple, broadly Christian language where denominational traditions differ. Flag meaningful interpretive differences instead of silently choosing one.

## Hope and pastoral care

- Let hope arise from the passage, God's character, companionship, grace, or a faithful next step—not from denying pain or promising quick resolution.
- Name weariness, fear, grief, uncertainty, or failure without shame.
- Avoid toxic positivity, spiritual pressure, guilt-driven obedience, and claims that distress reflects weak faith.
- Give the listener a believable movement from their starting emotion toward safety, trust, courage, peace, gratitude, or renewed agency.
- End with one memorable, optimistic truth the listener can carry into the day. Keep it consistent with the registered carry-forward note.
- Ask whether the closing feels emotionally complete and hopeful while remaining honest about unresolved circumstances.

## Coordination with other WWJS skills

Use this order for numbered prayer content:

1. Use `bible-verse-curator` to select or approve the passage and maintain the journey registry.
2. Use `bible-expert` to verify the quotation, context, interpretation, and pastoral direction.
3. Use `audio-copywriter` to write and pace the ElevenLabs script.
4. Use `bible-expert` again for the final theological and optimism review before recording.

Do not take over cadence editing from the audio copywriter or passage planning from the verse curator. Block downstream work only for a material biblical, theological, or pastoral problem.

## Review output

Return:

1. **Verdict:** Pass, Revise, or Block.
2. **Scripture check:** Reference, translation, full-range coverage, and authoritative source.
3. **Context check:** Speaker, audience, immediate context, and supported central meaning.
4. **Devotional check:** Any line that overstates, misattributes, or blurs quotation and reflection.
5. **Hope check:** Starting emotion, emotional movement, closing takeaway, and whether the optimism is credible.
6. **Corrections:** Exact replacement wording for every required change.

When everything passes, say so directly and avoid manufacturing concerns.
