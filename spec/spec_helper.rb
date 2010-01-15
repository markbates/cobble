require 'rubygems'
require 'spec'

require File.join(File.dirname(__FILE__), '..', 'lib', 'cobble')

Spec::Runner.configure do |config|
  
  config.before(:all) do
    
  end
  
  config.after(:all) do
    
  end
  
  config.before(:each) do
    Cobble.reset!
    @old_list = fakes.list.dup
  end
  
  config.after(:each) do
    fakes.list = @old_list
  end
  
end

Cobble::Fakes.add(:user_name) {'bill.smith'}
Cobble::Fakes.add(:email) {'bill.smith@example.org'}
Cobble::Fakes.add(:url) {'http://www.example.com'}
Cobble::Fakes.add(:name) {'Bill Smith'}

def fakes
  Cobble::Fakes.instance
end

class User
  attr_accessor :new_record
  attr_accessor :attributes
  
  def initialize(options = {})
    self.attributes = options
    self.new_record = true
  end
  
  def new_record?
    self.new_record
  end
  
  def save!
    self.new_record = false
  end
  
  def ==(other)
    !self.new_record? && !other.new_record? && (self.attributes == other.attributes)
  end
  
end

class Person < User
  attr_accessor :user
end
