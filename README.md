# Unscripted

> **Status:** Early development. The roadmap below describes planned work, not the
> current capabilities of the app. **Unscripted** is a working title; the final App
> Store name has not been selected.

Unscripted is a private, local-first voice journal launching on iPhone. It turns
spoken entries into editable transcripts, optional mood and tag suggestions,
and periodic reflections using Apple frameworks.

Unscripted has no ads, analytics, tracking, third-party SDKs, required account, or
developer-operated backend. Unscripted does not send journal content over the
network by default. Network access is limited to Apple services for required
asset downloads, user-initiated StoreKit trial and purchase actions, explicitly
enabled **Cloud Backup** or future cross-device sync, and explicitly enabled
Private Cloud Compute.

Apple-provided speech and intelligence assets may need to be downloaded before
some on-device features become available. These asset downloads do not upload
journal content.

iOS-managed device backups are separate from Unscripted's planned, app-managed
CloudKit backup. Local journal storage is excluded from device backups by
default. The user can opt in through an **Include in Device Backups** setting,
which makes the data eligible for backup; actual backup still depends on the
device's iOS, iCloud, and per-app backup settings. Without backup inclusion, an
export, or the post-launch CloudKit backup, losing the device or deleting the app
can permanently lose the journal.

## Product Principles

- **Private by default:** Unscripted does not transmit recordings or derived journal
  data unless the user enables a clearly explained network-backed feature.
- **Useful without AI:** Recording, playback, editing, and browsing continue to
  work when Apple Intelligence is unavailable.
- **No app account required:** CloudKit features use the device's iCloud account
  and do not require Sign in with Apple.
- **User-controlled insights:** Mood labels, tags, and reflections are
  suggestions that the user can edit, regenerate, or delete. They are not
  medical or mental-health assessments.
- **Traceable reflections:** Every generated reflection section identifies its
  contributing journal entries, and the user can open those sources. The app
  rejects missing or out-of-period source references. Source links expose the
  model's inputs; they do not prove that its interpretation is correct.
- **User-owned data:** A complete export remains available regardless of trial
  or purchase state and uses documented, durable formats instead of a
  proprietary-only archive.
- **Graceful degradation:** Unsupported languages, missing model assets, denied
  permissions, and unavailable network services have explicit fallback states.

## Planned Features

### Version 1.0

- Record audio and preserve completed or interrupted recordings locally,
  including when the device locks. Calls, system interruptions, and route
  changes must never silently discard or corrupt captured audio.
- Store audio files in the app's private container and persist journal metadata
  with SwiftData.
- Browse entries in a reverse-chronological journal and rename or delete a
  recording.
- Play, pause, and seek through recordings with elapsed time, duration, and
  progress.
- Show privacy-safe playback information and controls on the Lock Screen and in
  Control Center when permitted by the App Lock policy.
- Automatically transcribe a completed recording on device with the Speech
  framework.
- Review, edit, copy, and save a transcript without risking the original
  recording if transcription fails.
- Browse a calendar that marks dates containing journal entries.
- Optionally include local journal data in OS-managed device backups; keep it
  excluded by default.
- Protect the journal with an optional Face ID or device-passcode App Lock.
- Suggest editable mood labels and tags on device with Apple Intelligence.
- Create a bounded on-device summary for each accepted transcript to support
  longer reflections.
- Generate private weekly and monthly reflections from past journal entries,
  with each section linked to the entries used to generate it.
- Schedule optional local reminders to generate or review weekly and monthly
  reflections.
- Search titles, transcripts, tags, and reflections locally.
- Export all original audio and structured journal data in documented, durable
  formats.
- Explain permissions and privacy through onboarding and contextual tooltips.
- Support Light and Dark appearances, Dynamic Type, VoiceOver, Reduce Motion,
  and a restrained Liquid Glass design.
