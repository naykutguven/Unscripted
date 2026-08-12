# Architecture and Source Layout

This document is a living map of where Unscripted code should live as the
roadmap is implemented. It describes intended ownership boundaries; it is not a
claim that planned files or features already exist.

The authoritative product and engineering contracts remain:

- [`AGENTS.md`](../AGENTS.md)
- [`README.md`](../README.md)
- [Concurrency and Audio](AgentGuides/ConcurrencyAndAudio.md)
- [Data and Privacy](AgentGuides/DataAndPrivacy.md)
- [UI and Accessibility](AgentGuides/UIAndAccessibility.md)
- [Testing and Validation](AgentGuides/TestingAndValidation.md)

Roadmap entries must be added only when their phase is being implemented. A
planned path in this document does not authorize adjacent work, a privacy
boundary, a capability, an entitlement, or network transmission.

## How to use this map

- Add a source folder when it receives its first real file. Do not add
  `.gitkeep` placeholders under an Xcode target folder.
- Update the status marker when a file is added, moved, replaced, or deliberately
  removed.
- Treat proposed filenames as clear starting points, not frozen APIs. Preserve
  the documented ownership even when implementation details change.
- Keep ordinary source files inside their owning target's filesystem-synchronized
  folder. Do not edit `project.pbxproj` solely to add those files.
- Keep documentation, scripts, and tool configuration outside the three target
  folders.
- Prefer one primary type per file and avoid generic `Utils`, `Helpers`,
  `Managers`, `Common`, or `Shared` dumping grounds.

### Status legend

| Marker | Meaning |
| --- | --- |
| ✅ | Exists in the current working tree at the documented path |
| 🔀 | Exists, but is expected to move or split when that area is implemented |
| 🧹 | Disposable starter scaffolding; do not copy it as an architectural pattern |
| 🗓️ | Planned destination; create only with its roadmap work |
| ⚠️ | Requires a documented product, privacy, retention, conflict, or feasibility decision first |

## Architectural layers

| Layer | Owns | Does not own |
| --- | --- | --- |
| `App` | Composition, lifecycle, app-wide routing, root presentation, and privacy gating | Feature business rules or framework implementation details |
| `Features` | SwiftUI views, `@MainActor` presentation state, and user intents | SwiftData contexts, file transactions, audio sessions, model sessions, or CloudKit transport |
| `Domain` | Framework-independent identities, immutable snapshots, state machines, policies, and provenance | SwiftUI, SwiftData `@Model` types, or Apple-framework adapters |
| `Services` | Apple-framework integration, mutable non-UI owners, persistence, files, and long operations | Navigation or direct control of views |
| `DesignSystem` | Genuinely reused app-specific visuals and semantic style tokens | Feature workflows or business policy |
| `Extensions` | Narrow extensions to native Swift and Apple types | General-purpose helper collections |

Dependencies flow toward domain meaning:

```text
App ───────────────► Features ─────────► Domain
 │                       │
 └──── composes ─────► Services ───────► Domain
                         ▲
Features send intents ───┘

Features ────────────► DesignSystem
Services never control Features or Views
```

The app composition root creates long-lived concrete services once and injects
the narrow capabilities their consumers need. A service protocol is introduced
only when a consumer needs substitution; protocols do not belong in a generic
`Protocols/` folder.

## Current source snapshot

This is the relevant application and test structure currently present in the
working tree. Hidden Finder files are intentionally omitted.

```text
Unscripted/
├── Assets.xcassets/                         ✅
├── ContentView.swift                        🧹
├── Features/
│   └── Navigation/
│       └── JournalTabBar.swift              🔀
├── Info.plist                               ✅
├── Item.swift                               🧹
├── Unscripted.entitlements                  ✅
└── UnscriptedApp.swift                      🔀

UnscriptedTests/
└── UnscriptedTests.swift                    🧹

UnscriptedUITests/
├── UnscriptedUITests.swift                  🧹
└── UnscriptedUITestsLaunchTests.swift       🧹
```

`UnscriptedApp.swift` currently lives at the target root. Its destination is
`App/UnscriptedApp.swift` once an app composition boundary is introduced.
`JournalTab` is currently declared inside `JournalTabBar.swift`, and the file
currently lives under `Features/Navigation/`. App-wide tab routing belongs under
`App/Navigation/`. These moves are organizational follow-up work, not changes
performed by this document.

## Destination layout

