require 'logger'
require 'ice_nine'
require 'ice_nine/core_ext/object'

module Zog
  class Constants

    BASH_COLOR_ESC_PREFIX = "\033".freeze #formerly \e
    BASH_COLOR_NORMAL     = "[0m".freeze
    BASH_COLOR_BOLD       = "[37;1m".freeze

    module Defaults

      CATEGORIES = { debug:    { color: "[35m", stdlib: Logger::DEBUG },
                     info:     { color: "[34m", stdlib: Logger::INFO },
                     warn:     { color: "[33m", stdlib: Logger::WARN },
                     error:    { color: "[31m", stdlib: Logger::ERROR },
                     fatal:    { color: "[31;1m", stdlib: Logger::FATAL },
                     other:    { color: "[32m", stdlib: Logger::UNKNOWN },
                     _zog_internal: { color: "[32m", stdlib: Logger::UNKNOWN },
                     unknown:  { color: "[32m", stdlib: Logger::UNKNOWN } }.deep_freeze #TODO: make freeze recursive

      CATEGORY_NAMES_MINUS_INTERNAL = (CATEGORIES.keys - [:zog_internal]).freeze

      DEFAULT_NUM_STEPS = 3.freeze
      DEFAULT_NUM_STEPS_FAKE = 2.freeze
      DEFAULT_OUTPUTS = []

      LOG_FILENAME = "Zog.log".freeze

      CONFIG = {
          #string
          format_date:    "%Y%m%d-%H%M%S ",

          #array of strings or symbols
          format_output:  [:datestamp, :severity, " in ", :caller, "(): ", :message],

          # array of symbols
          allowed_categories: CATEGORY_NAMES_MINUS_INTERNAL,

          # array of Zog::Output derivatives
          active_outputs: DEFAULT_OUTPUTS,

          # boolean
          verbose:        true
      }.deep_freeze

    end

  end
end