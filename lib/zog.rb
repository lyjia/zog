# Zog - an alternate logger
# (C) 2012, 2014, 2016  Lyjia
# http://www.github.com/lyjia
# version 0.4

require 'zog/constants'
require 'zog/outputs/file_logger'
require 'zog/outputs/stream_logger'
require 'zog/body/zog_body'

module Zog #body moved to Zog::Body::ZogBody

  # We want our user to think this module is the logger, so redirect pretty much all calls to
  # Zog::Body::ZogBody
  def self.method_missing(meth, *args, &block)
    Zog::Body::ZogBody.send(meth, *args, &block)
  end

end