<details open>
<summary><strong><code>Unscripted/App/</code></strong> — composition, lifecycle, routing, and app-wide privacy</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🔀 | `UnscriptedApp.swift` | The `@main` entry point. Creates the composition, installs dependencies, and presents the root scene. It currently exists at `Unscripted/UnscriptedApp.swift`. |
| 🗓️ | `Composition/` | Construction and dependency wiring for long-lived application capabilities. |
| 🗓️ | `Composition/AppComposition.swift` | Creates the persistence owner, file store, recorder, player, audio-session coordinator, entitlement owner, and other long-lived services once. It is not a runtime service locator. |
| 🗓️ | `Lifecycle/` | App-wide foreground, background, activation, and termination coordination. |
| 🗓️ | `Lifecycle/AppLifecycleModel.swift` | Routes lifecycle events to the services that own the affected state without duplicating recorder, player, or lock state. |
| 🗓️ | `Navigation/` | Root tabs, typed destinations, navigation restoration, and validated deep links. |
| 🗓️ | `Navigation/AppRoute.swift` | Typed app destinations carrying stable domain IDs rather than live SwiftData models. |
| 🗓️ | `Navigation/AppNavigationModel.swift` | `@MainActor` owner of app-wide paths, selected tab, sheets, and full-screen presentation. |
| 🗓️ | `Navigation/AppShellView.swift` | Root visible shell containing navigation stacks, the tab bar, app-level overlays, and an optional compact player. |
| 🔀 | `Navigation/JournalTab.swift` | Identity and presentation metadata for root tabs. It is currently declared inside `Features/Navigation/JournalTabBar.swift`. |
| 🔀 | `Navigation/JournalTabBar.swift` | Renders root tab selection and the record action. It currently exists at `Features/Navigation/JournalTabBar.swift`. |
| 🗓️ | `Navigation/DeepLink.swift` | Parses URLs and notification responses into validated, privacy-safe app routes. |
| 🗓️ | `Privacy/` | App-level presentation boundaries that protect every feature at once. |
| 🗓️ | `Privacy/AppPrivacyGate.swift` | Replaces private visible and accessibility content while App Lock is engaged and coordinates privacy-safe app-switcher presentation. |

</details>

<details>
<summary><strong><code>Unscripted/Features/</code></strong> — user-visible workflows and presentation state</summary>

Feature folders contain SwiftUI views, `@MainActor` presentation models, and
components used only by that feature. Views render state and send intents;
Apple-framework integration stays in `Services/`.

<details>
<summary><code>Onboarding/</code> — first-launch and contextual privacy education (version 1.0)</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `OnboardingView.swift` | Presents local storage, backup exclusion, export, optional intelligence, App Lock, and future network-feature education. |
| 🗓️ | `OnboardingModel.swift` | Owns page progression, restoration, completion, and capability-dependent presentation. |
| 🗓️ | `Components/` | Visuals used only by onboarding, such as education cards or page indicators. |

</details>

<details>
<summary><code>Journal/</code> — reverse-chronological entry library and entry detail (version 1.0)</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `JournalView.swift` | Displays bounded, paged entry snapshots grouped by local calendar day. |
| 🗓️ | `JournalModel.swift` | Owns loading, empty, error, grouping, rename, delete, and navigation presentation for the library. |
| 🗓️ | `Components/` | Journal-only rows, day headers, transcript-state labels, and bounded metadata chips. |
| 🗓️ | `EntryDetail/` | User experience for one stable journal-entry ID. |
| 🗓️ | `EntryDetail/EntryDetailView.swift` | Presents recording metadata, playback, transcript status, insights, summaries, and entry actions. |
| 🗓️ | `EntryDetail/EntryDetailModel.swift` | Coordinates presentation for an immutable entry snapshot and reacts safely to edits or deletion. |
| 🗓️ | `EntryDetail/Components/` | Components used only within entry detail. |

</details>

<details>
<summary><code>Recording/</code> — explicit, interruption-aware recording controls (version 1.0)</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `RecordingView.swift` | Presents ready, recording, interrupted, finalizing, completed, and recoverable failure states. |
| 🗓️ | `RecordingModel.swift` | Maps the recorder owner's state into UI state and handles explicit start, stop, resume, cancel, and retry intents. |
| 🗓️ | `MicrophonePermissionView.swift` | Gives contextual microphone education, denial fallback, and a Settings route where appropriate. |
| 🗓️ | `Components/` | Recording-only controls, elapsed-time presentation, interruption notices, and semantic status indicators. |

</details>

<details>
<summary><code>Playback/</code> — in-app audio playback (version 1.0)</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `PlayerView.swift` | Presents play, pause, seek, elapsed time, duration, interruption, and failure state. |
| 🗓️ | `PlayerModel.swift` | Observes the single player owner and forwards explicit playback intents. |
| 🗓️ | `CompactPlayerView.swift` | Optional app-level surface shown after leaving entry detail, backed by the same player owner. |

</details>

<details>
<summary><code>Transcripts/</code> — transcription status and editable draft review (version 1.0)</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `TranscriptStatusView.swift` | Presents unavailable, missing-asset, queued, running, failed, cancelled, draft, and accepted states. |
| 🗓️ | `TranscriptReviewView.swift` | Lets the user edit, copy, accept, retry, or discard a generated draft. |
| 🗓️ | `TranscriptReviewModel.swift` | Preserves unsaved edits and acts against stable entry and transcript revisions. |
| 🗓️ | `Components/` | Transcript-only editors, status banners, and action groups. |

