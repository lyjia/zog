require 'zog/outputs/base'

module Zog
  module Outputs
    class FileLogger < Zog::Outputs::Base

      def msg(severity, message, kaller)

      end


      # config
      def configure!(config)
        super(DEFAULT_CONFIG.merge(config || {}))
        return
      end

    end
  end
end
