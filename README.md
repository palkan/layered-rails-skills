# Layered Rails Skills

Design and review Rails applications using layered architecture principles from the [Layered Design for Ruby on Rails Applications](https://www.packtpub.com/en-us/product/layered-design-for-ruby-on-rails-applications-9781806114221) book.

The bundled plugins and slash commands target [Claude Code](https://docs.anthropic.com/en/docs/claude-code), while the core skill content (`SKILL.md` + workflows + references + examples) is also usable from other environments such as Codex.

**Install (recommended — full plugin with commands and sub-agents):**

```
/plugin marketplace add palkan/layered-rails-skills
/plugin install layered-rails@layered-rails-skills
```

**Commands:**

| Command | Purpose |
|---------|---------|
| `/layered-rails:analyze` | Full codebase architecture analysis |
| `/layered-rails:analyze-services` | Audit `app/services/` — conventions, clusters, layer hygiene, test consequences |
| `/layered-rails:analyze-callbacks` | Score model callbacks, find extraction candidates |
| `/layered-rails:analyze-gods` | Find god objects via churn x complexity |
| `/layered-rails:review` | Review code changes for layer violations |
| `/layered-rails:spec-test` | Run specification test on specific files |
| `/layered-rails:plan [goal]` | Plan incremental adoption of layered patterns |
| `/layered-rails:archspec` | Generate and verify an `Archspec.rb` enforcing layer boundaries in CI |

**Install via [skills.sh](https://skills.sh/) (skill content only — no slash-command bindings):**

```
npx skills add palkan/layered-rails-skills --skill layered-rails
```

skills.sh delivers the `skills/layered-rails/` tree — `SKILL.md`, `workflows/`, `references/`, and `examples/`. The `/layered-rails:*` slash commands and the `layered-rails-planner` / `layered-rails-reviewer` sub-agent registrations are not part of the skill spec and won't be copied, but every workflow they wrap is in `workflows/` and can be invoked by name in plain language ("run the layered-rails review workflow on this diff"). Use this path when you want the same skill in Codex, the Claude API, or any other agent that supports skills.sh; use `/plugin install` when you want the slash commands.

**Install via [rails-hyperdrive](https://github.com/rails-hyperdrive/rails-hyperdrive) (Rails apps — bundle-aware, commands and sub-agents included):**

```ruby
group :development do
  gem "rails-hyperdrive", ">= 0.8"
  gem "layered-rails-skills"
end
```

```sh
bin/rails hyperdrive:init
```

Installs the same skill tree into `.claude/skills/layered-rails/`, tailored to the app's bundle: the architecture core installs into any Rails app, while each per-gem reference manual under `references/gems/` (Action Policy, ViewComponent, Alba, …) installs only when its gem is in the app's `Gemfile.lock` (the archspec manual is the exception — it installs unconditionally, since its job is to introduce that gem) — gating declared in [`hyperdrive.yml`](hyperdrive.yml) at the repo root — and `SKILL.md`'s Gem References table lists only what was installed. `bin/rails hyperdrive:sync` picks up updates on gem upgrades.

The commands and sub-agents come along too, into `.claude/commands/` and `.claude/agents/`. Since that directory has no plugin namespace, the commands install prefixed — `/layered-rails-analyze` rather than `/layered-rails:analyze` — and the two sub-agents keep their names.

## Integration with compound-engineering

We recommend asking Claude itself to update the instructions for Compound Engineering to include Layered Design features according to your needs. Below you can find some examples.

If you use the [compound-engineering](https://github.com/EveryInc/compound-engineering-plugin) plugin, add explicit instructions to include layered-rails planning and reviewing agents.

In your `compound-engineering.local.md` file:

```md
---
review_agents:
  - layered-rails:layered-rails-reviewer
  - rails-reviewer
  - security-sentinel
  # - ...
---

# ...

# also worth adding something like:

We are **gradually adopting layered design principles** from "Layered Design for Ruby on Rails Applications" — clean abstraction boundaries, explicit layers, and specification tests...

```

Similarly, for planning features, add to your `CLAUDE.md` (or `AGENTS.md`, or whatever) smth like:

```md
# ...

## For planning agents

When planning new features or architectural changes, use the `layered-rails` skill for analysis:
- `/layered-rails:plan` — plan incremental adoption of layered patterns
- `/layered-rails:analyze` — full codebase architecture analysis
- `/layered-rails:review` — review code from a layered architecture perspective
- `/layered-rails:spec-test` — apply the specification test to evaluate layer placement
```

Alternatively, you can try to add shorter instructions to `CLAUDE.md`:

```md
Extend the list of **review agents** with the `layered-rails:layered-rails-reviewer` agent to check for architecture layer violations. Must be applicable to such commands from the compound-engineering plugin as `/workflow:review`, `/plan_review`, and similar.

Extend the list of **planning agents** with the `layered-rails:layered-rails-planner` agent to plan refactoring according to the layered design principles. Must be applicable to such commands from the compound-engineering plugin as `/workflow:plan`, `/deepen_plan`, and similar.
```

## License

MIT
