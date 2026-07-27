# Data and Privacy

## When this guide is required

Read this guide before changing persistence, SwiftData models, journal files,
recording finalization, deletion, local search, transcription or generated
content, export/restore, StoreKit or entitlement state, App Lock security or
Keychain data, device-backup eligibility, CloudKit, Private Cloud Compute, or
sync.

Also read [Concurrency and Audio](ConcurrencyAndAudio.md) for isolation,
recording ownership, or asynchronous derived work, and
[Testing and Validation](TestingAndValidation.md) before verification.

The root [AGENTS.md](../../AGENTS.md) and README product/privacy contracts remain
authoritative. Ask rather than inventing a missing decision that changes
transmission, migration compatibility, retention, restore, or destructive
behavior.

## Non-negotiable invariants

- Audio, titles, transcripts, moods, tags, summaries, reflections, prompts,
  source links, search data, and derived metadata are sensitive journal content.
- Journal content stays on device unless the user explicitly enables a clearly
  explained network-backed feature.
- Entitlements and capabilities do not constitute consent or authorize transfer.
- Original recordings and user edits are irreplaceable. Derived work never
  corrupts, overwrites, or deletes them.
- Never recover from a store, migration, file, or restore failure by silently
  deleting data or recreating the journal.
- Preserve valid partial recordings and the last known-good artifact where
  recovery is possible.
- Complete export remains available regardless of trial or purchase state.
  Existing content remains readable, playable, searchable, exportable, and
  deletable.
- Recording, playback, editing, browsing, and export work without Speech assets,
  Apple Intelligence, CloudKit, or Private Cloud Compute.
- Never place real journal content in logs, signposts, diagnostics, crash
  reports, test output, identifiers, filenames, screenshots, or fixtures.
- Cross-resource work is crash-safe, idempotent, bounded, and recoverable, with
  explicit staging, validation, commit, compensation, retry, and cleanup.

## Privacy and network boundaries

- Do not add ads, analytics, tracking, a developer backend, or a required app
  account.
- Use Apple SDKs only. A third-party dependency requires the user to explicitly
  revise that contract and review necessity, data flow, consent, security,
  maintenance, licensing, binary size, offline behavior, and removal.
- Asset downloads may use Apple services but never upload journal content.
- StoreKit receives only entitlement-lifecycle information, never journal data.
- Device backup, Cloud Backup, cross-device sync, and Private Cloud Compute are
  distinct features with distinct explanations and consent.
- Declining or disabling a network-backed feature never makes the local journal
  unusable.
- Verify an Apple API's actual processing location, network behavior, retention,
  availability, and fallback. Never infer "on device" from its framework name.
- App Lock controls presentation; it is not encryption. Secrets belong in
  Keychain, not files or `UserDefaults`.

## SwiftData ownership and local isolation

- Replace `Item` with deliberate source, derived, and relationship models rather
  than a catch-all.
- Give records stable app-level IDs independent of SwiftData implementation
  identity.
- Give persistence writes one isolated owner, normally an actor or `@ModelActor`.
  Views do not coordinate file/database transactions.
- Never pass `ModelContext` or a live `@Model` across actors. Pass stable IDs or
  immutable `Sendable` snapshots and refetch in the owning context.
- Use explicit saves at transaction/publication boundaries; do not rely on
  autosave for file/database consistency.
- Handle store-open and save failures as recoverable states. Preserve the store
  for retry, export, or diagnosis; do not terminate or reset it.
- Every configuration that can contain local journal data must explicitly set
  `cloudKitDatabase: .none`, including app, preview, and test configurations.
- Existing CloudKit/push entitlements neither implement a feature nor authorize
  transmission. SwiftData `.automatic` discovery is unsafe for the local store.
- Future Cloud Backup and sync use separate consented adapters, never automatic
  SwiftData mirroring.

## Schemas and migrations

- Introduce deliberate versioned schemas before persisted data must survive
  distribution.
- Once a schema reaches TestFlight, users, or another durable store, every change
  requires a forward-migration decision and representative fixtures from each
  supported source version.
- Preserve stable IDs, revisions, relationships, file references, provenance,
  and user edits.
- Migration failure leaves the original store or a safe staged copy intact.
  Never automatically delete/recreate it and do not assume downgrade support.
