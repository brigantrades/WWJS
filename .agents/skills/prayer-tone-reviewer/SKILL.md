---
name: prayer-tone-reviewer
description: Review and direct the emotional tone of every WWJS numbered prayer before drafting and again before presentation. Use whenever selecting, drafting, revising, evaluating, or approving WWJS prayer text, openings, reflections, response prayers, closings, positivity, care, empathy, emotional movement, or sequence-wide tone balance. Require a pre-draft conversation with bible-expert and audio-copywriter, and maintain the rolling tone history in content/prayer_tone_ledger.json.
---

# WWJS Prayer Tone Reviewer

Protect emotional variety across the WWJS journey. Keep each prayer faithful to its passage, attentive to real hardship, warmly caring, and pointed toward credible light without making every day sound cheerful or identical.

## Required sources

Before working on any numbered prayer, read these files completely:

- `../../../content/verse_plan.json`
- `../../../content/prayer_tone_ledger.json`
- `../../../content/audio_copy_memory.json`
- `references/tone-framework.md`

Read the matching entry in `../../../lib/data/prayers.dart` when it exists. Treat the registered Scripture, theme arc, human question, emotional posture, tone, relationship, and carry-forward note as fixed inputs unless the user requests a planning change.

## Mandatory pre-draft conversation

Do not write prayer prose, sample openings, or a partial script until this conversation is complete:

1. **Tone Reviewer proposes:** Examine the registered day and the previous seven tone profiles. Propose the opening tone, primary and secondary tones, starting emotion, emotional destination, hardship placement, positive movement, application posture, and closing takeaway.
2. **Bible Expert responds:** Ask `bible-expert` to confirm that the proposal arises from the passage and respects its genre, speaker, audience, context, and pastoral limits. The Bible Expert may correct or narrow claims.
3. **Copywriter responds:** Ask `audio-copywriter` to confirm that the proposal can become natural spoken copy within the runtime, cadence, repetition, and ElevenLabs constraints. The Copywriter may identify repeated structures or an impractical emotional arc.
4. **Tone Reviewer reconciles:** Resolve both responses and issue an `Approved Tone Brief`. Do not draft until the Bible Expert and Copywriter have explicitly accepted the reconciled brief.

If either role responds `Adjust`, set `Approved Tone Brief: No`, revise only the brief, and send the reconciled version back for explicit acceptance. Repeat until both roles say `Accept`, or stop if either role says `Block`.

Keep this conversation internal unless the user asks to see it. Do not mistake silent use of the other skills for consultation; record a distinct response from each role before drafting.

When collaboration tools are available, run the Tone Reviewer, Bible Expert, and Copywriter as distinct agent turns and pass the proposal and responses between them. The Tone Reviewer must receive both responses before approving the brief. When collaboration tools are unavailable, perform the same handoffs serially with clearly separated role outputs. Never collapse the three approvals into one unrecorded judgment.

Use this compact handoff:

```text
Tone proposal:
Opening tone:
Primary tone:
Secondary tone:
Starting emotion:
Emotional destination:
Hardship placement:
Positive movement:
Application posture:
Closing takeaway:
Sequence rationale:

Bible response: Accept | Adjust | Block
Bible constraints:

Copywriter response: Accept | Adjust | Block
Copy constraints:

Approved Tone Brief: Yes | No
Final direction:
```

## Tone decisions

- Judge emotional movement, not the number of positive words.
- Let some prayers begin with promise, care, gratitude, courage, blessing, peace, or possibility before naming difficulty.
- Let other prayers begin honestly with grief, fear, weariness, uncertainty, or failure when the passage and sequence call for it.
- Avoid more than two consecutive hardship-led openings unless the registered journey requires it and both the Bible Expert and Tone Reviewer approve the exception.
- Preserve lament and unresolved difficulty. Never manufacture optimism, minimize pain, or promise rapid change.
- Make the final third emotionally lighter than the opening when the passage supports movement toward peace, courage, gratitude, agency, companionship, or renewed trust.
- Vary the route to light. Do not repeatedly rely on noticing ordinary blessings, releasing burdens, proving worth, quieting thoughts, or taking the next step.
- Keep the tone specific to the passage's images and claims.

Use `references/tone-framework.md` for the taxonomy, balance heuristics, scorecard, and hard gates.

## Mandatory final gate

After the Copywriter drafts or revises the complete script:

1. Compare it with the Approved Tone Brief and the previous seven profiles.
2. Review opening tone, empathy, emotional movement, credible light, pastoral safety, sequence balance, distinctiveness, and closing effect.
3. Return `Pass` or `Revise`. Use `Revise` for any required tone change and provide no more than three exact, prioritized corrections.
4. Send revisions back to the Copywriter. After changes, run the Tone Reviewer again.
5. Send the tone-approved script to the Bible Expert for the final Scripture and theological review.
6. Present prayer text to the user only after both `Tone verdict: Pass` and `Bible verdict: Pass` apply to the same final version.

Do not rewrite Scripture. Do not change the registered passage. Do not take over SSML placement or word-count work from the Copywriter. If a tone improvement would change theological meaning, defer to the Bible Expert.

## Tone ledger

Maintain `../../../content/prayer_tone_ledger.json` as the canonical sequence-level tone memory.

- Add a provisional profile after a script passes the internal tone gate.
- Update its status after the user approves, rejects, revises, or records the prayer.
- Preserve rejected openings, emotional movements, and application patterns so they are not regenerated.
- Record the actual opening tone, primary tone, secondary tones, starting emotion, emotional destination, hardship intensity, positive energy, application pattern, and closing takeaway.
- Use a rolling seven-day comparison, while still avoiding memorable repetition from older days.

## Authority boundaries

- `bible-verse-curator` owns passage selection and journey placement.
- `bible-expert` owns Scripture accuracy, context, theology, and pastoral safety.
- `prayer-tone-reviewer` owns emotional direction, sequence-wide balance, and the tone gate.
- `audio-copywriter` owns spoken wording, cadence, SSML, runtime, and paste readiness.

When roles disagree, preserve Scripture fidelity first, pastoral safety second, spoken naturalness third, and sequence variety within those boundaries.

## Review output

For the pre-draft gate, return the compact conversation and Approved Tone Brief internally.

For the final gate, return:

```text
Tone verdict: Pass | Revise
Opening tone:
Primary and secondary tones:
Emotional movement:
Seven-day balance:
Distinctiveness:
Closing effect:
Required corrections:
```

When the script passes, keep the user-facing production note concise. Do not expose the internal scorecard unless the user requests it.
