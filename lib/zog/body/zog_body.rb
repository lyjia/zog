module Zog
  module Body

    class ZogBody

      if defined?(Rails)
        @@log_dir = "#{Rails.root}/log"
      else
        @@log_dir = "#{Dir.pwd}/log"
      end

      Dir.mkdir(@@log_dir) unless File.exist?(@@log_dir)
      @@log_filename = "#{@@log_dir}/Zog.log"

      @@log      = File.open(@@log_filename, 'a')
      @@silenced = false

      LOG_CATS     = Constants::Defaults::COLORS
      ESC_PREFIX   = Constants::BASH_COLOR_ESC_PREFIX
      COLOR_NORMAL = Constants::BASH_COLOR_NORMAL

      OUTPUTS = {
          stream: [Zog::Outputs::StreamLogger],
          file:   [Zog::Outputs::FileLogger],

          # names from 0.4
          display: [Zog::Outputs::StreamLogger],
          both:    [Zog::Outputs::StreamLogger, Zog::Outputs::FileLogger]
      }

      TYPES        = OUTPUTS.keys

      @@allowed_disp = LOG_CATS.keys
      @@allowed_log  = LOG_CATS.keys

      @@allowed = {

      }


      # User-facing functions
      def self.allow_only(type = :both, cats = [])
        raise ArgumentError, "Invalid type #{type}, must be one of these symbols: " << TYPES.join(" ") unless TYPES.include?(type)

        cats.each do |c|
          raise ArgumentError, "Invalid category #{c}, must be one of these symbols: " << LOG_CATS.keys.join(" ") unless LOG_CATS.keys.include?(c)
        end

        @@allowed_disp << cats
        @@allowed_log << cats

        self.info("Allowed categories changed. Display: #{@@allowed_disp}, log: #{@@allowed_log}")

      end


      def self.deny(type = :both, cats = [])
        raise ArgumentError, "Invalid type, must be one of these symbols: " << TYPES.join(" ") unless TYPES.include?(type)

        cats.each do |c|
          if type == :both || type == :display
            @@allowed_disp.delete(c)
          end

          if type == :both || type == :log
            @@allowed_log.delete(c)
          end
        end

        self.info("Allowed categories changed. Display: #{@@allowed_disp}, log: #{@@allowed_log}")
      end


      def self.reset
        @@allowed_disp = LOG_CATS.keys
        @@allowed_log  = LOG_CATS.keys
        self.info("Allowed categories changed. Display: #{@@allowed_disp}, log: #{@@allowed_log}")
      end


      def self.shut_up!
        Zog.debug("Shutting up...")
        @@silenced = true
      end


      def self.talk_again!
        @@silenced = false
        Zog.debug("I can talk again!")
      end


      # responds to Zog.info, Zog.error, etc
      def self.method_missing(meth, *args, &block)

        #$stderr.puts "MM: Is meth '#{meth}' a valid word from #{LOG_CATS.keys}? (#{LOG_CATS.keys.include?(meth)})"
        meth = meth.downcase.to_sym

        if LOG_CATS.keys.include?(meth)
          self::msg(meth, args[0])
        else
          super
        end

      end


      private


      def self.msg(level, msg)
        m = self.format_message(level, msg)

        displayer = :puts
        writer    = :Zog

        unless @@silenced == true

          if @@allowed_disp.include?(level)
            case displayer
            when :puts
              $stderr.puts Zog::colorize(level, m)
            end
          end

          if @@allowed_log.include?(level)
            case writer
            when :Zog
              @@log.puts m.join(" ")
              @@log.flush
            end
          end

        end

      end


      # class-level internal functions
      def self.format_message(severity, msg)
        hello = self::get_my_caller()
        ["#{Time.now.strftime("%Y%m%d-%H%M%S")} #{severity} in #{hello}():", "#{msg}"]
      end


      def self.colorize(severity, msg)

        color = LOG_CATS[severity.downcase.to_sym]

        col = "#{ESC_PREFIX}#{color}"
        if [:error, :fatal].include?(severity)
          white = "#{ESC_PREFIX}[37;1m"
        else
          white = "#{ESC_PREFIX}#{COLOR_NORMAL}"
        end
        reset = "#{ESC_PREFIX}#{COLOR_NORMAL}"

        return "#{col}#{msg[0]} #{white}#{msg[1]}#{reset}"

      end


      def self.get_my_caller()
        #s = caller.grep(/\/app\//)[2]
        #/in .([^']+)/.match(s)
        #ap caller
        #$1
        step = 3
        caller(step + 1)[0][/`.*'/][1..-2]
      end


    end
  end
end