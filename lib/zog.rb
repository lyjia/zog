# Zog - an alternate logger
# (C) 2012  Lyjia
# http://www.github.com/lyjia
# version 1.1

class Zog

	if defined?(Rails) 
		@@log_dir = "#{Rails.root}/log"
	else
		@@log_dir = "#{Dir.pwd}/log"	
	end

  Dir.mkdir(@@log_dir) unless File.exist?(@@log_dir)
  @@log_filename = "#{@@log_dir}/Zog.log"

  @@log      = File.open(@@log_filename, 'a')
  @@silenced = false

  LOG_TYPES = { debug: "[35m",
                info:  "[34m",

                warn:  "[33m",
                error: "[31m",
                fatal: "[31;1m",
                other: "[32m" }

  ESC_PREFIX   = "\e"
  COLOR_NORMAL = "[0m"
  TYPES        = [:both, :display, :log]

  @@allowed_disp = LOG_TYPES.keys
  @@allowed_log  = LOG_TYPES.keys


  # User-facing functions
  def self.allow_only(type = :both, cats = [])
    raise ArgumentError, "Invalid type #{type}, must be one of these symbols: "<<TYPES.join(" ") unless TYPES.include?(type)

    cats.each do |c|
      raise ArgumentError, "Invalid category #{c}, must be one of these symbols: "<<LOG_TYPES.keys.join(" ") unless LOG_TYPES.keys.include?(c)
    end

    if type == :both || type == :display
      @@allowed_disp = []
      @@allowed_disp << cats
      @@allowed_disp.flatten!
    end

    if type == :both || type == :log
      @@allowed_log = []
      @@allowed_log << cats
      @@allowed_log.flatten!
    end

    self.info("Allowed categories changed. Display: #{@@allowed_disp}, log: #{@@allowed_log}")

  end

  def self.deny(type = :both, cats = [])
    raise ArgumentError, "Invalid type, must be one of these symbols: "<<TYPES.join(" ") unless TYPES.include?(type)

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
    @@allowed_disp = LOG_TYPES.keys
    @@allowed_log  = LOG_TYPES.keys
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

    #$stderr.puts "MM: Is meth '#{meth}' a valid word from #{LOG_TYPES.keys}? (#{LOG_TYPES.keys.include?(meth)})"
    meth = meth.downcase.to_sym

    if LOG_TYPES.keys.include?(meth)
      self::msg(meth, args[0])
    else
      super
    end

  end


  private

  # internal functions
  def self.format_message(severity, msg)
    hello = self::get_my_caller()
    ["#{Time.now.strftime("%Y%m%d-%H%M%S")} #{severity} #{hello}():", "#{msg}"]
  end


  def self.colorize(severity, msg)

    color = LOG_TYPES[severity.downcase.to_sym]

    col = "#{ESC_PREFIX}#{color}"
    if [:error, :fatal].include?(severity)
      white = "#{ESC_PREFIX}[37;1m"
    else
      white = "#{ESC_PREFIX}#{COLOR_NORMAL}"
    end
    reset = "#{ESC_PREFIX}#{COLOR_NORMAL}"

    return "#{col}#{msg[0]} #{white}#{msg[1]}#{reset}"

  end


  def self.msg(level, msg)
    m = Zog::format_message(level, msg)

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
        end
      end

    end

  end

	def self.get_my_caller()
		#s = caller.grep(/\/app\//)[2]
		#/in .([^']+)/.match(s)
		#ap caller
		#$1
		step = 3
		caller(step+1)[0][/`.*'/][1..-2]
	end


end