- Support a clearly disclosed trial followed by a one-time Full Unlock. Existing
  journal content remains readable, playable, searchable, exportable, and
  deletable if the trial ends.

### Version 1.1

- Show active recording status with a Live Activity on the Lock Screen and, on
  supported devices, in the Dynamic Island.
- Add explicit, opt-in CloudKit backup and restore for the complete journal,
  including audio. This is recovery-oriented backup, not continuous
  cross-device synchronization.

### Version 1.2

- Add an iPad experience with adaptive layouts, keyboard support, and
  multitasking.
- After the iPad app is usable, optionally synchronize journal data across the
  user's devices with CloudKit.

### Version 1.3

- Generate yearly reflections from bounded per-entry summaries and weekly and
  monthly reflections, with links back to source entries.
- Optionally use Private Cloud Compute for stronger yearly-reflection reasoning
  and a larger context window when the API, entitlement, device, region, and
  network are available.

### Later

- Evaluate richer visual effects only when they improve the journaling
  experience without compromising accessibility, battery life, or performance.

## Privacy Model

| Capability | Default processing | Network use |
| --- | --- | --- |
| Recording and playback | On device | None |
| Transcription | On device | Apple speech assets may need to be downloaded |
| Mood and tag suggestions | On device | Apple Intelligence assets may need to be downloaded |
| Weekly and monthly reflections | On device | None after required assets are present |
| Complete export | On device | Only the destination explicitly chosen by the user |
| Trial and Full Unlock | StoreKit entitlement state on device | App Store services for trial, purchase, and restoration |
| iOS device backup | Excluded | Eligible only after explicit opt-in; actual backup is controlled by iOS |
| CloudKit backup and restore | Disabled and post-launch | User's private CloudKit database, only after explicit opt-in |
| Cross-device sync | Disabled and post-iPad | CloudKit, only after explicit opt-in |
| Yearly reflection with Private Cloud Compute | Disabled and post-launch | PCC, only after explicit opt-in |

Disabling a network-backed feature must not make the local journal unusable.
The precise retention and deletion behavior for disabling CloudKit backup or
cross-device sync will be defined and tested before either feature ships.
Disabling backup inclusion affects future backup eligibility; the app must not
claim that it immediately removes data already held in an existing device
backup.

### Backup, Restore, and Sync Terminology

- **Device backup** is managed by iOS. Unscripted can make its local journal eligible
  or ineligible, but cannot guarantee that iOS creates or retains a backup.
- **Cloud Backup** is Unscripted's planned CloudKit feature. It creates explicit,
  versioned recovery generations in the user's private database and provides a
  deliberate restore flow.
- **Cross-device sync** continuously propagates edits and deletions between
  active devices. It is a separate, later feature that follows the iPad
  experience.

## Technology

Unscripted uses Apple SDKs only:

- iPhone with iOS 26 or later for version 1.0; iPadOS support is planned for
  version 1.2
- Swift 6.2+ in Swift 6 language mode
- SwiftUI for the interface
- SwiftData for structured local data
- AVFoundation and protected app-container files for audio capture, storage,
  and playback
- Speech framework with `SpeechAnalyzer` and `SpeechTranscriber` for
  post-recording transcription
- Foundation Models for availability-gated, on-device intelligence
- LocalAuthentication for App Lock
- MediaPlayer for Now Playing information and remote playback controls
- UserNotifications for local reflection reminders
- CryptoKit for export and backup integrity checks
- StoreKit 2 for the trial, one-time Full Unlock, and purchase restoration
- ActivityKit and WidgetKit for the post-launch recording Live Activity
- CloudKit private databases and `CKAsset` for post-launch, opt-in backup and
  restore, followed later by cross-device sync
- Private Cloud Compute for a post-launch, iOS 27+ yearly-reflection enhancement,
  subject to API stability and managed-entitlement eligibility
- Swift Testing for unit and integration tests, with XCUITest for critical user
  journeys

