# Bog

Bog is a simple logging library for Ruby applications, which renders messages with colorization and caller information attached.

## Installation

Add this line to your application's Gemfile:

    gem 'bog'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bog

## Usage

Bog will attempt to create a `log/` in the root of your project. (It checks `Rails.root` if it's available, otherwise `Dir.pwd`).

Bog manifests as a class of the same name. Various log channels are available as functions of `Bog`.

There are:

	Bog.debug("Yourtext")
	Bog.info("Yourtext")
	Bog.warn("Yourtext")
	Bog.error("Yourtext")
	Bog.fatal("Yourtext")
	Bog.other("Yourtext")

### Configuration

`Bog.shut_up!` and `Bog.talk_again` will disable and enable logging, respectively.

Log display levels can be modified, with a different setting for screen and disk output. Bog starts with all message types displayed in all categories, but can be configured with:

	Bog.deny(type = :both, categories = [])
	Bog.allow_only(type = :both, categories = [])

`type` must be `:display`, `:log`, or `:both`.
`categories` is an array of any of the following symbols: `:debug`, `:info`, `:warn`, `:error`, `:fatal`, `:other`

Configuration can be reset with:
	
	Bog.reset

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
