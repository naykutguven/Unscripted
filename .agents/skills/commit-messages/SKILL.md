---
name: commit-messages
description: Draft, edit, or review Unscripted commit messages using the repository's Conventional Commits conventions.
---

# Commit messages

Use Conventional Commits:

```text
<type>(<scope>): <imperative summary>
```

- Keep the subject concise, preferably 72 characters or fewer.
- Use a lowercase type: `feat`, `fix`, `refactor`, `test`, `docs`, `build`,
  `chore`, or `perf`.
- Choose a focused product or technical scope, such as `recording`, `playback`,
  `journal`, `persistence`, `privacy`, or `ui`.
- Write the summary in the imperative mood without a trailing period.
- Add a body when the motivation, data-safety implications, concurrency behavior,
  or migration impact is not obvious.
- Use `BREAKING CHANGE:` only for an intentional breaking change.
- Describe the committed change, not the work session or tools used.