Metal is not a baseline dependency. SwiftUI and system frameworks remain the
default; Metal will be considered only for a concrete effect that cannot be
delivered efficiently otherwise.

## Roadmap

Items within each phase are listed in execution order. Each phase is intended to
be independently reviewable, testable, and small enough to complete without
mixing unrelated product work.

### Version 1.0 — Local-first App Store Release

#### Phase 1 — Project Baseline and Architecture

1. Align the project with the version 1.0 iPhone-only, iOS 26+, Swift 6.2+
   baseline.
2. Define the entry lifecycle: recording, saved audio, transcript draft,
   accepted transcript, per-entry summary, insights, and reflections.
3. Document permissions, capability checks, unavailable states, and low-storage
   behavior.
4. Choose concurrency boundaries for recording, playback, transcription, and
   persistence services.
5. Design a versioned local schema that can support later backup and sync
   adapters without making the local journal dependent on either.

#### Phase 2 — Data Ownership, Derivation, and Portability Contracts

1. Inventory every original and derived data type and its on-device location.
2. Map every permitted network boundary and the user action that enables it.
3. Define OS-managed device-backup behavior: excluded by default, eligible only
   after explicit opt-in, and still governed by system settings.
4. Define post-launch CloudKit backup as versioned recovery snapshots, not
   automatic SwiftData mirroring or continuous device sync.
5. Define stable source identifiers, revisions, transitive provenance, and
   invalidation rules for all derived data.
6. Specify the durable export format, schema-version policy, and minimum
   contents.
7. Define which operations remain available after a trial ends and how complete
   local and cloud deletion behave.

#### Phase 3 — Local Persistence

1. Define the initial SwiftData recording and transcript models.
2. Create a dedicated journal-storage root with an iOS Data Protection class
   compatible with recording while locked.
3. Place the SwiftData store and private audio-file store under that root, with
   atomic audio finalization.
4. Exclude the journal root from device backups by default and implement
   reversible backup eligibility for current and future data.
5. Add create, fetch, rename, and delete operations.
6. Remove associated audio when an entry is deleted and clean up orphaned or
   incomplete files safely.
7. Test persistence, file protection, both backup-setting states, deletion,
   recovery, and the first schema migration.

#### Phase 4 — Interruption-safe Audio Recording

1. Add just-in-time microphone permission handling.
2. Configure the audio session, recording format, and explicit interruption
   policy.
3. Enable and validate the background-audio capability required for supported
   locked-device recording and playback.
4. Implement a single recording service and state machine, including
   interrupted and finalizing states.
5. Build start, stop, elapsed-time, and failure-state UI.
6. Observe calls, Siri and other system interruptions, audio-route changes,
   device locking, and supported background execution.
7. Preserve and atomically finalize valid audio captured before an unrecoverable
   interruption; resume only when the documented policy and system state permit
   it.
8. Create the durable journal entry only after audio finalization succeeds.
9. Validate short, long, interrupted, Bluetooth-disconnected, locked, and
   low-storage recordings on physical devices.

#### Phase 5 — Journal Library

1. Display saved entries in reverse chronological order.
2. Add empty, loading, and recoverable error states.
3. Build an entry-detail destination with recording metadata.
4. Add recording renaming.
5. Add confirmed deletion with complete cleanup of the entry's current direct
   data.
6. Test the journal's create, rename, navigation, and delete flows.

#### Phase 6 — In-app Playback

1. Implement a single source of truth for player state.
2. Add play, pause, seek, elapsed time, duration, and progress.
3. Connect playback controls to entry rows and the entry-detail screen.
4. Pause cleanly and preserve position across calls, system interruptions,
   output-route changes, and switching recordings.
5. Restore playback only when the system permits it and the documented policy
   matches user intent.
6. Test player state transitions, interruption recovery, progress accuracy, and
   resource cleanup.

#### Phase 7 — System Playback Controls