- Before distribution, a destructive development reset is acceptable only with
  explicit agreement and no durable data requiring preservation.
- Consider export decoding, backup compatibility, search-index rebuilding,
  derived invalidation, and mixed app versions with every schema change.
- Keep adapters at schema boundaries so local models do not become export,
  backup, or sync representations.

## Journal files and cross-resource transactions

- Store recordings as protected files in a dedicated journal root, not SwiftData
  blobs.
- Persist relative paths or opaque file IDs, never absolute container URLs or
  content-derived filenames.
- Use the least-permissive Data Protection compatible with recording while
  locked, and verify it on a physical device.
- Exclude the journal root from device backup by default. Eligibility changes
  cover existing and future artifacts, are reversible, and reflect applied state.
- Stage recordings on the same filesystem as their final location with the
  intended Data Protection and backup policy.
- Finalize by closing and validating the recording, atomically renaming it, then
  publishing its durable database row.
- Define launch recovery for every interruption point, including valid orphaned
  recordings and incomplete staging.
- Free-space checks are advisory. Handle `ENOSPC` at every write, flush, close,
  validation, move, save, export, and restore boundary.
- SwiftData and file operations are not one transaction. Document ordering,
  commit point, compensation, retry identity, and idempotent cleanup.
- Deletion covers metadata, original files, derived artifacts, search data, and
  provenance; interruption and repeated cleanup remain safe.
- Distinguish disposable generated suggestions from accepted or user-edited
  content and define invalidation behavior explicitly.
- Protect plaintext staging with opaque names, Data Protection, backup exclusion,
  bounded lifetime, and cleanup after success, cancellation, failure, or crash.

## Derived data and model provenance

- Start transcription only after recording finalization. Its failure or
  cancellation never affects audio durability.
- Treat every model output as untrusted. Validate structure, IDs, revisions,
  duplicates, period/context membership, and size before display or persistence.
- Persist:
  - stable source IDs and exact revisions;
  - transitive source IDs for reflections;
  - app-owned inference, prompt, format, and chunking versions;
  - on-device or explicitly enabled PCC processing mode; and
  - a model identifier only when the OS exposes one.
- Never invent a framework model version.
- Bound inputs, outputs, chunks, task counts, buffers, and retries
  deterministically. Split oversized inputs at stable boundaries.
- Attach a generation ID and revalidate source existence, revision, operation
  identity, cancellation, and deletion state after suspension before commit.
- Mark derived results stale when sources change. Cascade invalidation through
  transitive dependencies and make cleanup idempotent.
- Reject deleted, unknown, stale, duplicate, or out-of-period sources.
- User-visible generated content is identifiable, editable, regenerable, and
  deletable. It is a suggestion, not truth or a medical assessment.
- Internal derived artifacts may be invalidated/regenerated without invented UI.
- Availability, locale, missing assets, refusal, cancellation, over-budget input,
  malformed output, and failure require explicit fallback and retry behavior.

## Scalability and local search

- Stream, page, or batch unbounded recordings, journals, exports, backups,
  restores, and model inputs.
- Bound fetches, task width, buffers, retries, and in-flight operations; apply
  backpressure.
- Keep journal-list records lightweight. Sort/filter in storage with stable
  ordering and a deterministic tie-breaker.
- Add indexes for established query patterns and verify them against
  representative large journals. Do not extend the starter's unbounded `@Query`.
- Avoid whole-recording `Data(contentsOf:)`.
- Persist semantic milestones, not waveform samples, playback ticks, or frequent
  progress.
- Use explicit calendar, locale, and time zone for periods. Never assume a
  24-hour day.
- Keep search local, private, and rebuildable. Never publish journal text to
  Spotlight or another system-wide index.
- Update/rebuild the index after source edits, invalidation, and deletion; the
  journal remains source of truth.

## Export and restore

- Build export from a consistent journal snapshot.
- Use a documented, versioned UTF-8 JSON manifest with schema/app versions,
  stable IDs, relationships, provenance, timestamps, deterministic paths, media
  types, sizes, and SHA-256 checksums.
- Include original audio unchanged plus readable UTF-8 entry/reflection content,
  accepted transcripts, user-edited moods/tags, summaries, and source links.
  Exclude purchase and authentication state.
- Validate protected staging before atomic publication to the chosen system
  exporter. Keep it alive only as long as required and clean it after every exit.