</details>

<details>
<summary><code>Calendar/</code> — locale-aware calendar browsing (version 1.0)</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `JournalCalendarView.swift` | Marks dates containing entries and displays entries for the selected date. |
| 🗓️ | `JournalCalendarModel.swift` | Owns selected date and period presentation using explicit calendar, locale, and time-zone values. |
| 🗓️ | `Components/` | Calendar-only day cells, period headers, and accessible entry indicators. |

</details>

<details>
<summary><code>Insights/</code> — generated mood and tag suggestions (version 1.0)</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `InsightsView.swift` | Presents eligibility, generation, review, acceptance, editing, removal, and regeneration. |
| 🗓️ | `InsightsModel.swift` | Starts bounded generation through an injected capability and rejects stale presentation after source changes or deletion. |
| 🗓️ | `Components/` | Insight-only suggestion chips, provenance labels, generated-state labels, and review controls. |

</details>

<details>
<summary><code>Reflections/</code> — source-traceable weekly, monthly, and yearly reflection experiences</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `ReflectionHistory/` | History grouped by period, including eligible, not generated, current, stale, and failed states. |
| 🗓️ | `ReflectionDetail/` | Section presentation, source coverage, source navigation, review, regeneration, editing, and deletion. |
| 🗓️ | `Weekly/` | Weekly eligibility and generation presentation for version 1.0. |
| 🗓️ | `Monthly/` | Monthly eligibility and generation presentation for version 1.0. |
| 🗓️ | `Yearly/` | On-device yearly reflection presentation planned for version 1.3. |
| 🗓️ | `Reminders/` | Weekly, monthly, and optional yearly reminder preferences and contextual permission UI. |
| 🗓️ | `Components/` | Reflection-only section cards, source coverage, period labels, and stale-state notices. |

</details>

<details>
<summary><code>Search/</code> — private local journal search (version 1.0)</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `JournalSearchView.swift` | Presents query, recent-query, empty, results, and recoverable failure states. |
| 🗓️ | `JournalSearchModel.swift` | Debounces bounded queries, loads immutable results, clears queries, and routes to source content. |
| 🗓️ | `Components/` | Search-only fields, result rows, matched context, and result grouping. |

</details>

<details>
<summary><code>DataControls/</code> — local data and device-backup eligibility (version 1.0)</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `LocalDataView.swift` | Explains local storage, export, storage scope, and local-data controls. |
| 🗓️ | `DeviceBackupSettingsView.swift` | Presents “Include in Device Backups” with accurate eligibility language. |
| 🗓️ | `DeleteJournalView.swift` | Presents confirmation and recoverable progress for complete local deletion. |
| 🗓️ | `DataControlsModel.swift` | Maps applied backup eligibility and deletion-service state into presentation. |

</details>

<details>
<summary><code>AppLock/</code> — lock presentation and settings (version 1.0)</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `AppLockView.swift` | Presents a generic locked state and authentication action without exposing journal content. |
| 🗓️ | `AppLockSettingsView.swift` | Presents opt-in, opt-out, and any approved grace-period settings. |
| 🗓️ | `AppLockModel.swift` | Maps authentication results and lock policy into explicit UI states. |

</details>

<details>
<summary><code>Export/</code> — complete durable export (version 1.0)</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `ExportView.swift` | Presents scope, preparation, progress, cancellation, recoverable failure, and publication. |
| 🗓️ | `ExportModel.swift` | Starts export through an injected service and communicates whether local data remains safe. |

</details>

<details>
<summary><code>Purchases/</code> — trial, Full Unlock, and restoration (version 1.0)</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `PurchaseView.swift` | Presents verified products, terms, pending state, cancellation, and failures without dark patterns. |
| 🗓️ | `RestorePurchasesView.swift` | Handles explicit user-initiated purchase restoration. |
| 🗓️ | `PurchaseModel.swift` | Maps verified entitlement-service state into presentation. |

</details>

<details>
<summary><code>CloudBackup/</code> — versioned recovery backup and explicit restore (version 1.1)</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `CloudBackupView.swift` | Presents opt-in, account state, generations, progress, errors, retention, and disable behavior. |
| ⚠️ | `BackupRestoreView.swift` | Presents compatible generations and an explicit restore decision. Nonempty-journal restore behavior must be approved before implementation. |
| 🗓️ | `CloudBackupModel.swift` | Maps backup operations and recovery actions into bounded presentation state. |

</details>

<details>
<summary><code>Sync/</code> — continuous cross-iPhone synchronization (version 1.2)</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| ⚠️ | `SyncSettingsView.swift` | Presents distinct sync consent, scope, migration preview, and opt-out behavior after the sync contract is approved. |
| ⚠️ | `SyncStatusView.swift` | Presents offline, transferring, conflict, recoverable failure, and convergence state. |
| ⚠️ | `SyncModel.swift` | Observes the eventual sync owner and exposes only approved conflict and recovery actions. |

