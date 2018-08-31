# Zog - an alternate logger
# (C) 2012, 2014, 2016  Lyjia
# Certain portions (C) their respective copyright holders
# http://www.github.com/lyjia
# version 0.5

require 'zog/constants'
require 'zog/outputs/file_logger'
require 'zog/outputs/stream_logger'
require 'zog/body'

module Zog

  @@zog ||= Zog::Body.new

  # We don't want the user to instantiate this module,
  # so override instantiation to a return Zog::Body instance
  def self.new(**params)
    return Zog::Body.new(*params)
  end

  # We want our user to think this module is the logger, so redirect pretty much all calls to
  # Zog::Body
  def self.method_missing(meth, *args, &block)
    @@zog.send(meth, *args, &block)
  end

end
