# Testing and Validation

## When this guide is required

Read this guide before adding/changing tests, building, running the app, using a
sanitizer, profiling, making a performance claim, or handing off a code change.

Read the relevant domain guide as well:

- [Concurrency and Audio](ConcurrencyAndAudio.md)
- [Data and Privacy](DataAndPrivacy.md)
- [UI and Accessibility](UIAndAccessibility.md)

The root [AGENTS.md](../../AGENTS.md) and README contracts remain authoritative.

## Project validation facts

- Project: `Unscripted.xcodeproj`
- Scheme: `Unscripted`
- Targets: `Unscripted`, `UnscriptedTests`, `UnscriptedUITests`
- Configurations: Debug and Release
- Platform: iPhone only, iOS 26.0+; iPad and iPadOS are unsupported
- Build system: Xcode project, not SwiftPM
- Unit/integration tests: Swift Testing
- UI, launch, and metrics: XCTest/XCUITest
- No committed CI, shared scheme, test plan, linter, or formatter

Use only supported iPhone destinations and device matrices. Do not add iPad
Simulator destinations, iPad physical-device gates, or iPad-specific UI tests.

Before adding CI or a test plan, commit the shared scheme at
`Unscripted.xcodeproj/xcshareddata/xcschemes/Unscripted.xcscheme`.

## Choose the lowest reliable test layer

- Add a root-cause regression test for a bug when practical.
- Use Swift Testing for state machines, policies, validation, provenance,
  chunking, cancellation, mappings, and errors.
- Use on-disk integration tests for persistence, migration/reopen, file
  transactions, export decoding, and framework adapters.
- Use XCUITest only for critical journeys, system integration that cannot be
  covered lower, and accessibility behavior.
- Add a performance test only for an identified budget or regression with a
  representative workload.

## Determinism and isolation

- Unit and deterministic integration tests use no real network.
- Dedicated StoreKit/CloudKit sandbox or device tests may use Apple services and
  must be labeled separately.
- Do not share mutable fixtures, depend on execution order, use arbitrary sleeps,
  or make correctness assertions from wall-clock timing.
- Inject clocks, dates, UUIDs, file roots, capability clients, and schedulers
  where determinism requires it.
- Use a fresh in-memory store for pure logic/UI and a unique temporary on-disk
  store for persistence, migration, reopen, corruption, or file coordination.
- Use unique temporary journal roots and synthetic content.
- Clean up tasks, streams, continuations, observers, audio resources, files, and
  stores.
- Assert that cancelled, deleted, replaced, or stale work cannot commit.
- XCTest performance metrics may measure time; ordinary correctness tests may not
  rely on timing.

## Coverage expectations

Test applicable:

- legal/illegal enum transitions, failure, retry, cancellation, and teardown;
- concurrency, reentrancy, stale callbacks/results, and repeated operations;
- migration, corruption, partial transaction, orphan, and recovery behavior;
- low storage and `ENOSPC`;
- locale, calendar, time-zone, daylight-saving, and period boundaries;
- denied/restricted permissions and later recovery;
- empty, short, long, large-journal, malformed, and over-budget inputs;
- Dynamic Type, VoiceOver semantics, privacy surfaces, and stable identifiers;
- export checksums, cancellation, atomic publication, and independent decoding;
  and
- network opt-in boundaries and local behavior while offline/opted out.

UI tests use deterministic launch arguments/environment and semantic
accessibility IDs. Do not key them to localized display strings where an
identifier is appropriate.

## Sanitizers

- Run Thread Sanitizer for changes involving actor boundaries, callbacks,
  recorder/player state, continuations, or persistence concurrency.
- Run Address Sanitizer for unsafe memory or buffer work when relevant.
- Add exactly one of these flags to a targeted `xcodebuild test` invocation:
  - `-enableThreadSanitizer YES`
  - `-enableAddressSanitizer YES`
- Never enable both in the same invocation.
- Sanitizers supplement tests; they do not prove thread safety, real-time safety,
  or absence of memory defects.

## Performance and energy evidence

- Establish a reproducible baseline and compare the same workload before/after.
- Profile a Release build on the oldest supported physical iPhone capable of the
  feature.