1. Extend the validated audio-session and background configuration for Now
   Playing publication and remote commands.
2. Publish generic recording metadata and progress through Now Playing without
   exposing a user-entered title.
3. Handle play, pause, and seek commands from the Lock Screen and Control
   Center.
4. Exclude private recordings from unrelated system media suggestions.
5. Test locked-device playback, headphones, route changes, and interruptions.

#### Phase 8 — Post-recording Transcription

1. Detect supported locales, device capabilities, and required speech assets.
2. Request and handle speech-recognition authorization when required.
3. Explain and initiate any required Apple speech-asset download.
4. Model queued, running, failed, cancelled, and retryable transcription states.
5. Start transcription only after the recording file has been finalized.
6. Transcribe the saved file with `SpeechAnalyzer` and `SpeechTranscriber`.
7. Persist the transcript draft without coupling its success to audio
   persistence.
8. Test denied authorization, unsupported locales, missing assets, long
   recordings, cancellation, and retry.

#### Phase 9 — Transcript Review

1. Present the generated transcript as an editable draft.
2. Add copy, save, retry, and discard actions with clear consequences.
3. Allow an accepted transcript to be edited again from the entry-detail screen.
4. Preserve explicit empty, processing, failed, and saved states.
5. Test editing, copying, saving, discarding, and relaunch restoration.

#### Phase 10 — Calendar Browsing

1. Derive entry dates from the stored journal.
2. Mark days that contain one or more entries.
3. Show the entries for a selected date.
4. Connect calendar results to entry details.
5. Test locale, time-zone, daylight-saving, and date-boundary behavior.

#### Phase 11 — Privacy Settings and Local Data Controls

1. Build a settings destination for privacy and local-data controls.
2. Add an **Include in Device Backups** toggle that is off by default.
3. Explain that enabling it makes journal data eligible but cannot override
   disabled iOS, iCloud, or per-app backup settings.
4. Keep notification previews generic by default.
5. Add a confirmed action that deletes every local recording and derived
   journal artifact.
6. Test both backup states, cancellation, partial cleanup recovery, and a full
   return to the empty state.

#### Phase 12 — App Lock

1. Add an opt-in App Lock setting independent of any account.
2. Authenticate with LocalAuthentication using Face ID and device-passcode
   fallback.
3. Define and implement launch, foreground, and grace-period relocking behavior.
4. Pause playback, clear Now Playing metadata, and disable external playback
   commands whenever App Lock engages.
5. Obscure journal content in app-switcher snapshots.
6. Test active playback, device locking, unavailable biometrics, cancellation,
   fallback, and recovery.

#### Phase 13 — On-device Mood and Tag Suggestions

1. Gate the feature by Apple Intelligence, model, locale, and device
   availability.
2. Define structured, versioned output for a suggested mood and tags.
3. Generate suggestions only from an accepted transcript.
4. Let the user accept, edit, remove, or regenerate every suggestion.
5. Persist the source transcript revision and model/prompt version.
6. Invalidate or regenerate suggestions after the source transcript changes or
   its entry is deleted.
7. Evaluate representative inputs and test unavailable, refused, stale, and
   failed generations.

#### Phase 14 — Per-entry Transcript Summaries

1. Define deterministic input and output context budgets plus a versioned
   summary format for an accepted transcript.
2. Split over-budget transcripts at stable boundaries and summarize chunks
   hierarchically before producing the bounded final summary.
3. Generate the summary on device without blocking transcript saving.
4. Persist the source entry identifier, transcript revision, chunking strategy,
   and model/prompt version.
5. Add queued, failed, retry, and regenerate states.
6. Invalidate the summary and dependent reflections when its source transcript
   changes or the entry is deleted.
7. Test short, long, over-budget, empty, edited, deleted, refused, and failed
   inputs.

#### Phase 15 — Weekly Reflections

