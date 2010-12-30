require 'logger'
require 'copycopter_client/i18n_backend'
require 'copycopter_client/client'
require 'copycopter_client/sync'
require 'copycopter_client/prefixed_logger'

module CopycopterClient
  # Used to set up and modify settings for the client.
  class Configuration

    # These options will be present in the Hash returned by {#to_hash}.
    OPTIONS = [:api_key, :development_environments, :environment_name, :host,
        :http_open_timeout, :http_read_timeout, :client_name, :client_url,
        :client_version, :port, :protocol, :proxy_host, :proxy_pass,
        :proxy_port, :proxy_user, :secure, :polling_delay, :logger,
        :framework, :fallback_backend].freeze

    # @return [String] The API key for your project, found on the project edit form.
    attr_accessor :api_key

    # @return [String] The host to connect to (defaults to +copycopter.com+).
    attr_accessor :host

    # @return [Fixnum] The port on which your Copycopter server runs (defaults to +443+ for secure connections, +80+ for insecure connections).
    attr_accessor :port

    # @return [Boolean] +true+ for https connections, +false+ for http connections.
    attr_accessor :secure

    # @return [Fixnum] The HTTP open timeout in seconds (defaults to +2+).
    attr_accessor :http_open_timeout

    # @return [Fixnum] The HTTP read timeout in seconds (defaults to +5+).
    attr_accessor :http_read_timeout

    # @return [String, NilClass] The hostname of your proxy server (if using a proxy)
    attr_accessor :proxy_host

    # @return [String, Fixnum] The port of your proxy server (if using a proxy)
    attr_accessor :proxy_port

    # @return [String, NilClass] The username to use when logging into your proxy server (if using a proxy)
    attr_accessor :proxy_user

    # @return [String, NilClass] The password to use when logging into your proxy server (if using a proxy)
    attr_accessor :proxy_pass

    # @return [Array<String>] A list of environments in which content should be editable
    attr_accessor :development_environments

    # @return [Array<String>] A list of environments in which the server should not be contacted
    attr_accessor :test_environments

    # @return [String] The name of the environment the application is running in
    attr_accessor :environment_name

    # @return [String] The name of the client library being used to send notifications (defaults to +Copycopter Client+)
    attr_accessor :client_name

    # @return [String, NilClass] The framework notifications are being sent from, if any (such as +Rails 2.3.9+)
    attr_accessor :framework

    # @return [String] The version of the client library being used to send notifications (such as +1.0.2+)
    attr_accessor :client_version

    # @return [String] The url of the client library being used
    attr_accessor :client_url

    # @return [Integer] The time, in seconds, in between each sync to the server. Defaults to +300+.
    attr_accessor :polling_delay

    # @return [Logger] Where to log messages. Must respond to same interface as Logger.
    attr_reader :logger

    # @return [I18n::Backend::Base] where to look for translations missing on the Copycopter server
    attr_accessor :fallback_backend

    alias_method :secure?, :secure

    # Instantiated from {CopycopterClient.configure}. Sets defaults.
    def initialize
      self.secure                   = false
      self.host                     = 'copycopter.com'
      self.http_open_timeout        = 2
      self.http_read_timeout        = 5
      self.development_environments = %w(development staging)
      self.test_environments        = %w(test cucumber)
      self.client_name              = 'Copycopter Client'
      self.client_version           = VERSION
      self.client_url               = 'http://copycopter.com'
      self.polling_delay            = 300
      self.logger                   = Logger.new($stdout)

      @applied = false
    end

    # Allows config options to be read like a hash
    #
    # @param [Symbol] option Key for a given attribute
    # @return [Object] the given attribute
    def [](option)
      send(option)
    end

    # Returns a hash of all configurable options
    # @return [Hash] configuration attributes
    def to_hash
      base_options = { :public => public? }
      OPTIONS.inject(base_options) do |hash, option|
        hash.merge(option.to_sym => send(option))
      end
    end

    # Returns a hash of all configurable options merged with +hash+
    #
    # @param [Hash] hash A set of configuration options that will take precedence over the defaults
    # @return [Hash] the merged configuration hash
    def merge(hash)
      to_hash.merge(hash)
    end

    # Determines if the content will be editable
    # @return [Boolean] Returns +false+ if in a development environment, +true+ otherwise.
    def public?
      !(development_environments + test_environments).include?(environment_name)
    end

    # Determines if the content will fetched from the server
    # @return [Boolean] Returns +true+ if in a test environment, +false+ otherwise.
    def test?
      test_environments.include?(environment_name)
    end

    # Determines if the configuration has been applied (internal)
    # @return [Boolean] Returns +true+ if applied, +false+ otherwise.
    def applied?
      @applied
    end

      # Applies the configuration (internal).
    #
    # Called automatically when {CopycopterClient.configure} is called in the application.
    #
    # This creates the {Client}, {Sync}, and {I18nBackend} and puts them together.
    #
    # When {#test?} returns +false+, the sync will be started.
    def apply
      client = Client.new(to_hash)
      sync = Sync.new(client, to_hash)
      I18n.backend = I18nBackend.new(sync, to_hash)
      CopycopterClient.client = client
      @applied = true
      logger.info("Client #{VERSION} ready")
      logger.info("Environment Info: #{environment_info}")
      sync.start unless test?
    end

    def port
      @port || default_port
    end

    # The protocol that should be used when generating URLs to Copycopter.
    # @return [String] +https+ if {#secure?} returns +true+, +http+ otherwise.
    def protocol
      if secure?
        'https'
      else
        'http'
      end
    end

    # For logging/debugging (internal).
    # @return [String] a description of the environment in which this configuration was built.
    def environment_info
      parts = ["Ruby: #{RUBY_VERSION}", framework, "Env: #{environment_name}"]
      parts.compact.map { |part| "[#{part}]" }.join(" ")
    end

    # Wraps the given logger in a PrefixedLogger. This way, CopycopterClient
    # log messages are recognizable.
    # @param original_logger [Logger] the upstream logger to use, which must respond to the standard +Logger+ severity methods.
    def logger=(original_logger)
      @logger = PrefixedLogger.new("** [Copycopter]", original_logger)
    end

    private

    def default_port
      if secure?
        443
      else
        80
      end
    end
  end
end