</details>

<details>
<summary><code>Settings/</code> — settings home and routes to capability-owned settings</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `SettingsView.swift` | Routes to privacy, App Lock, device backup, Cloud Backup, sync, reminders, export, and purchase settings. |
| 🗓️ | `Components/` | Settings-only rows, section content, and explanatory footers. |

Settings links to other capability-owned screens rather than absorbing their
state into one large settings model.

</details>

</details>

<details>
<summary><strong><code>Unscripted/Domain/</code></strong> — framework-independent meaning, identity, and policy</summary>

Domain values should generally be immutable and `Sendable` where their semantics
allow it. They do not import SwiftUI, SwiftData, AVFoundation, Foundation Models,
StoreKit, or CloudKit.

<details>
<summary><code>Journal/</code> — entry identity, immutable data, and lifecycle</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `JournalEntryID.swift` | Stable, opaque app-level identity independent of SwiftData identity. |
| 🗓️ | `JournalEntryRevision.swift` | Exact source revision used by transcription, generation, search, export, backup, and sync. |
| 🗓️ | `JournalEntrySnapshot.swift` | Immutable entry data safe to pass across ownership boundaries. |
| 🗓️ | `JournalEntryLifecycle.swift` | Legal recording, finalized-audio, transcript, and derived-content lifecycle states. |

</details>

<details>
<summary><code>Audio/</code> — framework-independent recording and playback state</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `RecordingID.swift` | Stable identity for a recording and finalization operation. |
| 🗓️ | `AudioFileReference.swift` | Opaque relative recording-file identity; never an absolute container URL. |
| 🗓️ | `RecordingState.swift` | Legal recording workflow states and associated values. |
| 🗓️ | `PlaybackState.swift` | Shareable playback selection, position, duration, interruption, and failure state. |

</details>

<details>
<summary><code>Transcripts/</code> — transcript identity and lifecycle</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `TranscriptRevision.swift` | Identifies the accepted transcript revision used by dependent work. |
| 🗓️ | `TranscriptState.swift` | Distinguishes missing, processing, draft, accepted, discarded, unavailable, and failed states. |
| 🗓️ | `TranscriptSnapshot.swift` | Immutable transcript representation passed instead of a live persistence object. |

</details>

<details>
<summary><code>GeneratedContent/</code> — shared generation identity, lifecycle, and provenance</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `GenerationID.swift` | Stable operation identity used to reject cancelled, replaced, deleted, or late results. |
| 🗓️ | `GenerationState.swift` | Shared lifecycle concepts such as eligible, queued, generating, current, stale, failed, and cancelled. |
| 🗓️ | `GenerationProvenance.swift` | Exact source IDs and revisions plus app-owned inference, prompt, format, and chunking versions. |
| 🗓️ | `InferenceVersion.swift` | App-owned version identifiers; it must never invent a framework model version. |
| 🗓️ | `ProcessingMode.swift` | Distinguishes on-device processing from separately consented PCC processing. |
| 🗓️ | `SourceReference.swift` | Stable link to an exact source identity and revision. |

</details>

<details>
<summary><code>Insights/</code> — accepted, edited, and generated mood/tag values</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `Mood.swift` | Validated mood label with explicit generated or user-edited ownership. |
| 🗓️ | `Tag.swift` | Bounded, validated tag value. |
| 🗓️ | `SuggestedInsights.swift` | Proposed moods and tags with provenance, source revision, and acceptance state. |

</details>

<details>
<summary><code>Summaries/</code> — bounded per-entry summaries</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `EntrySummary.swift` | Validated summary tied to an entry and exact accepted-transcript revision. |
| 🗓️ | `SummaryPolicy.swift` | Input/output budgets, eligibility, chunking version, and invalidation rules. |

</details>

<details>
<summary><code>Reflections/</code> — weekly, monthly, and yearly reflection meaning</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `ReflectionID.swift` | Stable reflection identity independent of storage. |
| 🗓️ | `ReflectionPeriod.swift` | Calendar-aware week, month, or year with explicit boundaries. |
| 🗓️ | `ReflectionSection.swift` | Validated section and the supplied source IDs it references. |
| 🗓️ | `ReflectionSnapshot.swift` | Immutable reflection data for UI, export, backup, or sync. |
| 🗓️ | `ReflectionEligibilityPolicy.swift` | Minimum coverage, valid period, and generation-eligibility rules. |

</details>

<details>
<summary><code>Calendar/</code> — period and grouping policy</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `JournalPeriodPolicy.swift` | Applies explicit calendar, locale, time-zone, week, month, year, and DST boundary rules. |

</details>

