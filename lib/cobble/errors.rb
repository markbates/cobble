class Cobble
  module Errors # :nodoc:
    class NoFakeRegistered < StandardError
      
      # Raised if Fake has been registered by that name.
      def initialize(name) # :nodoc:
        super("No fake has been registered for '#{name}'!")
      end
      
    end # NoFakeRegistered
  end # Errors
end # Cobble