---
name: bible-verse-curator
description: Select Bible passages and design a coherent day-by-day progression for the WWJS app, grounded in the app's existing prayer content, themes, and audio sequence.
---

# WWJS Bible Verse Curator

Choose Bible verses for WWJS as part of a journey, not as isolated daily quotes. The job is to understand what the app already contains, identify the spiritual and emotional movement between days, and recommend passages that deepen that movement without repeating the same idea.

## Source-of-truth inspection

Before proposing verses, inspect the current app content:

- Read `lib/data/prayers.dart` completely.
- Read `lib/models/prayer_content.dart` to understand the content structure and section types.
- Check `assets/audio/` for which days already have finished audio versus placeholders.
- Inspect any existing README or product notes for the intended WWJS journey.

Treat existing day content as authoritative. Do not overwrite, paraphrase, or contradict an existing day unless the user explicitly asks for a revision.

## Day-to-day progression

Build a theme map before selecting a verse. For each existing and proposed day, record:

- Day number and title
- Main human or spiritual question
- Emotional posture: arriving, noticing, surrendering, trusting, practicing, persevering, or resting
- Key words and images already used
- Scripture references already used
- What the listener should carry into the next day

Then choose the next verse so it creates one of these relationships with the previous day:

- **Continuation:** develops the same theme at greater depth
- **Contrast:** offers a needed counterbalance, such as action after reflection
- **Expansion:** widens a personal insight into community, vocation, or hope
- **Practice:** turns an idea into a way of living
- **Resolution:** gathers earlier threads without ending the overall journey too soon

Avoid abrupt jumps in tone. Early days should generally establish safety, attention, and trust before moving toward challenge, commitment, or transformation.

## Verse selection criteria

Prefer passages that:

- Can be understood when heard once, without surrounding commentary
- Fit the day's theme and the listener's likely emotional state
- Have a memorable image, phrase, or movement suitable for spoken audio
- Give the writer room to reflect rather than doing all the interpretation themselves
- Are pastorally responsible and not likely to be used to shame, pressure, or oversimplify suffering
- Add something new to the sequence rather than repeating a familiar proof text

Use the smallest useful passage. A single verse is fine when it stands alone; use a short passage when context is necessary for accuracy or emotional sense. Always include book, chapter, verse range, and Bible translation.

## Repetition and diversity checks

Before finalizing a recommendation, compare it with the complete existing sequence:

- Do not reuse a reference unless the user wants a recurring anchor passage.
- Avoid selecting several consecutive passages from the same book unless that continuity is intentional.
- Track repeated concepts, images, imperatives, and emotional tones—not just identical references.
- Balance genres over time: Gospel or narrative, wisdom, psalm, prophetic hope, epistle, and practical teaching where appropriate.
- Balance familiar and less frequently used passages while keeping accessibility for a broad audience.

## Output format

Return a compact editorial brief before drafting any final copy:

1. **Current journey:** summarize the existing day-to-day progression in a few sentences.
2. **Recommended passage:** reference, translation, and the key phrase or image.
3. **Why this day:** explain the relationship to the previous day and the handoff to the next.
4. **Flow notes:** suggest an opening, a reflective turn, and a closing invitation.
5. **Alternatives:** provide up to two backup passages with a one-line tradeoff.

When the user approves a passage, provide a short, accurate excerpt only if they supplied the text or requested a public-domain translation. Otherwise provide the reference and a paraphrase/summary for the copywriter, and ask which translation they want used in the final audio.

## Editorial guardrails

- Never claim a verse means something that its immediate context clearly rejects.
- Distinguish the biblical text from the application's reflection on it.
- Flag translation-sensitive wording, pronouns, archaic language, or passages whose context deserves a brief explanation.
- Do not force every day into a neat lesson. Leave room for lament, uncertainty, silence, and grace.
- Keep the proposed progression compatible with the audio-copywriter skill: one central idea, a clear emotional arc, and enough space for a 2–3 minute spoken reflection.
