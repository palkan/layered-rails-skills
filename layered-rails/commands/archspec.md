---
description: Generate and verify a tailored Archspec.rb that enforces the layered architecture boundaries in CI
---

Detect the app's folder structure, generate an `Archspec.rb` from the canonical layered-rails config, run `archspec check`, and help triage violations (fix, suppress, or baseline into a todo file).

This works even when the archspec gem isn't installed yet: explain the tool, ask the user to add the gem, and prepare the config so verification can run right after `bundle install`.

Read and follow [`skills/layered-rails/workflows/archspec.md`](../skills/layered-rails/workflows/archspec.md).
