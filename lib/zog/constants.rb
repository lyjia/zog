module Zog
  class Constants

    BASH_COLOR_ESC_PREFIX = "\033".freeze #formerly \e
    BASH_COLOR_NORMAL     = "[0m".freeze
    BASH_COLOR_BOLD       = "[37;1m".freeze

    NAME_DEFAULT_STREAM = "Default Stream Logger".freeze
    NAME_DEFAULT_FILE   = "Default File Logger".freeze

    module Defaults

      CATEGORY_COLORS = { debug: "[35m",
                          info:  "[34m",

                          warn:  "[33m",
                          error: "[31m",
                          fatal: "[31;1m",
                          other: "[32m" }.freeze

      CATEGORIES = CATEGORY_COLORS.keys.freeze

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