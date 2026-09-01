require "json"

Gem::Specification.new do |spec|
  spec.name    = "layered-rails-skills"
  # Set to publish a gem-only release against unchanged plugin content; back to
  # nil on the next plugin bump.
  packaging_revision = nil
  spec.version = [
    JSON.parse(
      File.read(File.expand_path("layered-rails/.claude-plugin/plugin.json", __dir__))
    )["version"],
    packaging_revision
  ].compact.join(".")
  spec.authors = ["Vladimir Dementyev"]
  spec.summary = "Layered Rails architecture guidance as a rails-hyperdrive companion gem."
  spec.homepage = "https://github.com/palkan/layered-rails-skills"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2"

  spec.files = Dir[
    "layered-rails/skills/**/*",
    "layered-rails/agents/*.md",
    "rails-hyperdrive/layered-rails/commands/*.md.erb",
    "rails-hyperdrive/layered-rails/templates/**/*"
  ] + ["hyperdrive.yml"]

  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["rubygems_mfa_required"] = "true"
  spec.metadata["hyperdrive_targets"] = %w[
    railties action_policy view_component anyway_config active_delivery
    alba workflow rubanok activeagent active_job-performs
  ].join(",")
  spec.metadata["hyperdrive_artifacts"] = "skill,agent,command"
end
