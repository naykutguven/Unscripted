# AGENTS.md

## Mission and authority

These instructions apply to the entire repository and are self-contained. Do not
depend on a global `AGENTS.md` or untracked global support files.

Work as a staff-level iOS engineer. Optimize in this order:

1. Correctness, data preservation, privacy, and thread safety
2. Maintainability and testability
3. Accessibility, responsiveness, energy use, and product quality
4. Delivery speed

Thread safety is correctness. Accessibility and privacy are product requirements,
not later polish.

For every task:

- Follow the explicit request and acceptance criteria first.
- Read this file, the relevant task guides below, and relevant `README.md`
  sections before acting.
- Treat README product principles and privacy terminology as contracts.
- Treat the roadmap as planned scope, not existing behavior or authorization to
  implement adjacent phases.
- Surface conflicts with privacy, data preservation, platform scope, or product
  contracts before proceeding.

If a task guide conflicts with this file, this file wins. Read only guides
relevant to the task, but read each selected guide completely.

## Required task-guide routing

- For actors, tasks, isolation, `Sendable`, callbacks, continuations, async
  streams, locks, queues, executors, recording/playback, audio sessions, routes,
  interruptions, waveform work, Now Playing, remote commands, or audio-linked
  transcription, read
  [Concurrency and Audio](Docs/AgentGuides/ConcurrencyAndAudio.md).
- For SwiftData, journal files, migrations, deletion, search, generated-data
  provenance, export/restore, StoreKit/entitlements, App Lock security/Keychain,
  backup eligibility, CloudKit, PCC, or sync, read
  [Data and Privacy](Docs/AgentGuides/DataAndPrivacy.md).
- For SwiftUI, presentation state, navigation, permissions, purchase/restore
  presentation, visual design, localization, App Lock presentation, or
  accessibility, read
  [UI and Accessibility](Docs/AgentGuides/UIAndAccessibility.md).
- Before adding/changing tests, building, running, profiling, using sanitizers,
  making evidence claims, or handing off code, read
  [Testing and Validation](Docs/AgentGuides/TestingAndValidation.md).
- Tasks spanning domains require every applicable guide. Do not load unrelated
  guides by default.

## Project truth

- **Product:** private, local-first voice journal.
- **State:** early development; current source is starter scaffolding, not an
  established architecture.
- **Project/scheme:** `Unscripted.xcodeproj` / `Unscripted`
- **Targets:** `Unscripted`, `UnscriptedTests`, `UnscriptedUITests`
- **Platform:** iPhone only, iOS 26.0+. iPad and iPadOS are explicitly
  unsupported and are not roadmap scope.
- **Language:** Swift 6 language mode, source-compatible with Swift 6.2.
  `SWIFT_VERSION = 6.0` denotes language mode; never change it to `6.2`.
- **Concurrency:** Approachable Concurrency and app-target default `MainActor`
  isolation are enabled. Do not weaken them.
- **Stack:** SwiftUI, SwiftData, and Apple SDKs only.
- **Tests:** Swift Testing for unit/integration tests; XCTest/XCUITest for UI,
  launch, metrics, and unsupported APIs.
- **Automation:** no committed CI, shared scheme, test plan, linter, or formatter.

Do not change the deployment target, device families, language/concurrency
settings, bundle IDs, signing, entitlements, capabilities, background modes, or
purpose strings unless directly required by the requested behavior. Keep
necessary configuration minimal and review it as a privacy and App Review
boundary.

Do not add iPad device-family support, iPadOS destinations, iPad-specific UI or
tests, Mac Catalyst, or another platform unless the user explicitly changes the
product's iPhone-only scope.

The current `ContentView`, `Item`, unbounded `@Query`, direct view-side
`ModelContext` mutation, implicit `ModelConfiguration`, startup `fatalError`, and
placeholder tests are disposable scaffolding. Do not copy them as patterns.

The three target folders are Xcode filesystem-synchronized groups. Add ordinary
target files on disk; do not hand-edit `project.pbxproj` solely for membership.
Keep repository docs/tool configuration outside those target roots.
`Info.plist` is already a membership exception and must not be copied as a
resource.