<details>
<summary><code>Search/</code> — index-independent search values</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `SearchQuery.swift` | Normalized, bounded search input and options. |
| 🗓️ | `SearchResult.swift` | Stable source reference plus bounded matched context safe for presentation. |

</details>

<details>
<summary><code>Export/</code> — durable export format</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `ExportManifest.swift` | Codable representation of entries, relationships, provenance, assets, sizes, and checksums. |
| 🗓️ | `ExportVersion.swift` | Explicit export-format version and compatibility rules. |

</details>

<details>
<summary><code>Backup/</code> — app-managed Cloud Backup values</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `BackupGenerationID.swift` | Stable identity for one complete or incomplete recovery generation. |
| 🗓️ | `BackupGeneration.swift` | Metadata describing a versioned generation and its content coverage. |
| 🗓️ | `BackupState.swift` | Disabled, preparing, uploading, complete, incomplete, failed, and restoring state. |

This domain is unrelated to iOS-managed device-backup eligibility.

</details>

<details>
<summary><code>Sync/</code> — continuous synchronization values</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| ⚠️ | `SyncState.swift` | Disabled, migrating, offline, transferring, conflicting, failed, or converged state after the sync contract is approved. |
| ⚠️ | `ConflictPolicy.swift` | Approved deterministic rules for edits, duplicates, derived content, and deletion. Do not invent these rules during implementation. |

</details>

<details>
<summary><code>Privacy/</code> — framework-independent privacy and consent policy</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `AppLockPolicy.swift` | Locking, relocking, grace-period, external-control, and protected-presentation rules. |
| 🗓️ | `ProcessingConsent.swift` | Narrow consent for one processing boundary, such as PCC, without conflating backup or sync consent. |

</details>

<details>
<summary><code>Entitlements/</code> — verified access state and product policy</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `EntitlementState.swift` | Verified trial, unlocked, expired, pending, unavailable, or unknown state. |
| ⚠️ | `AccessPolicy.swift` | Determines which optional actions are gated while preserving existing-content access and complete export. Exact trial and unlock rules require a product decision. |

</details>

</details>

<details>
<summary><strong><code>Unscripted/Services/</code></strong> — framework adapters and mutable non-UI owners</summary>

Each mutable subsystem has one explicit owner, normally an actor or `@ModelActor`.
Long operations are bounded, cancellable, and tied to stable operation and source
revision identities.

<details>
<summary><code>Persistence/</code> — SwiftData schema and structured local storage</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `ModelContainerFactory.swift` | Creates a versioned local container with explicit `cloudKitDatabase: .none` and recoverable open failures. |
| 🗓️ | `JournalStore.swift` | Isolated owner of bounded journal fetches and structured writes. |
| 🗓️ | `Schema/` | SwiftData `VersionedSchema` declarations and schema-version definitions. |
| 🗓️ | `Models/` | SwiftData `@Model` records. These are persistence representations, not cross-actor domain values. |
| 🗓️ | `Migrations/` | Explicit migration plans, stages, adapters, and compatibility decisions. |

</details>

<details>
<summary><code>JournalFiles/</code> — protected recording files and crash recovery</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `JournalRoot.swift` | Resolves and configures the private journal root, Data Protection, and default device-backup exclusion. |
| 🗓️ | `RecordingFileStore.swift` | Creates opaque staged files and owns bounded file access and idempotent cleanup. |
| 🗓️ | `RecordingFinalizer.swift` | Closes, validates, atomically renames, and publishes a recording through an explicit commit sequence. |
| 🗓️ | `JournalStorageRecovery.swift` | Detects interrupted staging and orphan states without deleting recoverable user data. |

</details>

<details>
<summary><code>Journal/</code> — cross-resource journal mutations</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `EntryDeletionService.swift` | Coordinates idempotent deletion of one entry's structured data, original recording, derived artifacts, search records, and provenance. |
| 🗓️ | `LocalJournalDeletionService.swift` | Coordinates confirmed deletion of all local journal resources with recoverable progress and repeatable cleanup. |

These operations exist separately from `JournalStore` because SwiftData and file
operations do not share one transaction.

</details>

<details>
<summary><code>DeviceBackup/</code> — iOS-managed backup eligibility</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `DeviceBackupEligibilityService.swift` | Reads and applies exclusion attributes for current and future local journal artifacts. It cannot claim that an iOS backup exists. |

</details>

<details>
<summary><code>Audio/</code> — AVFoundation session, recording, playback, and system controls</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `Session/AudioSessionCoordinator.swift` | Serializes audio-session category, mode, activation, interruptions, routes, and media-service resets. |
| 🗓️ | `Recording/AudioRecorder.swift` | Single mutable owner of capture state, callbacks, interruptions, and recording teardown. |
| 🗓️ | `Playback/AudioPlayer.swift` | Single mutable owner of selected audio, position, duration, seeking, interruptions, and cleanup. |
| 🗓️ | `SystemPlayback/NowPlayingPublisher.swift` | Publishes only generic, privacy-safe playback metadata and progress. |
| 🗓️ | `SystemPlayback/RemoteCommandController.swift` | Installs, validates, handles, and removes play, pause, and seek commands. |