1. Define weekly calendar boundaries and minimum-entry eligibility.
2. Build bounded input from current per-entry summaries, each labeled with its
   stable source entry identifier.
3. Define structured reflection sections that return only contributing source
   identifiers from the supplied input.
4. Generate a weekly reflection on demand while the app is active.
5. Reject missing, unknown, duplicate, or out-of-period source references before
   displaying a result.
6. Persist the validated source identifiers, revisions, and model/prompt
   version for every section.
7. Mark a reflection stale when a source changes or is deleted, then offer
   regeneration.
8. Test sparse weeks, time zones, context limits, invalid source output,
   unavailable models, and partial failures.

#### Phase 16 — Monthly Reflections

1. Define monthly calendar boundaries and minimum-entry eligibility.
2. Build bounded input from current weekly reflections and per-entry summaries.
3. Resolve all transitive dependencies to original journal-entry identifiers.
4. Generate structured monthly sections whose source references are limited to
   the supplied period.
5. Validate and persist complete section-level source provenance.
6. Mark a reflection stale when a dependency changes or is deleted, then offer
   regeneration.
7. Test sparse months, time zones, context limits, invalid source output,
   unavailable models, and partial failures.

#### Phase 17 — Reflection Experience

1. Build a reflection history grouped by week and month.
2. Show eligible, not-yet-generated, generating, current, stale, and failed
   states.
3. Show source coverage and a **Sources** action for every reflection section.
4. Let the user open each contributing entry directly from the reflection.
5. Add detail, generate, regenerate, and delete actions.
6. Keep generation progress and cancellation usable while the app is active.
7. Test source navigation, deleted sources, navigation restoration, overlapping
   periods, stale dependencies, and deletion.

#### Phase 18 — Local Reflection Reminders

1. Add reminder preferences and request notification permission in context.
2. Schedule weekly reminders using the user's chosen day and time.
3. Schedule monthly reminders using a predictable calendar rule.
4. Word notifications as reminders to generate or review a reflection, never as
   a guarantee that background generation completed.
5. Deep-link a notification into the relevant period's reflection flow.
6. Reschedule safely after preference, time-zone, or calendar changes.
7. Test denied permission, delivery, deep links, and stale reminders.

#### Phase 19 — Local Search

1. Define searchable fields and locale-aware text normalization for titles,
   accepted transcripts, mood labels, tags, and reflections.
2. Build a private, rebuildable local index that never publishes journal text to
   Spotlight or another system-wide index.
3. Add query, empty, recent-query, and clear-query states.
4. Group matching entries and reflections, highlight useful context, and
   navigate to the original content.
5. Update the index after edits, regeneration, invalidation, and deletion.
6. Test diacritics, supported writing systems, stale index recovery, and
   representative large journals.

#### Phase 20 — Complete Durable Export

1. Create a consistent read snapshot so an export cannot mix journal revisions.
2. Write a documented, versioned UTF-8 JSON manifest with app, schema, entry,
   relationship, and provenance metadata.
3. Include each original audio file unchanged and readable UTF-8 Markdown or
   plain-text representations of every entry and reflection.
4. Include accepted transcripts, user-edited moods and tags, summaries,
   reflection source links, and relevant timestamps without exporting purchase
   or authentication state.
5. Add deterministic paths, stable identifiers, media types, byte sizes, and
   SHA-256 checksums to the manifest.
6. Package the result atomically and hand it to the system share or document
   exporter chosen by the user.
7. Keep export available before, during, and after the trial or purchase.
8. Test cancellation, low storage, large journals, checksum verification, and
   decoding with an independent test reader.

#### Phase 21 — Onboarding and Permission Education

1. Explain local storage, default backup exclusion, optional backup inclusion,
   complete export, optional AI, asset downloads, App Lock, and future network
   features.
2. Explain the risk of permanent data loss while no recoverable cloud copy
   exists.
3. Add contextual education before microphone, speech-asset, biometric, and
   notification requests.
