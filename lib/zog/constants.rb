module Zog
  class Constants

    BASH_COLOR_ESC_PREFIX = "\033".freeze #formerly \e
    BASH_COLOR_NORMAL     = "[0m".freeze
    BASH_COLOR_BOLD       = "[37;1m".freeze

    module Defaults

      CATEGORIES = { debug: "[35m",
                     info:  "[34m",

                     warn:  "[33m",
                     error: "[31m",
                     fatal: "[31;1m",
                     other: "[32m" }.freeze

      LOG_FILENAME = "Zog.log".freeze

      CONFIG = {
          format_date:   "%Y%m%d-%H%M%S ",
          format_output: [:datestamp, :severity, " in ", :caller, "(): ", :message],
          categories:    CATEGORIES.dup,
      }.freeze

    end

  end
end