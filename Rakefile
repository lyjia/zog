require "bundler/gem_tasks"

desc "Open an irb session preloaded with this library"
task :console do
	sh "irb -rrubygems -I lib -r Zog.rb"
end

task :spec do #why do I need this???
  sh 'rspec'
end