</details>

<details>
<summary><code>Speech/</code> — post-finalization transcription</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `SpeechAvailability.swift` | Evaluates locale, authorization, device, and speech-asset availability. |
| 🗓️ | `SpeechAssetService.swift` | Coordinates required Apple speech assets and exposes explicit download or failure state. |
| 🗓️ | `TranscriptionService.swift` | Runs bounded, cancellable saved-file transcription and returns an untrusted draft. |

Transcription begins only after recording finalization, and its failure never
affects the original audio.

</details>

<details>
<summary><code>Intelligence/</code> — availability-gated on-device Foundation Models integration</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `FoundationModelsClient.swift` | Narrow test seam around Foundation Models sessions if multiple generators need the same adapter. Do not add it before that need exists. |
| 🗓️ | `Availability/IntelligenceAvailability.swift` | Reports supported device, locale, model, assets, refusal, and unavailable conditions. |
| 🗓️ | `Models/GeneratedInsightsOutput.swift` | Foundation Models structured-output schema for proposed moods and tags. |
| 🗓️ | `Models/GeneratedSummaryOutput.swift` | Structured-output schema for a bounded entry summary. |
| 🗓️ | `Models/GeneratedReflectionOutput.swift` | Structured-output schema for reflection sections and supplied source IDs. |
| 🗓️ | `Insights/OnDeviceInsightsGenerator.swift` | Builds bounded input, invokes the model, validates output, and returns a domain value. |
| 🗓️ | `Summaries/OnDeviceSummaryGenerator.swift` | Applies deterministic context budgets and stable hierarchical chunking. |
| 🗓️ | `Reflections/OnDeviceReflectionGenerator.swift` | Generates source-labelled sections and rejects invalid, duplicate, unknown, or out-of-period references. |

Foundation Models output types are untrusted framework adapters. They are neither
SwiftData records nor domain truth. Capability names such as `Generator` or
`Service` are preferred over a catch-all `AppleIntelligenceManager`.

</details>

<details>
<summary><code>Search/</code> — private, rebuildable local indexing</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `LocalSearchIndex.swift` | Updates and queries a bounded on-device index that is never published to Spotlight. |
| 🗓️ | `SearchIndexRebuilder.swift` | Reconstructs disposable index data from authoritative journal content. |

</details>

<details>
<summary><code>Export/</code> — durable export construction and validation</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `JournalExporter.swift` | Coordinates a consistent snapshot, protected staging, packaging, publication, cancellation, and cleanup. |
| 🗓️ | `ExportManifestEncoder.swift` | Encodes the documented deterministic UTF-8 manifest. |
| 🗓️ | `ExportArchiveValidator.swift` | Independently validates paths, relationships, sizes, checksums, and manifest decoding before publication. |

</details>

<details>
<summary><code>Security/</code> — LocalAuthentication, Keychain, and runtime App Lock state</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `AppLockAuthenticator.swift` | Wraps LocalAuthentication with typed success, cancellation, denial, and unavailable outcomes. |
| 🗓️ | `AppLockStateController.swift` | Owns lock state, relocking policy, lifecycle reactions, and coordination with playback and external surfaces. |

</details>

<details>
<summary><code>Notifications/</code> — generic local reflection reminders</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `ReflectionReminderScheduler.swift` | Requests contextual authorization and deterministically schedules, replaces, or removes privacy-safe reminders. |

</details>

<details>
<summary><code>Preferences/</code> — non-sensitive app preferences</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `AppPreferencesStore.swift` | Persists non-sensitive settings such as onboarding completion. Journal content and secrets never belong in this store. |

Capability-owned applied state remains with its capability—for example, device
backup eligibility with `DeviceBackupEligibilityService` and App Lock secrets
with `Security/`.

</details>

<details>
<summary><code>StoreKit/</code> — verified entitlement lifecycle</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `EntitlementService.swift` | Verifies transactions, reconciles current entitlements, owns `Transaction.updates`, handles restoration, and provides approved offline state. |

</details>

<details>
<summary><code>LiveActivity/</code> — main-app ActivityKit control (version 1.1)</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `RecordingActivityController.swift` | Starts, updates, recovers, and ends a generic recording Live Activity according to recorder state and App Lock policy. |

</details>

