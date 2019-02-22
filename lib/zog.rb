# Zog - an alternate logger
# (C) 2012, 2014, 2016  Lyjia
# Certain portions (C) their respective copyright holders
# http://www.github.com/lyjia
# version 0.5

require 'zog/constants'
require 'zog/outputs/file_logger'
require 'zog/outputs/stream_logger'
require 'zog/heart'

module Zog

  @@zog ||= Zog::Heart.new(Constants::Defaults::DEFAULT_NUM_STEPS)

  # We don't want the user to instantiate this module,
  # so fake #new and return a Zog::Body instance
  def self.new(**params)
    return Zog::Heart.new(Constants::Defaults::DEFAULT_NUM_STEPS_FAKE)
  end

  # We want our user to think this module is the logger, so redirect pretty much all calls to
  # Zog::Body
  def self.method_missing(meth, *args, &block)
    @@zog.send(meth, *args, &block)
  end

end
