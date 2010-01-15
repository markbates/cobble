class Cobble
  module Errors
    class NoFakeRegistered < StandardError
      
      def initialize(name)
        super("No fake has been registered for '#{name}'!")
      end
      
    end # NoFakeRegistered
  end # Errors
end # Cobble