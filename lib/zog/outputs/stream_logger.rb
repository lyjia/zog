require 'zog/outputs/base'

module Zog
  module Outputs
    class StreamLogger < Zog::Outputs::Base

      #LOG_CATS     = Constants::Defaults::CATEGORIES.freeze

      DEFAULT_CONFIG = Constants::Defaults::CONFIG.merge({
                                                             stream:            $stderr,
                                                             colorize:          true,
                                                             categories_bolded: [:error, :fatal],
                                                             categories_colors: Constants::Defaults::CATEGORY_COLORS,
                                                             color_normal:      Constants::BASH_COLOR_NORMAL,
                                                             color_bold:        Constants::BASH_COLOR_BOLD,
                                                             color_escape:      Constants::BASH_COLOR_ESC_PREFIX
                                                         }).freeze

      # functions called by Zog::Heart
      def msg(severity, message, kaller)

        output = Zog::Heart::standard_formatter(kaller, message, severity, @config[:format_output], @config[:format_date])

        if @config[:colorize] == true
          output = colorize(output, severity)
        end

        message = Zog::Heart.format_message(output)
        @config[:stream].puts(message)
        @config[:stream].flush

        return
      end

      # config
      def configure!(config)
        super(DEFAULT_CONFIG.merge(config || {}))

        # set colorization fields ahead of time
        @format = @config[:format_output]
        @escape = @config[:color_escape]
        @cats   = @config[:categories_colors]

        @normal = @config[:color_normal]
        @bold   = @config[:color_bold]

        return
      end


      private


      def colorize(output, severity)

        @format.each_index do |i|

          case @format[i]

            when :severity, :caller #colored by severity
              color     ||= @cats[severity.to_sym]
              output[i] = @escape + color + output[i]

            when :message, :datestamp #colored white
              if @config[:categories_bolded].include?(severity)
                output[i] = @escape + @bold + output[i]
              else
                output[i] = @escape + @normal + output[i]
              end

          end

          if @format[i].is_a?(String)
            if @config[:categories_bolded].include?(severity)
              output[i] = @escape + @bold + output[i]
            else
              output[i] = @escape + @normal + output[i]
            end
          end

        end

        #clear our colors from the terminal
        output << @escape + Constants::BASH_COLOR_NORMAL
        return output

      end
    end
  end
end