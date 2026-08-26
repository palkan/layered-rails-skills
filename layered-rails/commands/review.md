---
description: Standalone code review from a layered architecture perspective
argument-hint: "[file_path | --staged | --branch <name>]"
---

Read and follow [`skills/layered-rails/workflows/review.md`](../skills/layered-rails/workflows/review.md), applied to whatever $ARGUMENTS names: a file path, `--staged` for the staged changes, or `--branch <name>` for the changes against that branch. With no argument, review the uncommitted changes.

For multi-agent review with compound-engineering, this same workflow runs as the `layered-rails-reviewer` sub-agent.