4. Add tooltips only where a control or system surface is not self-explanatory.
5. Test first launch, skipped permissions, later recovery, and onboarding
   restoration.

#### Phase 22 — Visual and Accessibility Polish

1. Establish a consistent visual hierarchy using native SwiftUI and restrained
   Liquid Glass.
2. Complete Light and Dark appearance support.
3. Audit Dynamic Type, VoiceOver, contrast, Reduce Motion, and touch targets.
4. Polish empty, loading, progress, error, and recovery states across the app.
5. Validate every primary flow with accessibility settings enabled.

#### Phase 23 — Trial and One-time Full Unlock

1. Decide the trial duration, exact creation limits after expiry, price, and
   which capabilities the Full Unlock enables.
2. Configure a clearly named, zero-price non-consumable trial product and a paid
   non-consumable Full Unlock with StoreKit 2.
3. Define the trial's authoritative start from the verified transaction date,
   plus reinstall, device-change, offline, clock-change, and Apple Account
   behavior.
4. Implement a single entitlement service with signed-transaction validation,
   offline caching, and purchase restoration.
5. Keep existing journal content readable, playable, searchable, exportable,
   and deletable after trial expiry; never hold user data hostage.
6. Add purchase, pending, cancelled, failed, expired-trial, and restored states
   without dark patterns.
7. Validate the complete matrix with StoreKit Test and sandbox accounts.

#### Phase 24 — Release Hardening

1. Exercise denied permissions, low storage, calls, audio-route changes, device
   locking, termination, and unavailable models.
2. Complete unit, integration, UI, migration, and physical-device test matrices.
3. Profile launch, scrolling, transcription, storage growth, battery use, and
   long recordings.
4. Verify backup attributes, Data Protection, App Lock, system playback
   metadata, export integrity, StoreKit entitlements, and cascade deletion on
   physical devices.
5. Finalize usage descriptions, privacy declarations, support material, and App
   Store metadata.
6. Run TestFlight validation and resolve release blockers.
7. Submit version 1.0.

### Version 1.1 — Recording Status and Cloud Backup

#### Phase 25 — Recording Live Activity

1. Define whether App Lock permits the activity and the minimum generic
   recording state and actions allowed outside the app.
2. Add the WidgetKit extension and ActivityKit attributes.
3. Implement Lock Screen and Dynamic Island presentations.
4. Start, update, recover, and end the Live Activity from recorder state.
5. Validate App Lock, devices with and without Dynamic Island, interruptions,
   and termination paths.

#### Phase 26 — Cloud Backup Contract and Prototype

1. Define the recovery objective as complete, versioned backup generations
   rather than a continuously mirrored SwiftData store.
2. Include original audio and all structured journal data in every logically
   complete generation.
3. Decide manual and best-effort automatic triggers, retention limits, disable
   behavior, cloud deletion, and restore behavior for a nonempty local journal.
4. Prototype a custom CloudKit private-database representation using a custom
   zone, encrypted journal-content fields, manifests, records, and `CKAsset`
   audio.
5. Define deterministic asset chunking, whole-file and per-chunk checksums, and
   exact reassembly for recordings above current CloudKit asset limits.
6. Validate iCloud account and keychain requirements, user-quota behavior, large
   recordings, partial uploads, and schema evolution.
7. Record the production design before enabling CloudKit in the shipping app.

#### Phase 27 — CloudKit Backup Foundation and Opt-in

1. Configure the CloudKit container, custom record zone, and development schema.
2. Mark sensitive fields as encrypted before schema promotion and keep only the
   minimum metadata required for record management unencrypted.
3. Keep local SwiftData explicitly independent of automatic CloudKit sync.
4. Add a separate, off-by-default **Cloud Backup** setting with account-status,
   storage-scope, retention, and network-use explanations.
