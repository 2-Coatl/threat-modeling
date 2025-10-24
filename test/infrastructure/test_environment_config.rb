# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../infrastructure/lib/environment_config'

class EnvironmentConfigTest < Minitest::Test
  DEFAULTS = {
    'NETWORK_SUBNET' => '192.168.56.0',
    'LOAD_BALANCER_IP' => '192.168.56.10',
    'APPLICATION_SERVER_IP' => '192.168.56.11',
    'HTTP_PORT' => '8080',
    'HTTPS_PORT' => '8443',
    'NGINX_MEMORY' => '1024',
    'NGINX_CPUS' => '1',
    'TOMCAT_MEMORY' => '2048',
    'TOMCAT_CPUS' => '2',
    'ENABLE_PROVISIONING' => 'true',
    'ENABLE_DEBUG' => 'false'
  }.freeze

  def test_defaults_used_when_environment_missing
    env_vars = EnvironmentConfig.load(DEFAULTS, {})
    assert_equal DEFAULTS, env_vars
  end

  def test_environment_override_applies
    env_vars = EnvironmentConfig.load(DEFAULTS, { 'HTTP_PORT' => '9090' })
    assert_equal '9090', env_vars['HTTP_PORT']
  end

  def test_only_declared_keys_copied
    env_vars = EnvironmentConfig.load(DEFAULTS, { 'UNUSED_KEY' => 'value' })
    refute_includes env_vars.keys, 'UNUSED_KEY'
  end

  def test_environment_object_with_key_method_supported
    env_source = Class.new {
      def initialize(values)
        @values = values
      end

      def key?(key)
        @values.key?(key)
      end

      def [](key)
        @values[key]
      end
    }.new('NGINX_CPUS' => '4')

    env_vars = EnvironmentConfig.load(DEFAULTS, env_source)
    assert_equal '4', env_vars['NGINX_CPUS']
  end
end