<details>
<summary><code>CloudBackup/</code> — versioned CloudKit recovery generations (version 1.1)</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `CloudBackupService.swift` | Owns backup lifecycle, stable operation identity, retry, cancellation, and high-level progress. |
| 🗓️ | `CloudBackupSnapshotBuilder.swift` | Creates a consistent, versioned local snapshot without mutating the journal source of truth. |
| 🗓️ | `CloudBackupUploader.swift` | Uploads deterministic resumable batches and publishes a generation manifest only after all content verifies. |
| ⚠️ | `CloudBackupRestorer.swift` | Downloads into staging, validates, imports into a temporary store, and activates atomically after nonempty-journal restore policy is approved. |
| 🗓️ | `CloudKit/` | Backup-only custom-zone records, encrypted-field mappings, manifests, asset chunking, and transport adapters. |

Cloud Backup is off by default and remains separate from the local SwiftData
store, iOS device-backup eligibility, and continuous sync.

</details>

<details>
<summary><code>Sync/</code> — continuous CloudKit propagation (version 1.2)</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| ⚠️ | `JournalSyncService.swift` | Owns the future sync lifecycle, checkpoints, cancellation, and convergence after architecture and policy are approved. |
| ⚠️ | `StructuredDataSync.swift` | Synchronizes entry metadata, transcripts, insights, summaries, reflections, and deletions. |
| ⚠️ | `AudioAssetSync.swift` | Transfers and verifies original recordings independently of structured records. |
| ⚠️ | `ConflictResolver.swift` | Applies the approved deterministic conflict, tombstone, and deletion policy. |
| ⚠️ | `CloudKit/` | Sync-specific records, subscriptions, checkpoints, and transfer adapters. |

Do not reuse the Cloud Backup generation workflow as continuous synchronization.
Share a lower-level primitive only after real reuse and compatible invariants are
demonstrated.

</details>

<details>
<summary><code>PrivateCloudCompute/</code> — optional yearly-reflection enhancement (version 1.3)</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| ⚠️ | `PCCAvailability.swift` | Checks API, OS, device, region, language, entitlement, model, and network eligibility. |
| ⚠️ | `PCCConsentStore.swift` | Persists narrowly scoped PCC consent separately from backup and sync consent. |
| ⚠️ | `PCCYearlyReflectionGenerator.swift` | Sends only an explicitly previewed bounded payload, validates returned source IDs, and supports on-device fallback. |

Do not create this folder until the PCC feasibility phase records a go decision
and the privacy, API, entitlement, and App Store requirements are satisfied.

</details>

</details>

<details>
<summary><strong><code>Unscripted/DesignSystem/</code></strong> — reused semantic visuals</summary>

Only visuals reused by otherwise independent features belong here. A component
used only within one feature stays in that feature's `Components/` folder.

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `Components/` | Cross-feature semantic presentation components. |
| 🗓️ | `Components/AsyncStateView.swift` | Shared layout for applicable progress, content, and failure presentation without replacing feature state enums. |
| 🗓️ | `Components/EmptyStateView.swift` | Accessible empty state with heading, explanation, and optional action. |
| 🗓️ | `Components/ErrorStateView.swift` | Recoverable error presentation explaining data safety and the next useful action. |
| 🗓️ | `Components/PrivacyPlaceholderView.swift` | Generic locked or redacted presentation containing no journal content. |
| 🗓️ | `Colors/AppColor.swift` | Semantic color names backed by system colors, materials, or asset-catalog colors. |
| 🗓️ | `Typography/AppTypography.swift` | Semantic SwiftUI text treatments that preserve Dynamic Type and accessibility sizes. |
| 🗓️ | `Theming/AppTheme.swift` | Optional composition of related visual tokens if a real theme abstraction becomes necessary; never a mutable global style bag. |
| 🗓️ | `Icons/AppIcon.swift` | Semantic mapping from app concepts to SF Symbols or approved custom assets. |
| ⚠️ | `Effects/AppGlassStyle.swift` | Reused restrained Liquid Glass treatment with accessibility fallbacks, added only after real reuse and validation. |

Raw custom colors and image resources remain in `Assets.xcassets`. Prefer system
fonts, semantic colors, SF Symbols, and native controls before custom assets.

</details>

<details>
<summary><strong><code>Unscripted/Extensions/</code></strong> — focused native-type extensions</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `TypeName+Extensions.swift` | Naming convention for one narrow native-type extension, such as `Date+JournalGrouping.swift`. |

Domain concepts and multi-type helper logic do not belong here.

</details>

<details>
<summary><strong>App-target resources and configuration</strong></summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| ✅ | `Unscripted/Assets.xcassets/` | App icon, accent color, custom semantic colors, and approved custom images. |
| 🗓️ | `Unscripted/Localizable.xcstrings` | User-visible localized copy, including privacy, permission, generated-content, error, and purchase language. |
| ✅ | `Unscripted/Info.plist` | System metadata and narrowly required purpose strings. It remains a target-membership exception. |
| ✅ | `Unscripted/Unscripted.entitlements` | Apple capabilities. Add or change entries only when explicitly required by implemented behavior. |

</details>

