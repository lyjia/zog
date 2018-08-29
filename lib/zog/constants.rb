module Zog
  class Constants

    BASH_COLOR_ESC_PREFIX = "\e"
    BASH_COLOR_NORMAL     = "[0m"

    module Defaults

      CATEGORIES = %i( debug info warn error fatal other )

      COLORS     = { debug: "[35m",
                     info:  "[34m",

                     warn:  "[33m",
                     error: "[31m",
                     fatal: "[31;1m",
                     other: "[32m" }

      LOG_FILENAME = "Zog.log"

    end

  end
end