module Zog
  module Outputs
    class Base

      DEFAULT_CONFIG = Constants::Defaults::CONFIG

      def initialize(**config)
        configure!(config)
      end

      def configure!(**config)
        @config = DEFAULT_CONFIG.dup.merge(config)
      end

      # Needs to be overridden
      def msg(severity, message, kaller)
        raise "Not implemented yet!"
      end

      # Needs to be overridden
      def die!
        raise "Not implemented yet!"
      end

    end
  end
end