5. Implement stable backup-generation identity and persist local upload state.
6. Add signed-out, restricted, account-changed, quota, network, and service-error
   states.
7. Test that adding CloudKit capabilities never transmits data before opt-in.

#### Phase 28 — Complete Backup Upload

1. Inventory the current journal and estimate the generation's item count and
   payload size.
2. Create a consistent local snapshot without blocking ordinary journal use
   longer than necessary.
3. Upload structured records in deterministic, idempotent, resumable batches.
4. Upload original audio as one or more assets with ordering, byte size, media
   type, and per-chunk and whole-file SHA-256 verification metadata.
5. Preserve the complete local journal throughout the operation.
6. Publish a completed generation manifest only after every required record and
   asset verifies successfully.
7. Surface progress, cancellation boundaries, retry, and recoverable failure
   states.
8. Test interrupted, repeated, partial, low-storage, large-library, and
   version-skewed uploads.

#### Phase 29 — Explicit Backup Restore

1. Discover only completed, compatible backup generations.
2. Show each generation's date, size, source app version, and content coverage
   before restore.
3. Require an explicit replace-or-cancel decision when the local journal is not
   empty; do not silently merge and call it a restore.
4. Download into staging, reassemble chunked assets, verify the manifest,
   checksums, and referential integrity, then import into a temporary local
   store.
5. Atomically activate the restored journal only after full validation.
6. Preserve or recover the previous local journal if activation fails.
7. Test reinstall, replacement iPhone, wrong account, network loss, damaged
   assets, insufficient storage, and incompatible schema versions.

#### Phase 30 — Backup Lifecycle and Version 1.1 Hardening

1. Add manual backup and conservative automatic triggers that run only when iOS
   execution time and current app state permit.
2. Show last successful backup, current progress, incomplete state, and a
   specific recoverable error.
3. Prune old generations only after a newer complete generation verifies.
4. Let the user stop future backups while either retaining or explicitly
   deleting existing CloudKit generations.
5. Test retention, user-deleted zones, cloud deletion, account and iCloud
   Keychain changes, quota exhaustion, mixed app versions, interruption, and
   repeated restore cycles.
6. Promote the CloudKit schema only after destructive backup and restore tests
   pass.
7. Run TestFlight validation and ship version 1.1.

### Version 1.2 — iPad First, Cross-device Sync Second

#### Phase 31 — iPad Foundation

1. Add iPad as a supported device without raising the existing minimum OS.
2. Replace iPhone-specific navigation assumptions with adaptive split-view and
   compact-width patterns.
3. Keep recording, playback, persistence, transcription, and reflection
   services independent of screen size and scene ownership.
4. Define multiwindow rules so two scenes cannot corrupt recorder or player
   state.
5. Add iPad test destinations and validate schema compatibility with existing
   iPhone journals.

#### Phase 32 — iPad Product Experience

1. Adapt the journal, recorder, entry detail, calendar, search, reflections, and
   settings flows for regular and compact widths.
2. Add keyboard shortcuts, focus behavior, pointer interactions, and sensible
   toolbar placement.
3. Validate portrait, landscape, Split View, Stage Manager, external keyboard,
   and external audio routes.
4. Complete iPad accessibility, performance, and physical-device testing.
5. Make the iPad experience release-quality before beginning continuous sync.

#### Phase 33 — Cross-device Sync Contract and Prototype

1. Define how continuous sync coexists with versioned Cloud Backup without
   duplicating storage or presenting ambiguous controls.
2. Define canonical identity, ordering, conflict, deletion, source-invalidation,
   and disable-sync behavior.
3. Select and prototype the CloudKit synchronization architecture separately
   from the backup-generation implementation.
4. Validate two-device edits, offline changes, account changes, large assets,
   and mixed app versions.
5. Commit to production only after the prototype converges deterministically.

#### Phase 34 — Structured Journal Sync

