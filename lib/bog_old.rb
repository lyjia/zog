
# Bog - an alternate logger
# (C) 2012  Lyjia
# http://www.github.com/lyjia
#version 1.1

class Bog

	if defined?(Rails) 
		@@log_dir = "#{Rails.root}/log"
	else
		@@log_dir = "#{Dir.pwd}/log"	
	end
	
	Dir.mkdir(@@log_dir) unless File.exist?(@@log_dir)
	@@log_filename = "#{@@log_dir}/bog.log"
	
	@@log = File.open(@@log_filename, 'a')
	@@silenced = false
	
	LOG_TYPES = { debug: "[35m", 
					info: "[34m", 
					warn: "[35;1m", 
					error: "[31m", 
					fatal: "[31;1m", 
					other: "[32m" }
					
	ESC_PREFIX = "\e"
	COLOR_NORMAL = "[0m"

	def self.format_message(severity, msg)
		hello = self::get_my_caller()
		["#{Time.now.strftime("%Y%m%d-%H%M%S")} #{severity} #{hello}():", "#{msg}"]
	end

	def self.shut_up!
		bog.debug("Shutting up...")
		@@silenced = true
	end

	def self.talk_again!
		@@silenced = false
		bog.debug("I can talk again!")
	end
	
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
		m = Bog::format_message(level, msg)
		
		displayer = :puts
		writer = :bog
		
		unless @@silenced == true
		
			case displayer
				when :puts
					$stderr.puts Bog::colorize(level, m)
			end
			
			case writer
				when :bog
					@@log.puts m.join(" ")					
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
