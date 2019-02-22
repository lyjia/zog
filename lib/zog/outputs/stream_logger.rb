require 'zog/outputs/base'
require 'ice_nine'
require 'ice_nine/core_ext/object'

module Zog
  module Outputs
    class StreamLogger < Zog::Outputs::Base

      #LOG_CATS     = Constants::Defaults::CATEGORIES.freeze

      DEFAULT_CONFIG = Constants::Defaults::CONFIG.merge({
                                                             stream:                   $stderr,
                                                             stream_colorize:          true,
                                                             stream_categories_bolded: [:error, :fatal],
                                                             stream_categories_colors: Constants::Defaults::CATEGORIES.map {|cat, details| [cat, details[:color]]}.to_h,
                                                             stream_color_normal:      Constants::BASH_COLOR_NORMAL,
                                                             stream_color_bold:        Constants::BASH_COLOR_BOLD,
                                                             stream_color_escape:      Constants::BASH_COLOR_ESC_PREFIX
                                                         }) # can't deep freeze this

      # functions called by Zog::Heart
      def msg(severity, message, kaller)

        output = Zog::Heart::standard_formatter(kaller, message, severity, @config[:format_output], @config[:format_date])

        if @config[:stream_colorize] == true
          output = stream_colorize(output, severity)
        end

        message = Zog::Heart.format_message(output)
        @config[:stream].puts(message)
        @config[:stream].flush

        return
      end


      # config
      def configure!(**config)
        super(DEFAULT_CONFIG.merge(config))

        # set colorization fields ahead of time
        @format = @config[:format_output]
        @escape = @config[:stream_color_escape]
        @cats   = @config[:stream_categories_colors]

        @normal = @config[:stream_color_normal]
        @bold   = @config[:stream_color_bold]

        return
      end


      private

      def stream_colorize(output, severity)

        @format.each_index do |i|

          case @format[i]

            when :severity, :caller #colored by severity
              color     ||= @cats[severity.to_sym]
              output[i] = @escape + color + output[i]

            when :message, :datestamp #colored white
              if @config[:stream_categories_bolded].include?(severity)
                output[i] = @escape + @bold + output[i]
              else
                output[i] = @escape + @normal + output[i]
              end

          end

          if @format[i].is_a?(String)
            if @config[:stream_categories_bolded].include?(severity)
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