Existing CloudKit/push declarations neither implement features nor authorize
transmission. Every local-journal `ModelConfiguration` must explicitly set
`cloudKitDatabase: .none`; backup/sync always use separate adapters.

## Non-negotiable product contracts

### Privacy and user control

- Treat audio, titles, transcripts, moods, tags, summaries, reflections, prompts,
  source links, search data, and derived metadata as sensitive content.
- Process journal content on device by default. Verify an Apple API's actual
  processing and network behavior before adoption.
- Do not add ads, analytics, tracking, a developer backend, or a required account.
- Do not add an external dependency or third-party SDK unless the user explicitly
  revises the Apple-SDKs-only contract and its privacy/security tradeoffs are
  documented.
- Asset downloads and StoreKit may use Apple services for their stated purpose,
  but never receive journal content.
- Cloud Backup, sync, and Private Cloud Compute are distinct, off-by-default
  boundaries with distinct consent. Local use survives opt-out.
- Never put real journal content in logs, diagnostics, identifiers, filenames,
  screenshots, tests, or fixtures. Use opaque IDs, redacted state, and synthetic
  data.

### Data preservation and portability

- Original recordings and user edits are irreplaceable. Derived work never
  corrupts or deletes them.
- Never silently discard a valid partial recording, overwrite the last good
  artifact, recreate a failed store, or recover by deleting user data.
- Cross-resource work is crash-safe and idempotent, with staging, validation, an
  explicit commit point, compensation, retry, and repeatable cleanup.
- Complete export remains available regardless of trial or purchase state.
  Existing content remains readable, playable, searchable, exportable, and
  deletable.
- **Device backup** means iOS-managed eligibility, **Cloud Backup** means
  app-managed versioned recovery, and **sync** means continuous propagation of
  edits/deletions. Eligibility does not prove a backup exists; backup is not sync.

### Speech and generated content

- Recording, playback, editing, browsing, and export remain useful without Speech
  assets or Apple Intelligence.
- Generated output is optional, untrusted, and never a medical assessment.
- User-visible suggestions are identifiable, editable, regenerable, and
  deletable. Internal derived artifacts are versioned, invalidatable, and
  regenerable without invented UI.
- Validate model structure, source IDs/revisions, context/period membership, and
  duplicates before display or save.
- Persist app-owned prompt/format/inference versions and only model identifiers
  the OS exposes. Never invent a framework model version.
- Bound model input/output and reject stale work after cancellation, deletion, or
  source revision changes.

## Core engineering standards

- Follow Apple's current
  [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines),
  [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/),
  and
  [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/).
- Keep Swift 6.2 source compatibility. A newer compiler build does not prove it.
- Prefer small readable diffs, clear names/boundaries, and minimal cleverness.
- Prefer `internal`; treat every broader API as a maintenance promise.
- Comments explain non-obvious intent, invariants, ownership, data-loss
  constraints, or measured tradeoffs—not obvious code.
- Use typed errors and explicit recovery. Do not use empty `catch`, `try!`, force
  unwraps, or `fatalError` for recoverable user-data/system conditions.
- Prefer dependency injection over global state. Inject time, IDs, roots, and
  capabilities where determinism matters.
- Keep UI/presentation on `MainActor`; give each mutable non-UI subsystem one
  explicit owner, normally an actor or `@ModelActor`.
- Never pass `ModelContext` or a live SwiftData model across actors. Pass stable
  IDs or immutable `Sendable` snapshots and refetch in the owning context.
- Prefer structured, cancellable, bounded concurrency. Do not silence concurrency
  diagnostics or use `@unchecked Sendable` without a documented necessity and
  synchronization invariant.
- Never block `MainActor`. Stream, page, or batch long recordings and large
  journals; bound task counts, buffers, and retries.
- User-facing work uses native semantic controls first and supports Dynamic Type,
  VoiceOver, appearance/contrast variants, Reduce Motion/Transparency,
  localization, and privacy-safe locked/external surfaces as applicable.

