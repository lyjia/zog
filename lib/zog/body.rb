module Zog
  class Body

    LOG_CATS     = Constants::Defaults::CATEGORIES

    OUTPUTS = {
        stream: [Zog::Outputs::StreamLogger],
        file:   [Zog::Outputs::FileLogger],

        # names from 0.4
        display: [Zog::Outputs::StreamLogger],
        both:    [Zog::Outputs::StreamLogger, Zog::Outputs::FileLogger]
    }

    TYPES = OUTPUTS.keys

    def initialize

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
      @allowed = {}
      @silenced = false
      reset
    end


    # User-facing functions
    def allow_only(type = :both, cats = [])
      raise ArgumentError, "Invalid type #{type}, must be one of these symbols: " << TYPES.join(" ") unless TYPES.include?(type)

      cats.each do |c|
        raise ArgumentError, "Invalid category #{c}, must be one of these symbols: " << LOG_CATS.keys.join(" ") unless LOG_CATS.keys.include?(c)
      end

      self.info("Allowed categories changed. Display: #{@allowed_disp}, log: #{@allowed_log}")

    end


    def deny(type = :both, cats = [])
      raise ArgumentError, "Invalid type, must be one of these symbols: " << TYPES.join(" ") unless TYPES.include?(type)

      cats.each do |c|
        raise ArgumentError, "Invalid category #{c}, must be one of these symbols: " << LOG_CATS.keys.join(" ") unless LOG_CATS.keys.include?(c)
      end

      self.info("Allowed categories changed. Display: #{@allowed_disp}, log: #{@allowed_log}")
    end


    def reset
      remove_all_allowed
      add_allowed_output(:stream, "Default Stream Logger", categories: LOG_CATS)
      #add_allowed_output(:file, "Default File Logger", categories: LOG_CATS)
    end

    def shut_up!
      Zog.debug("Shutting up...")
      @silenced = true
    end


    def talk_again!
      @silenced = false
      Zog.debug("I can talk again!")
    end


    # responds to Zog.info, Zog.error, etc
    def method_missing(meth, *args, &block)

      #$stderr.puts "MM: Is meth '#{meth}' a valid word from #{LOG_CATS.keys}? (#{LOG_CATS.keys.include?(meth)})"
      meth = meth.downcase.to_sym

      if LOG_CATS.keys.include?(meth)
        self::msg(meth, args[0])
      else
        super
      end

    end


    def msg(severity, msg)
      mycaller = self.class.get_my_caller(3)

      unless @silenced

        @allowed.each do |a, v|
          outp = v[:outs]
          if v[:categories].include?(severity)
            outp.each { |x| x.msg(severity, msg, mycaller) }
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
      #   if @allowed_disp.include?(severity)
      #     case displayer
      #     when :puts
      #       $stderr.puts self.class.colorize(severity, m)
      #     end
      #   end
      #
      #   if @allowed_log.include?(severity)
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


    def add_allowed_output(type, name, categories: LOG_CATS.keys, config: nil)
      type = type.to_sym

      raise ArgumentError, "Type '#{type}' isn't one of these: #{OUTPUTS.keys.join(", ")}" unless OUTPUTS.keys.include?(type)
      raise ArgumentError, "Output '#{name}' already exists! You may want to call remove_allowed_output('#{name}') first." if @allowed[name]

      @allowed[name] = {
          #config
          categories: categories,
          config:     config,
          silenced:   false,

          #objects
          outs: OUTPUTS[type].map {|x| x.new(config)},
      }

    end


    # hook into manipulations of allowed state
    def update_allowed_output(name, categories: nil, config: nil)
      raise ArgumentError "Output '#{name}' doesn't exist! Outputs must first be created with add_allowed_output()"

      if categories
        @allowed[name][:categories] = categories
      end

      if config
        @allowed[name][:config] = config
      end

      if categories or config
        @allowed[name][:outs].each(&:configure!)
      end

    end


    def remove_allowed_output(name)

      if !@allowed[name].nil?
        @allowed[name][:outs].each(&:die!)
        delete @allowed[name]
      end

    end

    def remove_all_allowed
      @allowed.each do |k,v|
        remove_allowed_output(k)
      end
    end


    # class-level internal functions
    def self.get_my_caller(steps = 4)
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