1. Add a distinct, explicit cross-device sync opt-in and migration preview.
2. Migrate existing structured data in deterministic, idempotent batches while
   retaining a complete local copy.
3. Synchronize recording metadata, transcripts, insights, per-entry summaries,
   reflections, and deletions.
4. Propagate source revisions and stale derived data across devices.
5. Surface concise progress, offline, conflict, and recoverable error states.
6. Test concurrent edits, source deletion, cascade invalidation, offline work,
   and eventual convergence.

#### Phase 35 — Audio Asset Sync

1. Implement the validated CloudKit asset strategy for original recordings.
2. Add transfer priority, progress, quota, cancellation, retry, and recoverable
   error states.
3. Verify every downloaded asset before making it the active local recording.
4. Preserve journal browsing while an asset is remote and communicate when
   playback or retranscription requires a download.
5. Test large libraries, interrupted transfers, low local storage, quota
   exhaustion, and repeated device replacement.

#### Phase 36 — Sync Conflicts and Version 1.2 Hardening

1. Resolve duplicate, rename, transcript-edit, derived-data, and deletion
   conflicts consistently.
2. Cascade or invalidate insights and reflections when a source changes on
   another device.
3. Implement the agreed backup/sync relationship and local/cloud retention
   behavior.
4. Stress-test mixed app versions, repeated account changes, three-device
   convergence, opt-out, and re-enable flows.
5. Promote schema changes only after migration, conflict, retention, and
   destructive tests pass.
6. Run TestFlight validation and ship the iPad and sync release.

### Version 1.3 — Source-traceable Yearly Reflections

#### Phase 37 — Yearly Reflection Foundation

1. Define yearly eligibility, coverage, and calendar-boundary rules.
2. Build bounded input from current per-entry summaries and weekly and monthly
   reflections rather than a year of raw transcripts.
3. Resolve every transitive dependency to its original journal-entry identifier
   and enforce a deterministic context budget.
4. Generate a structured on-device yearly reflection whose sections contain
   only supplied source identifiers.
5. Validate source references, then persist exact revisions and model/prompt
   versions for every section.
6. Show source coverage, omitted periods, processing mode, and entry links
   before and after generation.
7. Mark the result stale after source edits or deletion and test sparse,
   incomplete, edited, and deleted source years.

#### Phase 38 — Private Cloud Compute Feasibility

1. Confirm a stable, App Store-eligible API and obtain the managed PCC
   entitlement.
2. Gate the feature to supported iOS versions, devices, regions, languages, and
   current model availability.
3. Define consent copy and the exact bounded, source-labeled payload that may
   leave the device.
4. Compare on-device and PCC output with a fixed quality, traceability, safety,
   and privacy evaluation set.
5. Prototype quota, timeout, offline, refusal, and on-device fallback behavior.
6. Make a documented go/no-go decision before building the shipping experience.

#### Phase 39 — PCC Yearly Reflection Experience

1. Keep on-device yearly generation available and make PCC a separate,
   off-by-default enhancement.
2. Preview the processing mode and bounded data categories before requesting
   explicit consent.
3. Generate with progress and cancellation, then validate every returned source
   identifier against the sent payload.
4. Handle quota, timeout, refusal, network loss, and on-device fallback.
5. Persist exact source provenance and whether processing occurred on device or
   in PCC.
6. Add source navigation, review, regenerate, delete, consent withdrawal, and an
   optional yearly reminder.
7. Test failure recovery, fallback, stale data, invalid source output, and
   cascade deletion.

### Later

#### Phase 40 — Optional Advanced Visuals

1. Define the user-facing outcome and accessibility constraints for a proposed
   effect.
2. Prototype it with SwiftUI, Canvas, or Core Animation first.
3. Profile the prototype on the oldest supported iPhone and iPad.
4. Introduce Metal only if measurements demonstrate a concrete need.
5. Validate battery, thermal behavior, contrast, and Reduce Motion before
   shipping.
