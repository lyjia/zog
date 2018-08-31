require 'zog/outputs/base'

module Zog
  module Outputs
    class StreamLogger < Zog::Outputs::Base

      #LOG_CATS     = Constants::Defaults::CATEGORIES.freeze

      DEFAULT_CONFIG.merge!({
                                stream:            $stderr,
                                colorize:          true,
                                categories_bolded: [:error, :fatal],
                                color_normal:      Constants::BASH_COLOR_NORMAL,
                                color_bold:        Constants::BASH_COLOR_BOLD,
                                color_escape:      Constants::BASH_COLOR_ESC_PREFIX
                            }).freeze

      # user-facing functions
      def msg(severity, message, kaller)

        df     = @config[:format_output]
        output = []

        df.each do |fmt|

          if fmt.is_a?(Symbol)

            case fmt
              when :severity
                output << severity.to_s
              when :caller
                output << kaller
              when :message
                output << message
              when :datestamp
                output << Time.now.strftime(@config[:format_date])
            end

          elsif fmt.is_a?(String)

            output << fmt #these are strings that should be printed as-is

          else

            raise "Not a valid format token: encounted a #{fmt.class} (only String and Symbol are allowed)"
          end

        end

        if @config[:colorize] == true
          output = colorize(output, severity)
        end

        message = Zog::Body.format_message(output, @config)
        @config[:stream].puts(message)
        @config[:stream].flush

        return
      end


      private


      # config
      def configure!(config)
        super(DEFAULT_CONFIG.merge(config || {}))
        return
      end


      def colorize(output, severity)
        format   = @config[:format_output]
        escape   = @config[:color_escape]
        cats     = @config[:categories]

        format.each_index do |i|

          case format[i]

            when :severity, :caller #colored by severity
              color     ||= cats[severity.to_sym]
              output[i] = "#{escape}#{color}#{output[i]}"

            when :message, :datestamp #colored white
              if @config[:categories_bolded].include?(severity)
                output[i] = "#{escape}#{@config[:color_bold]}#{output[i]}"
              else
                output[i] = "#{escape}#{@config[:color_normal]}#{output[i]}"
              end

          end

          if format[i].is_a?(String)
            if @config[:categories_bolded].include?(severity)
              output[i] = "#{escape}#{@config[:color_bold]}#{output[i]}"
            else
              output[i] = "#{escape}#{@config[:color_normal]}#{output[i]}"
            end
          end

        end

        #finally add a bash escape
        output << escape + Constants::BASH_COLOR_NORMAL
        pp output
        return output

      end
    end
  end
end