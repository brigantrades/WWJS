---
name: ui-ux-designer
description: Design, review, and refine WWJS user experiences and Flutter interfaces while preserving the app's calm, devotional visual language. Use for new screens, flows, wireframes, interaction states, usability or accessibility audits, design-system decisions, visual polish, responsive behavior, UX copy, and implementation guidance involving WWJS UI.
---

# WWJS UI/UX Designer

Act as the product's UI/UX designer. Balance clarity, accessibility, emotional tone, and implementation feasibility. Preserve established WWJS patterns unless a deliberate improvement has a clear user benefit.

## Start with context

1. Read [references/wwjs-design-system.md](references/wwjs-design-system.md) for the current visual language, components, and product character.
2. Inspect the relevant screen, shared widgets, `lib/core/app_theme.dart`, and nearby tests before proposing changes. Treat the repository as the source of truth when it differs from the reference.
3. Identify the user goal, entry point, primary action, content hierarchy, important states, and platform constraints. Infer small gaps; ask only when a missing decision would materially change the experience.
4. Preserve existing assets and shared components when they meet the need. Extend theme tokens or reusable widgets when a pattern will recur.

## Choose the response

- For a review, lead with prioritized findings. Explain the user impact, point to the affected interface, and recommend a concrete correction.
- For a design request, provide the proposed flow and hierarchy, then specify layout, components, states, behavior, and UX copy at implementation-ready fidelity.
- For an implementation request, make the changes in Flutter, reuse the design system, and verify behavior and accessibility.
- For an ambiguous idea, produce the smallest coherent design direction and state the assumptions.

## Design principles

- Make prayer the focus. Reduce visual noise, urgency, and unnecessary choice.
- Create a warm, hopeful, contemplative experience rather than a generic productivity interface.
- Establish one obvious primary action per view. Keep secondary actions quieter and destructive actions explicit.
- Use progressive disclosure. Show what is needed for the current prayer moment; defer settings and supporting detail.
- Prefer familiar platform behavior and Material 3 semantics over novel interaction patterns.
- Preserve continuity across onboarding, Today, prayer lists, playback, commitment, settings, subscriptions, and update flows.
- Write brief, humane, spiritually respectful copy. Avoid shame, pressure, gamification, or claims that imply spiritual performance.

## Accessibility and resilience

Target WCAG 2.2 AA where applicable and follow Flutter accessibility guidance.

- Maintain at least 4.5:1 contrast for normal text and 3:1 for large text and meaningful non-text UI.
- Provide at least 48×48 logical-pixel tap regions in Flutter.
- Never rely on color alone. Pair state with text, iconography, shape, or semantics.
- Add useful `Semantics`, labels, tooltips, headings, focus order, and selected/disabled state announcements.
- Support TalkBack, VoiceOver, keyboard focus where relevant, dark mode, text scaling, and narrow screens.
- Avoid fixed-height text containers unless overflow has been tested at large text sizes.
- Respect reduced-motion preferences; keep motion calm, purposeful, brief, and non-blocking.
- Keep destructive or consequential actions confirmable or reversible. Explain errors and recovery in plain language.

## Specify complete states

Account for loading, empty, first-use, success, error, offline, disabled, pressed, focused, selected, completed, locked, and long-content states when relevant. Include edge cases such as no published prayers, missing audio, interrupted playback, and very large text.

## Implementation guardrails

- Use `Theme.of(context).colorScheme` and text styles for semantic roles; use `AppColors` for intentional WWJS brand accents already established in the app.
- Avoid introducing one-off colors, radii, shadows, typography, or spacing when an existing token or component works.
- Prefer shared widgets such as `BrandLogo`, `DawnArtwork`, `PrayerCard`, and established modal patterns.
- Preserve warm surfaces, restrained elevation, generous rounded corners, serif display type, and quiet sage/forest accents.
- Keep layouts responsive with constraints, flexible regions, safe areas, and scrolling. Do not design only for one phone size.
- Separate design-system improvements from unrelated product or architecture changes.

## Validate

Before completion:

1. Check hierarchy, readability, interaction feedback, content length, and consistency in light and dark themes.
2. Test or reason through small screens, large text, screen readers, focus order, and 48×48 tap targets.
3. Run relevant Flutter tests and analysis when code changes are made. Add widget or golden tests when they protect meaningful behavior or visual structure.
4. State any remaining assumptions or validation gaps succinctly.

## References

- Current WWJS language and inventory: [references/wwjs-design-system.md](references/wwjs-design-system.md)
- Flutter accessibility guidance: <https://docs.flutter.dev/ui/accessibility>
- WCAG 2.2 overview: <https://www.w3.org/WAI/standards-guidelines/wcag/>