- Test graceful degradation on the oldest baseline device when Speech or
  Foundation Models is unavailable.
- Simulator measurements help diagnose but are not final performance/energy
  evidence.
- Prioritize launch, journal scrolling/view invalidation, recording/playback,
  transcription, search, export, storage growth, peak memory, battery, and
  thermals.
- Use Instruments, SwiftUI performance tools, Thread Performance Checker, memory
  diagnostics, privacy-safe signposts, and targeted XCTest metrics.
- Change one bottleneck at a time and report the before/after workload and result.

## Physical-device release gates

Physical-device validation is required as applicable for:

- microphone capture, calls, routes, Bluetooth, and interruptions;
- locked/background recording and playback;
- Data Protection and device-backup attributes;
- LocalAuthentication and App Lock interaction;
- Speech/Foundation Models availability and asset behavior;
- Now Playing and remote controls;
- StoreKit sandbox and CloudKit;
- memory pressure, battery, and thermal behavior; and
- release performance claims.

Run these checks when a suitable device is available. Otherwise report the exact
gap and mark it as required before shipping or making the corresponding claim.

## XcodeBuildMCP workflow

Prefer XcodeBuildMCP for discovery, simulator build/run/test, UI inspection, and
logs.

Before the first build, run, or test call in a session:

1. Call `session_show_defaults`.
2. If project/workspace, scheme, and simulator are correct, proceed directly with
   `build_run_sim`.
3. Use `discover_projs` only when the configured project/workspace is missing or
   wrong.
4. Do not boot or open the simulator as a prerequisite to `build_run_sim`.

## Shell workflow

Run from the repository root. Use `xcsift` when available. If it is absent, run
`xcodebuild` unpiped and preserve its exit status rather than skipping validation.
Do not install or reconfigure host tools without authorization.

If installation is explicitly authorized and `xcsift` is unavailable:

```sh
brew install mise
brew install xcsift
xcsift install-codex
```

Do not use `swift build` or `swift test`. Do not run `clean` by default. Do not
invent lint, formatting, or CI commands.

Inspect destinations:

```sh
xcodebuild -showdestinations \
  -project Unscripted.xcodeproj \
  -scheme Unscripted
```

Fast Debug compile:

```sh
set -o pipefail
xcodebuild build \
  -project Unscripted.xcodeproj \
  -scheme Unscripted \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  2>&1 | xcsift -f toon -w -E
```

Unit tests with coverage:

```sh
set -o pipefail
xcodebuild test \
  -project Unscripted.xcodeproj \
  -scheme Unscripted \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' \
  -only-testing:UnscriptedTests \
  -enableCodeCoverage YES \
  2>&1 | xcsift -f toon -w -c -E
```

Unsigned Release simulator compile:

```sh
set -o pipefail
xcodebuild build \
  -project Unscripted.xcodeproj \
  -scheme Unscripted \
  -configuration Release \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  2>&1 | xcsift -f toon -W -E
```

Use the oldest installed iOS 26.x simulator in place of the example destination
when needed. Use `OS=latest` only as an additional smoke test, never instead of
iOS 26 coverage. Record the exact destination and never commit a simulator UDID.

Remove `-only-testing:UnscriptedTests` to include the full unit/UI suite when
relevant.

The unsigned simulator build does not validate signing, provisioning,
entitlements, archiving, capabilities, or device-only behavior.

## Validation matrix

- Documentation only: inspect structure and run `git diff --check`.
- Local logic: targeted unit tests plus Debug build.
- Persistence/files/concurrency: integration tests, Debug and Release compile,
  relevant migration fixtures, and sanitizer.
- UI: unit/UI tests, simulator inspection/previews, and accessibility pass.
- Audio/security/StoreKit/CloudKit/background/performance: automation plus the
  physical-device gates above.

## Reporting

Every handoff lists:

- exact commands and whether they passed;
- simulator/device model and OS version;
- tests, sanitizers, previews, accessibility checks, and profiles run;
- skipped or unavailable validation and its release risk; and
- whether the active compiler was actually Swift 6.2.

A newer compiler build does not prove Swift 6.2 compatibility. Never claim all
tests, CI, thread safety, device behavior, or performance improvement without
corresponding evidence.