- Test decoding with an independent reader, not only the app's encoder.
- Restore validates compatibility, completeness, checksums, media, and
  referential integrity before activation.
- Import into staging/a temporary store and preserve the existing journal until
  replacement validates and commits.
- Restore into a nonempty journal is unresolved. Never silently merge, replace,
  or delete; ask for the approved policy.

## StoreKit and entitlements

- StoreKit is limited to entitlement lifecycle data and never receives journal
  content.
- Accept only verified transactions. Treat verification failure as untrusted
  input and do not grant access from it.
- Give entitlement state one long-lived owner. At launch, reconcile current
  entitlements and unfinished transactions, and maintain an owned
  `Transaction.updates` listener with deterministic teardown.
- Purchase and restore presentation require explicit user intent. Never
  automatically present purchase UI or pressure a user after cancellation.
- Model pending, cancellation, offline, restore, verification, and failure states
  explicitly, with a useful local fallback.
- Trial or purchase state may gate only approved optional features. Existing
  content and complete export remain readable, playable, searchable, exportable,
  and deletable.
- Keep StoreKit fixtures synthetic and label sandbox/device validation separately
  from deterministic tests.

## Backup and sync terminology

- **Device backup:** iOS-managed eligibility. Unscripted cannot prove creation or
  retention.
- **Cloud Backup:** planned app-managed, versioned recovery generations in the
  user's private CloudKit database.
- **Cross-device sync:** later continuous propagation of edits/deletions. It is
  not backup.
- **Private Cloud Compute:** separate optional processing, not backup or sync.

Do not claim that enabling eligibility creates a backup, disabling it deletes an
existing backup, or backup is sync.

## Cloud Backup, sync, and PCC

- Cloud Backup remains off by default and separate from local SwiftData.
- Use the private database and a custom record zone. Mark sensitive fields
  encrypted before schema promotion and expose minimal management metadata.
- Prove that capabilities, adapter initialization, and account checks transmit no
  journal content before opt-in.
- Preserve local use through sign-out, restriction, account changes, quota,
  offline state, cancellation, and service errors.
- Transfer uploads and downloads in deterministic, idempotent, resumable batches.
  Chunk large assets with ordering, size, type, and per-chunk/whole-file SHA-256
  checksums; validate them before reassembly or publication.
- Publish a generation manifest only after all required records/assets verify.
  Incomplete generations are never restorable.
- Restore only complete compatible generations through deterministic resumable
  download, checksum and referential-integrity validation, protected staging,
  and atomic activation; preserve the previous journal if activation fails.
- Prune an older generation only after a newer complete generation verifies.
- Retention, cloud deletion on disable, and nonempty restore remain product
  decisions. Ask before implementing them.
- Sync separately requires approved identity, ordering, conflicts, deletion,
  invalidation, opt-out, backup coexistence, and deterministic convergence.
- Private Cloud Compute remains off by default. Preview bounded transmitted data
  before consent, persist processing mode, validate returned source IDs, and
  provide offline/refusal/timeout/quota/cancellation/on-device fallback.

## Verification checklist

Follow [Testing and Validation](TestingAndValidation.md) and use synthetic data.
Cover applicable:

- local-store CloudKit isolation, save/open/reopen failure, and recovery;
- every supported migration with on-disk fixtures;
- interruption at cross-resource commit boundaries and repeated cleanup;
- `ENOSPC` at write/finalization/export/restore boundaries;
- Data Protection and backup attributes on a locked physical iPhone;
- cascade deletion and prevention of stale commits;
- empty, long, edited, deleted, refused, malformed, and over-budget model inputs;
- large-journal bounds, ordering, memory, and index rebuilding;
- export cancellation, checksums, atomic publication, and independent decoding;
- verified/unverified StoreKit transactions, launch reconciliation, update
  listening, pending/cancellation/offline states, and export availability;
- opt-in boundaries, incomplete backups, damaged assets, quota, schema mismatch,
  and failed restore activation; and
- absence of journal content from diagnostics, identifiers, fixtures, filenames,
  and external surfaces.

Every handoff reports privacy/network/entitlement impact, schema/migration impact,
file transaction and recovery, export/backup compatibility, provenance and
invalidation, scalability bounds, exact validation, and missing device/CloudKit
evidence.
