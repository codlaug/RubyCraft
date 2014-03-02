#!/usr/bin/env ruby
$LOAD_PATH.unshift File.join(File.dirname(__FILE__),'..','lib')
require 'rubycraft'
include RubyCraft


Dir[File.expand_path('../support/**/*.rb', __FILE__)].each {|f| require f}
