# Zog


[![Build Status](https://travis-ci.org/lyjia/zog.svg?branch=master)](https://travis-ci.org/lyjia/zog) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Zog is an advanced, multi-logging library for Ruby with a simple interface.

You can log to Zog through a globally-available `Zog` module, or manually instantiate multiple instances of `Zog` for whatever logging usage you see fit. While `Zog` instances are designed to be a drop-in replacement for Ruby's stdlib's `Logger` class, they extend `Logger`'s featureset with support for:
 * Unlimited outputs of multiple types (file logger, stream/stdout/stderr logger)
 * Unlimited toggleable category channels 
 * Advanced log message formatting support (color, bold, and more)
 * Caller identification within the log message

`Zog` makes debugging and monitoring your code a breeze!

Note that version 0.5 is currently ***in development***, do not use this in production code!
    

## Installation

Add this line to your application's Gemfile:

    gem 'zog'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install zog

## Usage (for 0.5)

By default, `Zog` manifests as a root singleton class of the same name. You can log to various channels by calling them from `Zog`, or a `Zog` instance.

For example:

	irb(main):> Zog.debug("Hello")
    20190101-120000 debug in irb_binding(): Hello
    => nil
	
	irb(main):> Zog.debug("Oh no! Something went wrong!")
    20190101-120001 error in irb_binding(): Oh no! Something went wrong!
    => nil
	
### Configuration


	
## Changelog

### 0.5 (Preliminary Changlist)

 - Major refactor to modularize and expand functionality
 - Added test suite and CI integration
 - File logger now uses Ruby's stdlib `logger`
 - `Zog` is now usable as a singleton or as an instantiated class
 - Added configurable channels, outputs, supports for any number in any combination
 - Documentation rework for 0.5 (TODO)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
