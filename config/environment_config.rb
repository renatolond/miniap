# frozen_string_literal: true

# This module contains all configuration that is loaded from ENV variables to be available to the rest of the app.
# It is loaded here so that if a environment variable is needed at runtime, it will fail fast, and not eventually fail at runtime when needed.
module EnvironmentConfig
  class << self
    # @raise [Dry::Types::CoercionError] If the value of the variable cannot be coerced correctly
    # @return [Boolean]
    def use_https?
      @use_https ||= Environment.current == :production || DryTypes::Params::Bool[ENV.fetch("LOCAL_HTTPS", false)]
    end

    # @return [String]
    def miniap_core_host
      @miniap_core_host ||= ENV.fetch("LOCAL_DOMAIN") { "localhost:#{ENV.fetch("PORT", 3000)}" }
    end

    # @raise [RuntimeError] If the variable is missing
    # @return [String]
    def session_secret
      @session_secret ||= ENV.delete("SESSION_SECRET") || (raise "Missing SESSION_SECRET variable")
    end

    # @return [String, nil]
    def miniap_version_prerelease
      @miniap_version_prerelease ||= ENV.fetch("MINIAP_VERSION_PRERELEASE", nil)
    end

    # @return [String, nil]
    def miniap_version_metadata
      @miniap_version_metadata ||= ENV.fetch("MINIAP_VERSION_METADATA", nil)
    end

    # @return [Regexp]
    def rack_trusted_ips_re
      @rack_trusted_ips_re ||= begin
        proxy_ips = ENV.fetch("PROXY_IPS", "")
        valid_ipv4_octet = /\.(25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])/
        regexes = [/\A127#{valid_ipv4_octet}{3}\z/, # localhost IPv4 range 127.x.x.x, per RFC-3330
                   /\A::1\z/,                                                # localhost IPv6 ::1
                   /\Af[cd][0-9a-f]{2}(?::[0-9a-f]{0,4}){0,7}\z/i,           # private IPv6 range fc00 .. fdff
                   /\A10#{valid_ipv4_octet}{3}\z/,                           # private IPv4 range 10.x.x.x
                   /\A172\.(1[6-9]|2[0-9]|3[01])#{valid_ipv4_octet}{2}\z/,   # private IPv4 range 172.16.0.0 .. 172.31.255.255
                   /\A192\.168#{valid_ipv4_octet}{2}\z/,                     # private IPv4 range 192.168.x.x
                   /\Alocalhost\z|\Aunix(\z|:)/i]                            # localhost hostname, and unix domain sockets
        regexes += proxy_ips.split(",").map { |v| /\A#{Regexp.escape(v)}\z/ } if proxy_ips.present?
        Regexp.union(*regexes)
      end
    end

    # Calls all the functions in the module so that any missing variables fail early
    # @raise [KeyError] If any of the variables is missing the keys
    # @raise [RuntimeError] on any other errors
    def load_values
      use_https?

      miniap_core_host

      session_secret

      miniap_version_prerelease
      miniap_version_metadata

      rack_trusted_ips_re
    end
  end
end
