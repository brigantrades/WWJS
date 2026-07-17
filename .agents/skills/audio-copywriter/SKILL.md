---
name: audio-copywriter
description: Write and refine short spoken-word scripts for the WWJS app so they are ready to paste into ElevenLabs, with natural pacing, intentional pauses, strong flow, and a 2:30-to-2:45 runtime.
---

# WWJS Audio Copywriter

Create warm, clear, reflective spoken-word scripts for the WWJS daily audio experience. Jesus is the devotional speaker: he addresses the listener directly in first person. The finished copy should sound natural when read aloud, feel spiritually grounded without being preachy, and be ready for direct use in ElevenLabs.

## Core target

- Aim for 2:30–2:45 of finished audio at the current ElevenLabs speed of 0.86.
- Use 335–370 spoken words as the default range, and treat 375 words as a ceiling unless a measured generation proves the selected voice can stay within the target. Preserve reflective pauses and remove repeated ideas before compressing the cadence.
- Use measured production audio to refine estimates. Day 9 established the current baseline: about 420 spoken words with the approved pauses rendered at 3:05 at speed 0.86.
- Write for the ear: short sentences, concrete language, varied rhythm, and one idea per breath.
- Keep the emotional arc simple: welcome, reflection, invitation, and gentle close.

## Opening voice and style

Open every daily script as a direct invitation from Jesus into prayer, not merely as a breathing or relaxation instruction. The first one to three sentences should feel reverent, warm, and personal.

- Jesus speaks as `I`, `me`, and `my`, and addresses the listener as `you`. Avoid an outside narrator speaking about Jesus in the third person.
- Name what is happening: the listener is beginning prayer, opening their heart, becoming present with Jesus, surrendering this time, or welcoming the Holy Spirit's guidance.
- Connect the opening image to the registered theme for the day. Appropriate starting movements include divine presence, the Holy Spirit, gratitude and surrender, the light of Christ, quiet trust, hope, mercy, or rest.
- Begin every finished script with `<break time="1.2s" />` on the first line so playback does not begin speaking immediately. This lead-in pause is mandatory and comes before all spoken words.
- Create a fresh opening sentence for every day. Do not use `As we begin this prayer...` as a recurring template.
- Compare the opening with the previous seven days whenever those scripts are available. Do not repeat the same sentence structure, central verb, or arrival image on consecutive days.
- Vary the opening movement while preserving the same calm flow. Options include a direct invitation, a theme-specific image, a reassuring statement, a gentle question, gratitude, surrender, or a simple call to rest or draw near.
- Always place `<break time="1.5s" />` immediately after the first spoken sentence. This opening pause is mandatory.
- Keep the opening speakable and grounded. Avoid piling up abstract spiritual phrases, making claims that go beyond the day's Scripture, or implying that God's presence depends on the listener producing the right emotional state.
- A breath or stillness invitation may follow the prayerful opening, but it should not be the entire opening by itself.
- Whenever the listener is prompted to take a slow or deep breath in, write the full inhale-and-exhale sequence: `Take a slow breath in.`, then `<break time="2s" />`, then `And gently breathe out.` Never prompt an inhale without also guiding the exhale.

## Voice of Jesus

The devotional guidance, reflection, application, practice, and closing must remain in the first-person voice of Jesus.

- Write `Stay close to me. I am with you in this moment.` rather than `Stay close to Jesus. He is with you in this moment.`
- Do not alternate between narrator voice and Jesus' voice inside the reflection.
- Ground everything Jesus says in the registered passage and responsible Christian teaching. Do not invent specific promises, predictions, private revelation, or claims about the listener's circumstances.
- Introduce the Bible reference clearly, then keep the biblical passage as a distinct continuous quotation. Do not silently rewrite Scripture to make every biblical speaker sound like Jesus.
- When including the listener's response prayer, mark the transition clearly, such as `If you are ready, answer me in your heart:`. The response may then address Jesus directly so it is not mistaken for Jesus praying to himself.
- After the response prayer, return clearly to Jesus' first-person voice for the closing assurance or invitation.
- End every finished script with a 1.5-second pause followed by `Amen.` as the final spoken word: `<break time="1.5s" />` then `Amen.`

