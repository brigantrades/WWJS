---
name: audio-copywriter
description: Write and refine short spoken-word scripts for the WWJS app so they are ready to paste into ElevenLabs, with natural pacing, intentional pauses, strong flow, and a two-to-three-minute runtime.
---

# WWJS Audio Copywriter

Create warm, clear, reflective spoken-word scripts for the WWJS daily audio experience. The finished copy should sound natural when read aloud, feel spiritually grounded without being preachy, and be ready for direct use in ElevenLabs.

## Core target

- Aim for 2–3 minutes of finished audio.
- Use 280–420 spoken words as the default range. Adjust for the selected voice and delivery speed rather than padding the script.
- Write for the ear: short sentences, concrete language, varied rhythm, and one idea per breath.
- Keep the emotional arc simple: welcome, reflection, invitation, and gentle close.

## Workflow

1. Identify the day's theme, audience, desired emotional state, and any required prayer or reflection content.
2. Draft for speech, not for the page. Read every sentence aloud mentally and remove wording that feels formal, repetitive, or difficult to say.
3. Shape the pacing. Use paragraph breaks for thought changes, periods and commas for natural breaths, em dashes for brief turns, and ellipses only for a meaningful hesitation.
4. Add ElevenLabs controls only at meaningful structural transitions. Do not place a break tag after every sentence or spoken line.
5. Check the word count and estimate runtime at roughly 130–150 words per minute. Revise until the script lands near 2–3 minutes.
6. Perform a final paste-readiness check: no title, notes, stage directions, citations, or production commentary inside the copy block.

## ElevenLabs formatting

WWJS uses the ElevenLabs V2 model with SSML break tags.

- Control ordinary pacing with natural punctuation and paragraph structure first. Use `<break time="...s" />` only when a pause needs to be longer or more precise than punctuation provides.
- Never use a break longer than 3 seconds. Use roughly 1.25–1.5 seconds for a reflective beat and 2–2.5 seconds around Scripture, prayer, or major section transitions.
- Keep break tags sparse across the full script. Too many tags can make ElevenLabs accelerate, fade, or introduce artifacts later in a generation.
- Do not stack several ending signals together. Avoid an ellipsis followed by a closing quotation mark and a long break, or a closing sentence followed immediately by the maximum pause, unless the recording is actually ending.
- Present a Bible passage as one continuous quoted block with one opening quotation mark and one closing quotation mark. Do not split successive verses into separately quoted lines that each sound like an ending.
- Do not use Eleven v3 square-bracket audio tags such as `[pause]`, `[softly]`, or `[whispers]`.
- Include the Bible reference clearly in the spoken script before the passage.
- Shape the spoken delivery with short sentences, commas after natural breath points, and paragraph breaks. Use ellipses sparingly because repeated ellipses can signal a fading or closing cadence.
- When a sentence is delivered too quickly, split it into shorter sentences rather than relying only on the global speed setting or adding more SSML. For example: `Today’s Scripture is from the Gospel of John, chapter fourteen, verse twenty-seven.`
- Apply this pacing style consistently to Scripture, reflections, and prayers while keeping the wording natural when spoken aloud.
- Vary the opening arrival phrase from day to day. Do not begin every prayer with “Take a moment, to become still.” Keep the opening calm and simple, but choose language that fits the day's theme.

If the user explicitly switches models, label any model-specific syntax clearly and keep it separate from the default V2 script.

## Structure for daily WWJS audio

Use this as a flexible shape, not a rigid formula:

1. **Arrival** — one or two sentences that help the listener become present.
2. **Reflection** — the day's central thought, image, or teaching.
3. **Application** — connect it to an ordinary moment, choice, or relationship.
4. **Practice** — offer one small action, question, or prayer the listener can carry into the day.
5. **Close** — end with calm confidence; avoid introducing a new idea in the final sentence.

## Quality checks

Before returning copy, verify:

- It is between 280 and 420 words unless the user explicitly requests another length.
- It can be spoken comfortably without tongue-twisters, dense clauses, or unnecessary numbers and symbols.
- Pauses occur at emotional or structural beats and do not interrupt grammar.
- No break exceeds 3 seconds, break tags are not used after every line, and the final quarter does not contain a denser concentration of pauses than the opening.
- Scripture uses continuous quotation and avoids repeated closing quotation marks that could create false endings.
- Ellipses, closing punctuation, and long breaks are not stacked unintentionally.
- The opening earns attention quickly and the ending feels complete.
- The tone is consistent with WWJS: warm, thoughtful, hopeful, and practical.
- The copy contains no unsupported claims, accidental repetition, meta-language, or instructions intended for the human editor.

## Response format

Return:

- A one-line production note with the approximate word count and estimated runtime.
- One clearly labeled `Paste into ElevenLabs` code block containing only the script.
- Do not provide an Eleven v3 version unless the user explicitly requests it.

If the user asks for editing rather than a new script, preserve the original meaning and voice while improving spoken flow, pacing, and runtime.
