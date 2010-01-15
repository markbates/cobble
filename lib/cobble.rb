require 'singleton'
require 'faker'

Dir.glob(File.join(File.dirname(__FILE__), 'cobble', '**/*.rb')).each do |f|
  require File.expand_path(f)
end

def Cobble(name, *args, &block)
  Cobble.create(name, *args, &block)
end

def Factory(name, *args, &block)
  puts "*** WARNING *** You should migrate over to using the proper Cobble methods as this won't be here forever!"
  Cobble.create(name, *args, &block)
end