## Working method

1. Define observable acceptance criteria and important non-regressions.
2. Inspect current implementation, nearby tests, settings, working-tree changes,
   relevant README phase, and required guides.
3. Identify privacy/network, data/migration, concurrency, scalability,
   performance, accessibility, and physical-device implications.
4. Choose the smallest design with clear ownership and test seams.
5. Implement a focused diff; avoid drive-by refactors and speculative abstraction.
6. Build early and test at the lowest reliable layer.
7. Review the diff for data loss, privacy leaks, actor mistakes, unbounded work,
   HIG/accessibility regressions, and roadmap creep.
8. Update affected docs/comments and report exact validation and gaps.

For a bug, reason about or reproduce the failure first and add a root-cause
regression test when practical.

Ask for direction only when a missing choice materially changes privacy,
persistence compatibility, product behavior, or destructive behavior. Otherwise
make a conservative assumption, state it, and continue.

For code review, report only actionable issues introduced by the change. Prioritize
correctness, data/privacy, concurrency, performance/scalability, HIG,
accessibility, and test coverage; cite exact files and lines.

## Commit messages

Use the `$commit-messages` skill when drafting, editing, or reviewing commit messages.

## Architecture and state

Grow toward this shape without reorganizing unrelated files:

```text
Unscripted/
  App/                    Composition, lifecycle, routing
  Features/<Feature>/     Feature UI and presentation
  Domain/                 Shared value types and policies
  Services/<Capability>/  Persistence, files, audio, speech, StoreKit, etc.
  DesignSystem/           Reused app-specific visuals only
  Extensions/             Focused native-type extensions
```

- The app composition root creates long-lived dependencies once and injects them.
  Avoid service locators and mutable global singletons.
- Views render state and send intents; framework integration belongs in injected
  capability services.
- Maintain one-way dependencies: features depend on domain contracts/services;
  services never control views.
- Add a protocol where a consumer needs substitution, not for every concrete type.
- Model mutually exclusive view-model workflow states with enums and associated
  values. Render with exhaustive switches and derive convenience properties
  instead of parallel Boolean/optional flags.
- Keep independent state axes in separate enums rather than one Cartesian-product
  mega-enum. Add `Equatable`/`Sendable` when their semantics make them useful.
- Long operations use explicit legal transitions, cancellation/retry, a stable
  generation ID, and a last safe commit point. Revalidate identity/revision after
  each relevant `await`.
- Keep one primary type per file. Put native extensions in
  `Unscripted/Extensions/TypeName+Extensions.swift` and mirror under tests.
- Avoid generic `Utils`, `Helpers`, and `Manager` dumping grounds.
- Add a target/package only for a real ownership, reuse, or dependency boundary.

## Validation and definition of done

Read [Testing and Validation](Docs/AgentGuides/TestingAndValidation.md) before
building, testing, running, profiling, using sanitizers, or handing off code.

- When code or project configuration changes, build the affected target and
  validate at the lowest reliable layer.
- Run physical-device-only checks when available; otherwise record the exact
  missing release gate.
- Report exact commands, destinations, devices, OS versions, results, and gaps.
- Never claim all tests, CI, thread safety, device behavior, Swift 6.2
  compatibility, or performance improvement without corresponding evidence.
- Leave no new warnings, unrelated changes, stale debug paths, or mismatched docs.

A change is done only when acceptance criteria and README contracts are met,
mutable state has one owner, cancellation/failure/stale-result behavior is
intentional, existing data remains safe, work is bounded, `MainActor` remains
responsive, relevant HIG/accessibility/privacy behavior is checked, and tests
cover the lowest reliable layer.

Every handoff/PR states what and why, scope, privacy/network/entitlement impact,
schema/migration/export/backup impact, concurrency ownership/cancellation,
performance evidence, HIG/accessibility validation, synthetic screenshots for UI
changes, exact validation, recovery/rollback behavior, risks, and remaining gates.
