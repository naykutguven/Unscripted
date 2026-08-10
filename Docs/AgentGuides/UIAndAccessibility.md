# UI and Accessibility

## When this guide is required

Read this guide before changing SwiftUI views, presentation state, navigation,
forms, permissions, purchase/restore presentation, user-visible system surfaces,
localization, visual design, App Lock presentation, or accessibility.

Also read [Concurrency and Audio](ConcurrencyAndAudio.md) for async ownership or
audio controls, [Data and Privacy](DataAndPrivacy.md) for private-content
boundaries, and [Testing and Validation](TestingAndValidation.md) before
verification.

The root [AGENTS.md](../../AGENTS.md) and README contracts remain authoritative.
Follow Apple's current
[Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines)
and [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/).

## View and presentation design

- Design and validate for supported iPhone screen sizes and orientations. Do not
  add iPad navigation or layouts, multiwindow UI, Split View, Stage Manager,
  pointer behavior, or iPad-specific keyboard interactions. Responsive layout
  remains required for iPhone sizes, localization, and Dynamic Type.
- Views render state and send intents. They do not coordinate SwiftData, files,
  audio, speech, purchases, and network work.
- Presentation state is normally an `@MainActor @Observable` type owned at the
  narrowest useful feature or scene boundary.
- Model mutually exclusive view-model workflows with enums and associated values.
  Render them with exhaustive switches.
- Derive convenience properties instead of storing parallel Boolean/optional
  flags that can create invalid combinations.
- Keep independent axes in separate focused enums rather than one
  Cartesian-product mega-enum.
- Use native SwiftUI navigation, presentation, search, forms, toolbars, menus,
  editing, and controls before custom replicas.
- A gesture-only interaction needs an equivalent visible and accessible action.
- Async screens intentionally represent applicable empty, preparing/progress,
  unavailable/permission, failure/retry, cancellation, and success states.
  Never leave an unexplained indefinite spinner.

## Visual design and Liquid Glass

- Preserve clear content hierarchy, legibility, harmony, and platform consistency.
- Keep Liquid Glass in navigation and control layers rather than decorating
  private journal content.
- Prefer system-provided glass behavior. Limit simultaneous custom effects and
  group them appropriately.
- Support Light and Dark appearances and Increased Contrast.
- Use semantic colors and materials. Never use color as the only state signal.
- Prefer SwiftUI, Canvas, or Core Animation to Metal. Add Metal only for a
  measured requirement that system tools cannot meet efficiently.
- A custom effect must preserve accessibility, touch behavior, battery, thermal,
  and rendering performance.

## Accessibility

- Use Dynamic Type and semantic text styles through accessibility sizes. Avoid
  fixed-height or clipped text containers.
- Aim for 44-by-44-point custom touch regions with adequate spacing. Smaller
  regions are reserved for documented system-standard compact controls.
- Provide accurate VoiceOver labels, values, traits, headings, grouping, focus
  order, and useful announcements for meaningful asynchronous changes.
- Do not add redundant hints when a control's label and trait already explain it.
- Never rely on color, motion, sound, waveform, or haptics alone. Provide
  equivalent textual or semantic state.
- Support Differentiate Without Color, Reduce Motion, and Reduce Transparency.
- Avoid auto-dismissing important information, uncontrolled repetitive motion,
  or flashing.
- Accessible content/actions match what an authenticated user can see—no less
  and no hidden extras.
- When App Lock engages, hide both visual and accessibility journal content.
- Make primary flows operable with VoiceOver and simple system-standard
  interactions. Provide visible alternatives to custom gestures.

## Permissions, purchases, recording, and destructive actions

- Request microphone, speech, biometrics, and notifications only in context after
  concise education.
- Purpose strings say specifically what is used and why, in clear active language.
- Permission denial has a useful fallback and, when appropriate, a Settings route.
- Do not repeatedly pressure a user who declined permission.
- Present purchase or restore UI only after explicit user intent. Represent
  pending, cancellation, offline, restore, and failure without blocking access to
  existing journal content or complete export.
- Show an unambiguous visual and semantic recording state and preserve system
  recording indicators.
- Starting or resuming recording requires clear user intent.
- Explain destructive journal actions and their scope plainly.
- Prefer undo or recoverable staging when it is honest about deletion semantics.
- Never use dark patterns for trial, purchase, consent, deletion, or generated
  features.

## Privacy-sensitive UI

- Notifications, Now Playing, widgets, Live Activities, and app-switcher
  snapshots remain generic according to privacy/App Lock policy.
- Never expose a title, transcript, mood, tag, reflection, or other journal
  content on an external surface unless an explicit future policy allows it.
- App Lock pauses playback, clears Now Playing, and disables external commands
  according to the documented policy.
- Accessibility identifiers are stable semantic tokens and contain no journal
  content.
- Previews, UI tests, screenshots, and performance fixtures use synthetic content.
- Generated suggestions are clearly identifiable, user-controlled, and never
  presented with medical certainty or anthropomorphic authority.

## Localization and formatting

- Localize all user-facing copy with grammar-safe resources.
- Avoid concatenating localized fragments.
- Format dates, times, durations, numbers, calendars, and period boundaries with
  locale-aware APIs.
- Test representative long translations, right-to-left layout when supported,
  and large accessibility text.
- User-facing errors state what happened, whether data is safe, and the next
  useful action without exposing private diagnostic detail.

## SwiftUI performance

- Keep `body` cheap, deterministic, and side-effect-free.
- Observe the narrowest state possible and preserve stable identity.
- Do not let frequent metering, waveform, progress, or playback ticks invalidate
  unrelated screens.
- Coalesce transient updates and stop view-lifetime timers/tasks when inactive.
- Avoid repeated decoding, formatter setup, fetches, or allocation on hot paths.
- Cache only with explicit ownership/invalidation and measured benefit.
- Profile custom Liquid Glass and animation for render cost, contrast, Reduce
  Motion/Transparency, battery, and thermals.

## Verification checklist

Follow [Testing and Validation](TestingAndValidation.md). Check applicable:

- Light/Dark, Increased Contrast, Reduce Transparency, and Reduce Motion;
- Dynamic Type through accessibility sizes without clipping;
- VoiceOver labels, values, order, focus, announcements, and actions;
- touch-target size, gesture alternatives, and destructive confirmations;
- localized/long content and relevant locale/calendar behavior;
- empty, loading, permission-denied, unavailable, error, retry, and cancellation;
- authenticated, locked, app-switcher, notification, and Now Playing privacy;
- recording indicators and explicit start/resume intent; and
- SwiftUI invalidation/rendering behavior for frequent updates.

Use Accessibility Inspector and synthetic fixtures where available. Report any
unverified device-only or assistive-technology behavior as a release gate.