<details>
<summary><strong><code>UnscriptedLiveActivity/</code></strong> — planned WidgetKit extension target (version 1.1)</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🗓️ | `RecordingActivityAttributes.swift` | Defines privacy-safe ActivityKit attributes and dynamic state shared with the app target where necessary. |
| 🗓️ | `RecordingActivityWidget.swift` | Registers the Live Activity configuration. |
| 🗓️ | `RecordingActivityView.swift` | Renders generic recording state on the Lock Screen and supported Dynamic Island regions. |
| 🗓️ | `Assets.xcassets/` | Extension-specific resources containing no journal content. |

This is a real target boundary and should be added only during the Live Activity
phase. Its UI exposes only generic state approved by App Lock policy.

</details>

<details>
<summary><strong><code>UnscriptedTests/</code></strong> — Swift Testing unit and integration coverage</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🧹 | `UnscriptedTests.swift` | Current placeholder test file. Replace rather than copy its structure. |
| 🗓️ | `Domain/` | Pure identity, state transition, provenance, validation, and calendar-policy tests. |
| 🗓️ | `Features/` | `@MainActor` presentation-model tests using injected test capabilities. |
| 🗓️ | `Services/` | Persistence, file, audio-state, transcription, generation, search, export, backup, and sync integration tests. |
| 🗓️ | `Extensions/` | Focused tests mirroring production native-type extensions. |
| 🗓️ | `SyntheticFixtures/` | Clearly synthetic entries, transcripts, audio metadata, model outputs, stores, exports, and manifests. |

Tests mirror the production ownership path when practical. Test doubles stay
beside their consumer until genuine cross-feature reuse appears.

</details>

<details>
<summary><strong><code>UnscriptedUITests/</code></strong> — XCUITest journeys and system-facing presentation</summary>

| Status | Path | Responsibility |
| --- | --- | --- |
| 🧹 | `UnscriptedUITests.swift` | Current placeholder UI test file. |
| 🧹 | `UnscriptedUITestsLaunchTests.swift` | Current placeholder launch/screenshot test file. |
| 🗓️ | `Journeys/` | Critical recording, journal, transcript, insight, reflection, export, purchase, backup, and recovery journeys. |
| 🗓️ | `Accessibility/` | UI checks for semantic identifiers, large text scenarios, accessibility structure, and alternative actions. |
| 🗓️ | `Launch/` | First launch, restoration, locked launch, permission state, and synthetic fixture configurations. |
| 🗓️ | `Screens/` | Page objects that encapsulate stable accessibility identifiers and actions without product logic. |

UI tests, previews, screenshots, and performance fixtures use synthetic journal
content only.

</details>

## Common placement decisions

| Type of code | Destination |
| --- | --- |
| App-wide route, tab, deep link, or root shell | `App/Navigation/` |
| App-wide lock/redaction gate | `App/Privacy/` |
| Feature-only SwiftUI component | `Features/<Feature>/Components/` |
| Component reused by independent features | `DesignSystem/Components/` |
| `@MainActor @Observable` presentation state | Beside its owning feature view |
| Framework-independent identity, state, snapshot, or policy | `Domain/<Capability>/` |
| SwiftData `@Model` record | `Services/Persistence/Models/` |
| SwiftData schema or migration | `Services/Persistence/Schema/` or `Migrations/` |
| Foundation Models structured-output type | `Services/Intelligence/Models/` |
| On-device generation owner | Capability folder under `Services/Intelligence/` |
| AVFoundation, Speech, StoreKit, LocalAuthentication, or CloudKit adapter | Matching capability under `Services/` |
| Raw color or custom image resource | `Assets.xcassets` |
| Semantic color, typography, icon, theme, or reused effect | Matching `DesignSystem/` folder |
| Focused extension to `Date`, `URL`, or another native type | `Extensions/TypeName+Extensions.swift` |

The word “model” can refer to several different things and does not determine
placement by itself:

- A view/presentation model stays in `Features`.
- A framework-independent domain value stays in `Domain`.
- A SwiftData model stays in `Services/Persistence/Models`.
- A Foundation Models output schema stays in
  `Services/Intelligence/Models`.

## Growth and review rules

Before adding or moving a path:

1. Confirm the roadmap phase and observable behavior being implemented.
2. Identify the state owner and the narrow dependency seams.
3. Check privacy/network, data preservation, concurrency, scale, accessibility,
   and physical-device implications.
4. Create only the folders and files needed for the focused change.
5. Mirror tests at the lowest reliable layer.
6. Update this map's status markers without marking adjacent roadmap work as
   implemented.

When a file appears to fit several places, place it according to ownership:

- Presentation belongs to the narrowest feature.
- Shared meaning and policy belong to the domain.
- Framework calls and mutable non-UI state belong to services.
- App-wide wiring and routing belong to the app shell.
- Visual reuse alone belongs to the design system.

Do not create a new target, package, shared abstraction, theme system, or common
service without a demonstrated ownership, reuse, or dependency boundary.
