# The Heart of Zog
# This class represents the logger and shunts messages to outputs
# module Zog will:
#    - Instantiate a single instance of me on startup and act as a singleton of me
#    - Return a newly-instantiated version of me when new() is called to it

module Zog
  class Heart

    RESERVED_NAME_ALL = :all

    OUTPUT_TYPES = {
        stream: [Zog::Outputs::StreamLogger],
        file:   [Zog::Outputs::FileLogger],

        # names from 0.4
        display: [Zog::Outputs::StreamLogger],
        both:    [Zog::Outputs::StreamLogger, Zog::Outputs::FileLogger]
    }

    TYPES = OUTPUT_TYPES.keys

    # User-facing functions
    def initialize(steps = Constants::Defaults::DEFAULT_NUM_STEPS, **config)
      # not configurable
      @all_categories = Constants::Defaults::CATEGORIES # The global pool of categories that all outputters draw from

      # configurable
      @caller_steps = steps # Nbr of steps the caller detector needs to traverse up the call stack
      @outputs      = {} # All output objects, by output name (key)
      @silenced     = false # Override, mute all outputs (TODO: remove?)

      configure(**config)
    end


    def reset()
      remove_all_outputs
      add_output(:stream, :stream, nice_name: "Default Stream Writer")
      add_output(:file, :file, nice_name: "Default File Writer")
      self._zog_internal("Logging configuration loaded.")
    end

    def configure(**config)

      if config == {}
        reset
      else

      end

    end

    def allow_only(name, cats = CATEGORY_NAMES_MINUS_INTERNAL)
      allowed_outputs = validate_names(name)
      cats            = validate_categories(cats)

      allowed_outputs.each do |output_name|
        @outputs[output_name][:all_categories] = cats
      end

      report_allowed_categories_change
      return
    end


    def allow(name, cats = [])
      allowed_outputs = validate_names(name)
      cats            = validate_categories(cats)

      allowed_outputs.each do |output_name|
        cats.each do |c|
          @outputs[output_name][:all_categories] += c
        end
      end

      report_allowed_categories_change
      return
    end


    def deny(name, cats = [])
      allowed_outputs = validate_names(name)
      cats            = validate_categories(cats)

      allowed_outputs.each do |output_name|
        cats.each do |c|
          @outputs[output_name][:all_categories] -= [c]
        end
      end

      report_allowed_categories_change
      return
    end


    def silence!
      self._zog_internal("Shutting up...")
      @silenced = true
    end


    def talk_again!
      @silenced = false
      self._zog_internal("I can talk again!")
    end


    alias_method :shut_up!, :silence!


    # This is what responds to Zog.info, Zog.error, etc
    def method_missing(meth, *args, &block)

      if @all_categories.include?(meth)

        if block_given?
          args[0] = yield block
        end

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
          if v[:all_categories].include?(severity)
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


    def validate_names(output_names)

      if output_names == RESERVED_NAME_ALL
        output_names = @outputs.keys
      elsif !output_names.is_a?(Array)
        output_names = [output_name]
      end

      # validate output names
      output_names.each do |out|
        raise ArgumentError, "Invalid output name #{out}, must be one of these names: " << @outputs.keys.map {|a| a.is_a?(Symbol) ? ":#{a}" : "\"#{a}\""}.join(" ") unless @outputs.keys.include?(out)
      end

      return output_names

    end


    def validate_categories(cats)
      cats = [cats] unless cats.is_a?(Array)

      # validate category names
      raise ArgumentError, "You didn't specify any categories!" << nag_categories if cats.length == 0 || cats[0].nil?

      cats.each do |c|
        raise ArgumentError, "Invalid category: '#{c}'." << nag_categories unless @all_categories.keys.include?(c)
      end

      return cats
    end


    # @return [Array] List of classes specified by the output type
    def validate_output_type(output_type)
      output_type = output_type.to_sym
      raise ArgumentError, "Type '#{output_type}' must be one of these: #{OUTPUT_TYPES.keys.join(", ")}" unless OUTPUT_TYPES.keys.include?(output_type)
      return OUTPUT_TYPES[output_type].map {|x| x}
    end


    def report_allowed_categories_change
      self._zog_internal("Allowed categories changed. Setting is now:" + @outputs.map {|k, v| "#{k}: #{v[:all_categories].join(",")}"}.join(" "))
    end


    ## Output manipulation
    def add_output(name, output_type, **config)
      output_classes = validate_output_type(output_type)
      raise ArgumentError, "Output '#{name}' already exists! Call remove_output('#{name}') first." if @outputs[name]

      #categories  = validate_categories(config[:categories] || Constants::Defaults::CATEGORY_NAMES_MINUS_INTERNAL)
      categories = validate_categories(config[:all_categories] || Constants::Defaults::CATEGORIES.keys)

      @outputs[name] = {
          #config
          config:         config,
          all_categories: categories,

          #objects
          outs: output_classes.map {|x| x.new(config)},
      }

    end


    def update_output(name, **config)
      raise ArgumentError "Output '#{name}' does not exist!" unless @outputs[name].present?

      if @outputs[name][:config] = config

        if config[:all_categories]
          @outputs[name][:all_categories] = categories
        end

        @outputs[name][:outs].each(&:configure!)

      end

    end


    def remove_output(name)
      raise ArgumentError "Output '#{name}' does not exist!" unless @outputs[name].present?

      @outputs[name][:outs].each(&:die!)
      return delete @outputs[name]
    end


    def remove_all_outputs
      @outputs.each do |k, v|
        remove_output(k)
      end
    end


    def nag_categories()
      " Please provide a scalar or array with any of these values: " << @all_categories.keys.join(" ")
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