## Day and verse verification

Before drafting a numbered day:

- Read the matching entry in `content/verse_plan.json`.
- Run `dart run tool/verse_plan_validator.dart` and stop if the registry contains a duplicate or overlapping verse.
- Confirm the day, title, passage, translation, theme arc, human question, emotional posture, and carry-forward note.
- If the day already exists in `lib/data/prayers.dart`, treat the app entry as authoritative and report any mismatch with the registry before writing.
- Do not substitute, expand, or reuse a different passage without approval from the Bible verse curator workflow and an updated registry entry.
- Verify that the quoted Scripture covers the complete registered verse range in the registered translation. A reference such as Romans 12:1–2 must not be represented only by words from verse 2.
- Check quoted wording against an authoritative source for the registered translation before returning the script. Do not rely on memory or an earlier generated script.
- Use `bible-expert` to approve the final Scripture block, devotional interpretation, pastoral responsibility, and hopeful takeaway before presenting a numbered-day script as finished.
- Keep verbatim Scripture and devotional paraphrase distinct. If wording is adapted into Jesus' first-person voice, introduce it explicitly as a reflection or paraphrase and do not place it in quotation marks as though it were the registered translation.
- Never change biblical pronouns or speakers inside a verbatim quotation to make the passage fit Jesus' first-person narration.

## Workflow

1. Identify the day's registered theme, audience, desired emotional state, opening spiritual focus, and any required prayer or reflection content. Review recent openings and choose a different sentence shape and image.
2. Draft for speech, not for the page. Read every sentence aloud mentally and remove wording that feels formal, repetitive, or difficult to say.
3. Shape the pacing. Use paragraph breaks for thought changes, periods and commas for natural breaths, em dashes for brief turns, and ellipses only for a meaningful hesitation.
4. Add a small number of short processing pauses within the reflection as well as longer pauses at meaningful structural transitions. Do not place a break tag after every sentence or spoken line.
5. Check the word count against the current 335–370-word production target. Revise until the script is expected to land between 2:30 and 2:45 at speed 0.86, then use the measured ElevenLabs result to recalibrate future drafts.
6. Perform a final paste-readiness check: no title, notes, stage directions, citations, or production commentary inside the copy block.

## ElevenLabs formatting

WWJS uses the ElevenLabs V2 model with SSML break tags.

### Standard WWJS cadence

Use the approved Day 1 pacing as the default cadence for future scripts:

- Place `<break time="1.2s" />` before the first spoken line of every script.
- Place `<break time="1.5s" />` directly after the first spoken line before continuing the opening.
- Let short paragraphs, periods, and sentence length establish the ordinary rhythm. Do not place an SSML break after every thought.
- Use approximately 1–1.5 seconds before Scripture and 2 seconds after the complete Scripture quotation.
- Keep Scripture as one continuous quotation without internal SSML by default. Add an internal pause only when an audio test shows that the passage is rushed.
- Use approximately 2 seconds before the listener's response prayer or another major reflective transition.
- Use `<break time="1.5s" />` immediately before the final `Amen.`.
- Whenever the script guides a slow or deep inhale, follow it with `<break time="2s" />` and the spoken instruction `And gently breathe out.`
- Read the reflection as Jesus speaking gently to one person. Prefer natural paragraph-level breathing room over frequent sub-second pauses.

