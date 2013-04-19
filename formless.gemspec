$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'formless'

Gem::Specification.new 'formless', Formless::VERSION do |s|
  s.summary           = "Unobtrusive form populator for web applications."
  s.description       = "Completely transparent, unobtrusive form populator for web applications and content scrapers."
  s.authors           = ["Tom Wardrop"]
  s.email             = "tom@tomwardrop.com"
  s.homepage          = "http://github.com/wardrop/Formless"
  s.files             = Dir.glob(`git ls-files`.split("\n") - %w[.gitignore])
  s.test_files        = Dir.glob('spec/**/*_spec.rb')
  s.rdoc_options      = %w[--line-numbers --inline-source --title Scorched --encoding=UTF-8]

  s.required_ruby_version = '>= 1.9.3'

  s.add_dependency 'nokogiri', '~> 1.5'
  s.add_development_dependency 'rspec', '~> 2.9'
end