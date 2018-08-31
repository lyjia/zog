module Zog
  module Outputs
    class Base

      DEFAULT_CONFIG = Constants::Defaults::CONFIG

      def initialize(config = nil)
        configure!(config)
      end

      def msg(severity, message, kaller)
        raise "Not implemented yet!"
      end

      def configure!(config)
        @config = config
        @config ||= DEFAULT_CONFIG.dup
      end

      def die!
        raise "Not implemented yet!"
      end

    end
  end
end
