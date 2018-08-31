require 'zog/outputs/base'
require 'logger'

module Zog
  module Outputs
    class FileLogger < Zog::Outputs::Base

      LOG_AGES = %w( daily weekly monthly )

      DEFAULT_CONFIG = Constants::Defaults::CONFIG.merge({
                                                             log_header:            ['====', 'Logging Started', :datestamp, '===='],
                                                             log_footer:            ['====', 'End of Log', :datestamp, '===='],
                                                             log_age:               nil,
                                                             log_size:              nil,
                                                             log_filename:          'zog.log',
                                                             log_use_stdlib_format: true,
                                                             log_open_mode:         nil
                                                         }).freeze

      # config
      def configure!(config)
        super(DEFAULT_CONFIG.merge(config || {}))

        if defined?(@logger) && !@logger.nil?
          @logger.close
        end

        # configure logger object
        if defined?(Rails)
          @log_dir = "#{Rails.root}/log"
        else
          @log_dir = "#{Dir.pwd}/log"
        end

        Dir.mkdir(@log_dir) unless File.exist?(@log_dir)
        @log_filename = "#{@log_dir}/#{@config[:log_filename]}"

        if @config[:log_open_mode]
          @log    = File.open(@log_filename, 'a')
          @logger = Logger.new(@log, @config[:log_age], @config[:log_size])
        else
          @logger = Logger.new(@log_filename, @config[:log_age], @config[:log_size])
        end

        #TODO: send any custom categories to Logger::UNKNOWN

        return

      end


      def msg(severity, message, kaller)

        if @config[:log_use_stdlib_format]
          @logger.add(get_stdlib_severity(severity), message, kaller)
        else
          output = Zog::Heart.standard_formatter(kaller, message, severity, @config[:format_output], @config[:format_date])
          @logger.add(get_stdlib_severity(severity), output, kaller)
        end

      end


      def get_stdlib_severity(severity)
        case severity
          when :debug
            return Logger::DEBUG
          when :info
            return Logger::INFO
          when :warn
            return Logger::WARN
          when :error
            return Logger::ERROR
          when :fatal
            return Logger::FATAL
          else
            return Logger::UNKNOWN
        end

      end


      def header_formatter(format)
        out = ""
        format.each do |fmt|
          if fmt.is_a?(String)
            out << fmt
          else
            case fmt
              when :datestamp
                out << Time.now.strftime(@config[:format_date])
              else
                raise ArgumentError, "Invalid token in header or footer format: #{fmt}."
            end
          end
        end
      end
    end
  end
end
