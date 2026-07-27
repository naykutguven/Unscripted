# Concurrency and Audio

## When this guide is required

Read this guide before changing:

- `async`/`await`, tasks, actors, isolation, `Sendable`, `AsyncSequence`,
  continuations, callbacks, locks, queues, or executors;
- SwiftData access across an isolation boundary;
- recording, playback, `AVAudioSession`, routes, interruptions, background or
  locked-device audio, waveform work, Now Playing, or remote commands; or
- transcription or inference lifecycle coordinated with a recording.

Read [Data and Privacy](DataAndPrivacy.md) as well for recording files,
SwiftData transactions, Data Protection, deletion, and atomic finalization.
Read [UI and Accessibility](UIAndAccessibility.md) for permissions, recording
indicators, App Lock presentation, and external surfaces. Follow
[Testing and Validation](TestingAndValidation.md) before verification.

The root [AGENTS.md](../../AGENTS.md) and README product contracts remain
authoritative.

## Concurrency baseline

- Use Swift 6 language mode and retain Swift 6.2 source compatibility.
- Approachable Concurrency, `InferIsolatedConformances`,
  `NonisolatedNonsendingByDefault`, and app-target default `MainActor` isolation
  are part of the design. Do not weaken them.
- Treat every concurrency diagnostic as a design signal. Thread safety is
  correctness, not an optimization.
- Prefer Swift Concurrency over GCD for application-state ownership.

## Isolation and ownership

- Keep views, navigation, presentation models, and UI updates on `MainActor`.
- `Task {}` inherits the caller's actor. Declaring a function `async` does not
  move it off that actor; `nonisolated(nonsending) async` also runs on the
  caller's actor under the enabled settings.
- Give each mutable non-UI subsystem one owner, normally an actor or
  `@ModelActor`. Recorder, player, audio-session state, persistence writes, and
  inference jobs must not have competing sources of truth.
- Stateless CPU-heavy work that must leave the caller may use a narrowly scoped
  Swift 6.2 `@concurrent` function with fully `Sendable` inputs and results.
- Use a worker actor or custom executor when work has mutable ownership or
  specialized scheduling. Revalidate operation identity and source revision
  before committing its result.
- An actor serializes access; it does not make blocking work nonblocking. Prefer
  async system APIs. Put unavoidable blocking file or legacy calls behind a
  narrow dedicated-queue or custom-executor adapter that owns no app state.
- Never pass `ModelContext` or a live SwiftData `@Model` instance across actors.
  Pass stable domain IDs or immutable `Sendable` snapshots and refetch in the
  context's owner.
- Immutable pure domain values may deliberately be `nonisolated` and `Sendable`.
- Avoid `nonisolated(unsafe)`, blanket `@preconcurrency`, broad diagnostic
  suppression, and imprecise isolation escapes.
- Avoid `@unchecked Sendable`. If no safe alternative exists, scope it to the
  narrowest type and document the synchronization invariant and why the compiler
  cannot verify it.

## Task lifecycle and state machines

- Prefer structured concurrency, bounded task groups, `AsyncSequence`, and
  cooperative cancellation.
- Every long-lived task has one owner, an explicit cancellation path, and
  deterministic teardown. It must not outlive its owning service, feature, scene,
  or operation.
- Prefer SwiftUI `.task(id:)` for view-lifetime work. Do not start untracked work
  from `body`.
- Avoid `Task.detached`. If unavoidable, document ownership, priority,
  cancellation propagation, and why every capture is safe.
- Model recorder, player, transcription, and other mutually exclusive workflows
  with focused enums and associated values. Keep independent state axes separate.
- Keep transcription and inference lifecycle state independent of recording and
  playback state. A finalized recording is their durable input boundary.
- Define legal transitions, failure/retry states, cancellation behavior, and the
  last safe commit point.
- Give each operation a stable generation ID. Ignore results made stale by
  cancellation, replacement, deletion, source revision changes, or reentrancy.
- Do not carry an invariant blindly across `await`. Capture identity and revision,
  suspend, then revalidate before mutation or commit.
- Cancellation is not rollback. Preserve committed source data and make cleanup
  safe to repeat.

## Callback, stream, and lock boundaries

- Resume checked continuations exactly once on every success, failure, and
  cancellation path.
- Handle races between synchronous callback completion, cancellation, and
  teardown.
- `AsyncStream` bridges unregister callbacks, finish on teardown, and use an
  explicitly bounded buffering policy.
- Never use an unbounded stream for audio samples, waveform values, playback
  ticks, or high-frequency progress.
