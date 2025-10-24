# frozen_string_literal: true

# EnvironmentConfig encapsulates the logic used by the Vagrantfile to
# combine baked-in defaults with optional overrides sourced from the process
# environment. Extracting the behaviour allows us to exercise it through
# automated tests without invoking Vagrant itself.
module EnvironmentConfig
  module_function

  # Returns a Hash composed from +defaults+ and +env_source+.
  #
  # Each key defined in +defaults+ is copied into the result. If the
  # +env_source+ exposes the same key, its value wins. Values are not coerced so
  # downstream consumers retain full control over type conversions.
  def load(defaults, env_source = ENV)
    defaults.each_with_object({}) do |(key, default_value), acc|
      acc[key] = value_for(env_source, key, default_value)
    end
  end

  # Helper used by tests to ensure the module respects Hash-like objects that
  # provide both string and symbol keys (as ENV does). The environment is
  # treated as case-sensitive, matching Ruby's ENV behaviour.
  def value_for(env_source, key, default_value)
    if env_has_key?(env_source, key)
      env_source[key]
    else
      default_value
    end
  end
  private_class_method :value_for

  def env_has_key?(env_source, key)
    if env_source.respond_to?(:key?)
      env_source.key?(key)
    elsif env_source.respond_to?(:include?)
      env_source.include?(key)
    else
      !env_source[key].nil?
    end
  end
  private_class_method :env_has_key?
end
