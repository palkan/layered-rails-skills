# /layered-rails:archspec

Generate and verify a tailored `Archspec.rb` that enforces the layered architecture boundaries in CI.

## Usage

```
/layered-rails:archspec
```

Detects the app's folder structure, generates an `Archspec.rb` from the canonical layered-rails config, runs `archspec check`, and helps triage violations (fix, suppress, or baseline into a todo file).

Works even when the archspec gem isn't installed yet — it explains the tool, asks the user to add the gem, and prepares the config so verification can run right after `bundle install`.

Read and follow [`skills/layered-rails/workflows/archspec.md`](../skills/layered-rails/workflows/archspec.md).
