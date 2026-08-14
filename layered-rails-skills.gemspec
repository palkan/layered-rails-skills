require "json"

Gem::Specification.new do |spec|
  spec.name    = "layered-rails-skills"
  spec.version = JSON.parse(
    File.read(File.expand_path("layered-rails/.claude-plugin/plugin.json", __dir__))
  )["version"]
  spec.authors = ["Vladimir Dementyev"]
  spec.summary = "Layered Rails architecture guidance as a rails-hyperdrive companion gem."
  spec.homepage = "https://github.com/palkan/skills"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2"

  spec.files = Dir["layered-rails/skills/**/*", "rails-hyperdrive/layered-rails/templates/**/*"]

  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["rubygems_mfa_required"] = "true"
  spec.metadata["rails_hyperdrive_skills_dir"] = "layered-rails/skills"
  spec.metadata["rails_hyperdrive_skill_templates_dir"] = "rails-hyperdrive/layered-rails/templates"
  spec.metadata["rails_hyperdrive_targets"] = %w[
    railties action_policy view_component anyway_config active_delivery
    alba workflow rubanok activeagent active_job-performs
  ].join(",")
  spec.metadata["rails_hyperdrive_artifacts"] = "skill"
end