- Control ordinary pacing with natural punctuation and paragraph structure first. Use `<break time="...s" />` only when a pause needs to be longer or more precise than punctuation provides.
- Never use a break longer than 3 seconds. Use roughly 1.25–1.5 seconds for a reflective beat and 2–2.5 seconds around Scripture, prayer, or major section transitions.
- Use explicit pauses mainly at section transitions and major emotional turns. Add a short internal pause only when a real audio test shows that punctuation is insufficient.
- Keep structural pauses around 1–2 seconds. The required inhale-to-exhale pause is exactly 2 seconds.
- Keep break tags intentional across the full script. Too many tags can make ElevenLabs accelerate, fade, or introduce artifacts later in a generation.
- Never stack break tags or place them after every sentence. Let punctuation carry ordinary speech and reserve explicit pauses for words the listener needs time to process.
- Do not stack several ending signals together. The required 1.5-second pause before `Amen.` should be the only explicit break at the ending and should not follow another break tag.
- Present a Bible passage as one continuous quoted block with one opening quotation mark and one closing quotation mark. Do not split successive verses into separately quoted lines that each sound like an ending.
- Do not use Eleven v3 square-bracket audio tags such as `[pause]`, `[softly]`, or `[whispers]`.
- Include the Bible reference clearly in the spoken script before the passage.
- Shape the spoken delivery with short sentences, commas after natural breath points, and paragraph breaks. Use ellipses sparingly because repeated ellipses can signal a fading or closing cadence.
- When a sentence is delivered too quickly, split it into shorter sentences rather than relying only on the global speed setting or adding more SSML. For example: `Today’s Scripture is from the Gospel of John, chapter fourteen, verse twenty-seven.`
- Apply this pacing style consistently to Scripture, reflections, and prayers while keeping the wording natural when spoken aloud.
- Keep the approved cadence consistent while making the opening language distinct for every day. Do not begin with a generic breathing instruction alone or reuse `As we begin this prayer...`. Keep the opening calm, personal, explicitly prayerful, connected to the day's theme, and in Jesus' first-person voice.

If the user explicitly switches models, label any model-specific syntax clearly and keep it separate from the default V2 script.

## Structure for daily WWJS audio

Use this as a flexible shape, not a rigid formula:

1. **Prayerful arrival** — one to three sentences in which Jesus directly welcomes the listener and helps them become present with him.
2. **Scripture** — Jesus introduces the reference, followed by the complete registered passage in the registered translation as a distinct, unaltered quotation.
3. **Reflection** — Jesus develops the day's central thought or image in first person.
4. **Application** — Jesus connects it to an ordinary moment, choice, or relationship.
5. **Response** — Jesus invites one small action, question, or clearly marked listener prayer.
6. **Close** — Jesus ends with calm first-person assurance or invitation, introduces no new idea, pauses for 1.5 seconds, and closes with `Amen.`

## Quality checks

Before returning copy, verify:

- It is between 335 and 370 words, and no more than 375 words, unless the user explicitly requests another length or a measured generation supports a different count.
- It can be spoken comfortably without tongue-twisters, dense clauses, or unnecessary numbers and symbols.
- No paragraph contains several process-worthy ideas that ElevenLabs is likely to rush together; split those ideas into short spoken lines before adding more SSML.
- Explicit pauses follow the approved Day 1 pattern: structural transitions carry most of the SSML, while punctuation and paragraphs carry ordinary pacing.
- No break exceeds 3 seconds, break tags are not used after every line, and the final quarter does not contain a denser concentration of pauses than the opening.
- Scripture uses continuous quotation and avoids repeated closing quotation marks that could create false endings.
- The Scripture block has been checked against an authoritative source, covers the complete registered range, and contains no devotional paraphrase presented as a verbatim translation.
- Ellipses, closing punctuation, and long breaks are not stacked unintentionally.
- The opening clearly enters prayer in Jesus' first-person voice, fits the day's theme, and differs in wording, sentence shape, and central image from recent days.
- The script begins with `<break time="1.2s" />` before any spoken words.
- The first spoken sentence is followed immediately by `<break time="1.5s" />`.
- Every slow or deep inhale is followed by `<break time="2s" />` and an explicit instruction to breathe out.
- All devotional guidance stays in Jesus' first-person voice; Scripture and the listener's response prayer are clearly marked so the speaker never becomes ambiguous.
- The final spoken line is exactly `<break time="1.5s" />` followed by `Amen.`, with no other ending pause stacked beside it.
- The tone is consistent with WWJS: warm, thoughtful, hopeful, and practical.
- The copy contains no unsupported claims, accidental repetition, meta-language, or instructions intended for the human editor.

## Response format

Return:

- A one-line production note with the approximate word count and estimated runtime.
- One clearly labeled `Paste into ElevenLabs` code block containing only the script.
- Do not provide an Eleven v3 version unless the user explicitly requests it.

If the user asks for editing rather than a new script, preserve the original meaning and voice while improving spoken flow, pacing, and runtime.
