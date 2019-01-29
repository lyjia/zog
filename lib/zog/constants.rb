require 'logger'

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
                     unknown:  { color: "[32m", stdlib: Logger::UNKNOWN } }.freeze #TODO: make freeze recursive

      CATEGORY_NAMES_MINUS_INTERNAL = (CATEGORIES.keys - [:zog_internal])

      LOG_FILENAME = "Zog.log".freeze

      CONFIG = {
          format_date:   "%Y%m%d-%H%M%S ",
          format_output: [:datestamp, :severity, " in ", :caller, "(): ", :message],
          categories:    CATEGORIES.dup,
          verbose:       true
      }.freeze

    end

  end
end