- Ordinary delegates and callbacks do minimal synchronous work and promptly hand
  events to the subsystem that owns mutable state.
- Use GCD only inside a narrow callback, blocking-I/O, or real-time adapter.
- Outside real-time paths, encapsulate necessary locks, keep critical sections
  small, and never suspend while holding one.

## Audio ownership

- Create the recorder, player, and audio-session coordinator once at app
  composition. Keep ownership above an individual scene.
- Maintain one mutable owner for recorder state, one for player state, and one
  coordinator for `AVAudioSession`.
- Serialize audio-session category, mode, options, activation, deactivation,
  interruptions, route changes, and media-service resets through the coordinator.
- Views and callbacks never configure `AVAudioSession` directly.
- Define recorder/player interaction policy explicitly rather than letting either
  infer or mutate the other's state through incidental callbacks.
- Notification, delegate, observer, and remote-command registration has symmetric
  teardown. Repeated activation must not install duplicate handlers.

## Recording lifecycle

- Start or resume only through clear user intent and when permission, route,
  audio-session, and system state allow it.
- Model permission, interruptions, route changes, Bluetooth disconnection,
  media-service reset, locking, background execution, low space, finalization,
  cancellation, and cleanup as explicit state-machine events.
- Never silently discard or corrupt valid captured audio. Preserve a valid
  partial recording when normal completion becomes impossible.
- Resume after interruption only when system state, documented policy, and user
  intent permit it.
- Treat finalization as an explicit commit boundary. Close and validate audio
  before publishing the durable journal entry; follow
  [Data and Privacy](DataAndPrivacy.md) for the file transaction.
- Handle write, close, validation, database-save, and finalization failures
  independently. Free-space preflight never replaces handling actual `ENOSPC`.
- Start transcription or inference only after finalization. Their failure or
  cancellation never invalidates original audio.

## Playback and external controls

- Keep one source of truth for selected recording, play/pause state, position,
  duration, seeking, interruption state, and failure.
- Pause cleanly and preserve an appropriate position across interruptions, route
  changes, switching recordings, and output loss.
- Restore playback only when the system permits it and policy matches user intent.
- Publish generic Now Playing metadata only; never expose user-entered or derived
  journal content.
- Exclude private recordings from unrelated system media suggestions.
- When App Lock engages, pause playback, clear Now Playing, and disable external
  commands according to policy.
- Remote-command handlers are idempotent, validate current player identity,
  reject stale commands, and are removed during teardown.

## Real-time audio safety

Determine the documented threading and real-time contract of every callback.
Do not assume all AVFoundation callbacks are equivalent.

A true render or other hard real-time callback:

- performs no dynamic allocation;
- takes no lock or other waiting primitive;
- creates no task;
- performs no logging or signposting;
- calls no `AVAudioSession` or runtime service;
- touches no SwiftData or application state;
- performs no synchronous file, network, or blocking I/O; and
- uses preallocated storage with a bounded lock-free handoff.

Treat audio taps conservatively until their scheduling contract and workload are
understood. Move parsing, aggregation, persistence, and UI publication out of the
callback. Do not add actor hops or task creation from a true real-time callback;
design a real-time-safe handoff instead.

## Throughput, responsiveness, and energy

- Stream or chunk long recordings and audio-derived work.
- Bound sample buffers, task groups, streams, retries, and work queues, with
  explicit backpressure.
- Keep waveform generation, hashing, parsing, and format conversion off
  `MainActor`, cancellable, and tied to source identity.
- Coalesce metering, waveform, elapsed-time, and playback-progress UI updates.
- Persist semantic milestones, not samples, meters, or playback ticks.
- Stop timers, taps, display updates, and processing tasks when inactive.
- Cache format/decoder work only with explicit ownership, invalidation, and
  measured benefit.

## Verification checklist

Follow [Testing and Validation](TestingAndValidation.md). Cover applicable:

- legal and illegal enum transitions;
- cancellation before, during, and after suspension;
- stale results after replacement, deletion, or revision changes;
- reentrancy at meaningful `await` points;
- teardown of tasks, streams, callbacks, continuations, and observers;
- bounded buffering and backpressure; and
- repeated and concurrent start/stop operations.

Run targeted Thread Sanitizer tests for actor, callback, recorder/player, or
persistence-concurrency changes. It does not prove real-time safety.

Recording/playback changes also need relevant physical-device evidence for long
recordings, calls, routes, Bluetooth, locking/background behavior, low space,
media-service reset, App Lock, Now Playing, and cleanup. Use synthetic journal
content and report every unavailable device check as a release gate.
