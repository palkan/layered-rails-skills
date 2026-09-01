# ArchSpec Setup Workflow

Generate, verify, and adopt a tailored `Archspec.rb` that enforces this skill's layer boundaries in CI. The canonical config, rule rationale, and DSL caveats live in the [archspec gem reference](../references/gems/archspec.md) — this workflow is the procedure for applying it to a concrete codebase.

## Contents

- [1. Check the Gem](#1-check-the-gem)
- [2. Detect the Structure](#2-detect-the-structure)
- [3. Generate Archspec.rb](#3-generate-archspecrb)
- [4. Verify](#4-verify)
- [5. Report](#5-report)

## 1. Check the Gem

Determine whether archspec is available: look for `archspec` in `Gemfile` / `Gemfile.lock`, then try `bundle exec archspec version`.

**If the gem is missing, don't stop.** Explain the tool and ask the user to install it:

> ArchSpec ([archspecrb.dev](https://archspecrb.dev), [github.com/crmne/archspec](https://github.com/crmne/archspec), MIT) is a static architecture linter for Ruby and Rails — it reads source with Prism (no app boot, no database) and turns layer boundaries into `archspec check` failures that run in CI, in git hooks, and after agent edits. Install it with:
>
> ```ruby
> # Gemfile
> group :development, :test do
>   gem "archspec"
> end
> ```
>
> then `bundle install`.

Continue with steps 2–3 regardless — the generated config is ready the moment the gem lands. If step 4 can't run, mark it **pending gem install** in the report.

## 2. Detect the Structure

1. List `app/*/` directories and map each to a layer using the reference's canonical map. Drop globs for folders that don't exist.
2. Note special shapes:
   - **Nested specializations** (`app/services/queries/`, etc.) — flag for renaming to a top-level folder; do **not** carve them out with overlapping globs (see the reference's Tailoring section for why).
   - **Models-first** (no `app/services/`) — the layer map still applies; the `domain.cannot_call` / `Current` rules are its teeth.
   - **Unmapped folders** (`app/facades/`, vendor-named folders) — classify by inspecting a few files' purposes; vendor-named ones feed the `vendor_folders` guard.
3. Check conventions before enabling optional rules — sample files, don't assume:
   - `ApplicationService` with `#call` → `services.must_implement :call` is safe; otherwise skip it (a linter must not invent a convention).
   - Query-object suffix convention (`*_query.rb` under `app/models/` or `app/queries/`) → the reference's `:query_objects` component, including its allowlist top-ups.
4. If `Archspec.rb` already exists, read it first and propose targeted additions — never overwrite the user's rules.

## 3. Generate Archspec.rb

Start from the reference config in the [archspec gem reference](../references/gems/archspec.md), pruned and extended per step 2. Always include: the four-layer `:layered` preset, the controller-API `cannot_call` rules, `domain.cannot_reference_constants "Current"`, and the vendor-folder guard. Add optional blocks only for detected conventions.

Write the file to the repo root and summarize what was included, what was excluded, and why.

## 4. Verify

Run `bundle exec archspec check`. On failures, read the evidence — never weaken a rule just to make it pass. Classify each violation:

- **Real boundary violation in existing code** — legacy debt. Bootstrap the baseline: add `todo "archspec_todo.yml"` to the config and run `bundle exec archspec check --update-todo`. The todo file freezes existing violations so new code must be clean. Never re-run `--update-todo` to absorb new violations.
- **Misclassification** — run `bundle exec archspec explain <file>` and fix the globs, move the file to the folder matching its purpose, or reclassify the dependency itself: a client wrapper a model legitimately uses belongs in the infrastructure layer via an `except:` carve-out, and a layer subset with extra rights (e.g. workflows firing deliveries) gets its own carved-out component — see the reference's Escape Hatches section.
- **Accepted exception** (e.g., an audit-column `Current` default) — inline suppression with a reason, per the reference. Suppressions hide diagnostics, not graph edges: a cycle derived from suppressed edges still fires, anchored on an arbitrary participating edge — baseline that one in the todo file.

## 5. Report

- Layers configured, with folder and file counts per layer
- Rules enabled; rules skipped and why (missing folder, no established convention)
- Violation summary: fixed / suppressed / baselined into the todo file (with counts)
- Next steps: wire `archspec check` into CI and git hooks; burn down the todo file (the layerification plan workflow's phases are natural checkpoints); re-run the architecture analysis after refactors
