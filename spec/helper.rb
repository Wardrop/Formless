require 'rack/test'
require_relative '../lib/formless.rb'

module GlobalConfig
  extend RSpec::SharedContext
  let(:html) do
    open(File.join __dir__, 'form.html').read
  end
end

RSpec.configure do |c|
  c.alias_example_to :they
  # c.backtrace_clean_patterns = []
  c.include GlobalConfig
end