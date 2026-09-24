# 1. Sync project repos with the template by diff, not merge

Status: Accepted (2026-09-24)

## Context

Project repos are created with GitHub's **Use this template**, which copies the
files into a new repo with a fresh root commit. The project repo and the
template share no history.

`pixi.toml` had a `git-merge-template` task
(`git merge template/main --allow-unrelated-histories`). It was commented out
and never used. Without a working sync path, project repos rebuilt template
features themselves: at least one repo created its own pixi environment and
`slurm-check` task a week after the template shipped both (#59).

## Decision

Replace the merge task with pixi tasks that diff the template between the last
sync point and `template/main`:

- `template-diff` shows the changes, optionally limited to paths.
- `template-apply` applies them with `git apply --3way`. Hunks the project
  hasn't touched apply cleanly; the rest get conflict markers.
- `template-mark-synced` writes the applied template commit to
  `.template-sync`, which the project commits.

Only `template-diff` fetches. `template-apply` saves the commit it applies to
`.git/template-pending`, and `template-mark-synced` moves it to
`.template-sync`, falling back to the last-fetched `template/main` after hand
edits. A fetch between review and apply, or between apply and marking, would
otherwise apply or record template changes nobody reviewed.

The sync point is the commit in `.template-sync`. Without a valid one, it's the
merge base (repos cloned from the template), else the last template commit
before the project repo's root commit. `git-link-template` is idempotent, and
`template-diff` runs it first.

Maintainers choose which changes to keep. The walkthrough is in
`docs/gh-pages/template-updates.qmd`.

## Alternatives considered

**Fix `git-merge-template`.** With unrelated histories, the first merge treats
every file as added on both sides, and any file the project edited conflicts.
Project repos edit most template files (`pixi.toml`, `run_nextflow.sh`,
parameter files, `CHECKLIST.md`). Later merges work from a real merge base,
but the first one means resolving the whole repo by hand. Merging also pulls
in template files a project deleted on purpose.

**Copier.** [Copier](https://copier.readthedocs.io/) records the template
version in `.copier-answers.yml` and `copier update` does the same 3-way
update, plus templated values such as the species name. Deferred: the template
would need converting to a Copier template, and every existing project repo
adopting it once. The pixi tasks solve the sync problem without either step.

## Consequences

- Maintainers see only what the template changed, not their own divergence
  from it, so the diff stays small.
- A project falls behind if nobody runs `template-diff`. The `CHECKLIST.md`
  item makes it an explicit step.
- Project repos created before this change must copy the tasks in once by
  hand.
- The fallback sync point assumes the repo was created from `template/main` at
  the time of its root commit, and picks the wrong commit if the template
  changed around then. The walkthrough has a first-run check. For repos
  created from another branch, write the right commit to `.template-sync`.
- `git apply` is all-or-nothing. A template change to a file the project
  deleted aborts the whole apply; the project excludes it with a `:!path`
  argument.
- The template repo itself never commits `.template-sync`. Repos created from
  it would inherit a stale value.
