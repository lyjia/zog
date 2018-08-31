# The Heart of Zog
# This class represents the logger and shunts messages to outputs
# module Zog will:
#    - Instantiate a single instance of me on startup and act as a singleton of me
#    - Return a newly-instantiated version of me when new() is called to it

module Zog
  class Heart

    LOG_CATS = Constants::Defaults::CATEGORIES

    OUTPUT_TYPES = {
        stream: [Zog::Outputs::StreamLogger],
        file:   [Zog::Outputs::FileLogger],

        # names from 0.4
        display: [Zog::Outputs::StreamLogger],
        both:    [Zog::Outputs::StreamLogger, Zog::Outputs::FileLogger]
    }

    TYPES = OUTPUT_TYPES.keys

    def initialize(steps = 3)

      # if defined?(Rails)
      #   @log_dir = "#{Rails.root}/log"
      # else
      #   @log_dir = "#{Dir.pwd}/log"
      # end
      #
      # Dir.mkdir(@log_dir) unless File.exist?(@log_dir)
      # @log_filename = "#{@log_dir}/Zog.log"
      #
      # @log      = File.open(@log_filename, 'a')

      @caller_steps = steps
      @outputs  = {}
      @silenced = false
      reset
    end


    # User-facing functions
    def allow_only(allowed_name, cats = [])

      cats = validate_categories(cats)

      @outputs[allowed_name][:categories] = cats

      report_allowed_categories_change
      return

    end


    def allow(allowed_name, cats = [])

      cats = validate_categories(cats)

      cats.each do |c|
        @outputs[allowed_name][:categories] += c
      end

      report_allowed_categories_change
      return

    end


    def deny(allowed_name, cats = [])

      cats = validate_categories(cats)

      cats.each do |c|
        @outputs[allowed_name][:categories] -= c
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


    def validate_categories(cats)
      raise ArgumentError, "Invalid type, must be one of these symbols: " << TYPES.join(" ") unless TYPES.include?(type)
      cats = [cats] unless cats.is_a?(Array)

      cats.each do |c|
        raise ArgumentError, "Invalid category #{c}, must be one of these symbols: " << LOG_CATS.keys.join(" ") unless LOG_CATS.keys.include?(c)
      end

      return cats
    end


    def report_allowed_categories_change
      self.info("Allowed categories changed. Setting is now:" + @outputs.map {|k, v| "#{k}: #{v[:categories].join(",")}"})
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


    # class-level internal functions
    def self.get_my_caller(steps = 4) #steps = 4 works for Zog as singleton. Zog as instance
      #s = caller.grep(/\/app\//)[2]
      #/in .([^']+)/.match(s)
      #ap caller
      #$1
      caller(steps + 1)[0][/`.*'/][1..-2]
    end


    def self.format_message(output, format)
      output.join()
    end

  end
end