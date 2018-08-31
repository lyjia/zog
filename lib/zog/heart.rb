# The Heart of Zog
# This class represents the logger and shunts messages to outputs
# module Zog will:
#    - Instantiate a single instance of me on startup and act as a singleton of me
#    - Return a newly-instantiated version of me when new() is called to it

module Zog
  class Heart

    LOG_CATS = Constants::Defaults::CATEGORIES

    RESERVED_NAME_ALL = :all

    OUTPUT_TYPES = {
        stream: [Zog::Outputs::StreamLogger],
        file:   [Zog::Outputs::FileLogger],

        # names from 0.4
        display: [Zog::Outputs::StreamLogger],
        both:    [Zog::Outputs::StreamLogger, Zog::Outputs::FileLogger]
    }

    TYPES = OUTPUT_TYPES.keys

    def initialize(steps = 3)

      @caller_steps = steps
      @outputs  = {}
      @silenced = false
      reset
    end


    # User-facing functions
    def allow_only(allowed_name, cats = [])
      allowed_outputs, cats = validate_categories_and_allowed_name(allowed_name, cats)

      allowed_outputs.each do |output_name|
        @outputs[output_name][:categories] = cats
      end

      report_allowed_categories_change
      return

    end


    def allow(allowed_name, cats = [])

      allowed_outputs, cats = validate_categories_and_allowed_name(allowed_name, cats)

      allowed_outputs.each do |output_name|
        cats.each do |c|
          @outputs[output_name][:categories] += c
        end
      end

      report_allowed_categories_change
      return

    end


    def deny(allowed_name, cats = [])
      allowed_outputs, cats = validate_categories_and_allowed_name(allowed_name, cats)

      allowed_outputs.each do |output_name|
        cats.each do |c|
          @outputs[output_name][:categories] -= c
        end
      end

      report_allowed_categories_change
      return


    end


    def reset
      remove_all_outputs
      add_output(:stream, Constants::NAME_DEFAULT_STREAM, categories: LOG_CATS)
      add_output(:file, Constants::NAME_DEFAULT_FILE, categories: LOG_CATS)
      self.info("Configuration loaded.")
    end


    def silence!
      self.debug("Shutting up...")
      @silenced = true
    end


    def talk_again!
      @silenced = false
      self.debug("I can talk again!")
    end


    alias_method :shut_up!, :silence!


    # responds to Zog.info, Zog.error, etc
    def method_missing(meth, *args, &block)

      #$stderr.puts "MM: Is meth '#{meth}' a valid word from #{LOG_CATS.keys}? (#{LOG_CATS.keys.include?(meth)})"
      meth = meth.downcase.to_sym

      if LOG_CATS.include?(meth)
        self::msg(meth, args[0])
      else
        super
      end

    end


    def msg(severity, msg)
      mycaller = self.class.get_my_caller(@caller_steps)

      unless @silenced

        @outputs.each do |a, v|
          outp = v[:outs]
          if v[:categories].include?(severity)
            outp.each {|x| x.msg(severity, msg, mycaller)}
          end
        end

      end

      return

      #m = self.class.format_message(severity, msg)

      # displayer = :puts
      # writer    = :Zog
      #
      # unless @silenced == true
      #
      #   if @outputs_disp.include?(severity)
      #     case displayer
      #     when :puts
      #       $stderr.puts self.class.colorize(severity, m)
      #     end
      #   end
      #
      #   if @outputs_log.include?(severity)
      #     case writer
      #     when :Zog
      #       @log.puts m.join(" ")
      #       @log.flush
      #     end
      #   end
      #
      # end

    end


    private


    def validate_categories_and_allowed_name(allowed_name, cats)

      if allowed_name.is_a?(Symbol) && allowed_name != RESERVED_NAME_ALL && @outputs.keys.include?(allowed_name)
        cats = [allowed_name]
        allowed_name = RESERVED_NAME_ALL
      end

      if allowed_name == RESERVED_NAME_ALL
        allowed_outputs = @outputs.keys
      else
        allowed_outputs = [allowed_name]
      end

      cats = [cats] unless cats.is_a?(Array)

      cats.each do |c|
        raise ArgumentError, "Invalid category #{c}, must be one of these symbols: " << LOG_CATS.keys.join(" ") unless LOG_CATS.keys.include?(c)
      end

      return allowed_outputs, cats
    end


    def report_allowed_categories_change
      self.info("Allowed categories changed. Setting is now:" + @outputs.map {|k, v| "#{k}: #{v[:categories].join(",")}"}.join(" "))
    end


    def add_output(output_type, name, categories: LOG_CATS.keys, config: nil)
      output_type = output_type.to_sym

      raise ArgumentError, "Type '#{output_type}' isn't one of these: #{OUTPUT_TYPES.keys.join(", ")}" unless OUTPUT_TYPES.keys.include?(output_type)
      raise ArgumentError, "Output '#{name}' already exists! You may want to call remove_output('#{name}') first." if @outputs[name]

      @outputs[name] = {
          #config
          categories: categories,
          config:     config,

          #objects
          outs: OUTPUT_TYPES[output_type].map {|x| x.new(config)},
      }

    end


    def update_output(name, categories: nil, config: nil)
      raise ArgumentError "Output '#{name}' doesn't exist! Outputs must first be created with add_allowed_output()"

      if categories
        @outputs[name][:categories] = categories
      end

      if config
        @outputs[name][:config] = config
      end

      if categories or config
        @outputs[name][:outs].each(&:configure!)
      end

    end


    def remove_output(name)

      if !@outputs[name].nil?
        @outputs[name][:outs].each(&:die!)
        delete @outputs[name]
      end

    end


    def remove_all_outputs
      @outputs.each do |k, v|
        remove_output(k)
      end
    end

    # class-level functions
    def self.standard_formatter(kaller, message, severity, format_output, format_date)
      df     = format_output
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
              output << Time.now.strftime(format_date)
          end

        elsif fmt.is_a?(String)

          output << fmt #these are strings that should be printed as-is

        else

          raise "Not a valid @format token: encounted a #{fmt.class} (only String and Symbol are allowed)"
        end

      end
      output
    end


    def self.get_my_caller(steps = 4)
      #s = caller.grep(/\/app\//)[2]
      #/in .([^']+)/.match(s)
      #ap caller
      #$1
      caller(steps + 1)[0][/`(.[^']+)'/] #extract function name from call stack to $1
      return $1
    end


    def self.format_message(output)
      output.join()
    end

  end
end