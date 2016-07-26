# Zog

Zog is a simple logging library for Ruby applications, which renders messages with colorization and caller information attached.

## Installation

Add this line to your application's Gemfile:

    gem 'zog'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install zog

## Usage

Zog will attempt to create a `log/` in the root of your project. (It checks `Rails.root` if it's available, otherwise `Dir.pwd`).

Zog manifests as a class of the same name. Various log channels are available as functions of `Zog`.

There are:

	Zog.debug("Yourtext")
	Zog.info("Yourtext")
	Zog.warn("Yourtext")
	Zog.error("Yourtext")
	Zog.fatal("Yourtext")
	Zog.other("Yourtext")

### Configuration

`Zog.shut_up!` and `Zog.talk_again` will disable and enable logging, respectively.

Log display levels can be modified, with a different setting for screen and disk output. Zog starts with all message types displayed in all categories, but can be configured with:

	Zog.deny(type = :both, categories = [])
	Zog.allow_only(type = :both, categories = [])

`type` must be `:display`, `:log`, or `:both`.

`categories` is an array of any of the following symbols: `:debug`, `:info`, `:warn`, `:error`, `:fatal`, `:other`

Configuration can be reset with:
	
	Zog.reset

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
