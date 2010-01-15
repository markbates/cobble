require 'spec_helper'

describe Cobble::Binding do
  
  describe 'initialize' do
    
    it 'should set options to an empty hash' do
      fb = Cobble::Binding.new(:foo)
      fb.options.should == {}
    end
    
    it 'should set the options eql to a hash' do
      fb = Cobble::Binding.new(:foo, :one => 1)
      fb.options.should == {:one => 1}
    end
    
    it 'should set options to an emtpy hash if it doesnt know what else to do' do
      fb = Cobble::Binding.new(:foo, 1)
      fb.options.should == {}
    end
    
    it 'should work through an Array' do
      fb = Cobble::Binding.new(:foo, [])
      fb.options.should == {}
      
      fb = Cobble::Binding.new(:foo, [1, 2, 3])
      fb.options.should == {}
      
      fb = Cobble::Binding.new(:foo, [1, {:two => 2}, 3])
      fb.options.should == {:two => 2}
      
      fb = Cobble::Binding.new(:foo, [1, {:two => 2}, {:three => 3}])
      fb.options.should == {:two => 2}
    end
    
  end
  
  describe 'fake' do
    
    it 'should pass the call onto Cobble::Fakes' do
      fb = Cobble::Binding.new(:foo)
      fb.fake(:email).should == 'bill.smith@example.org'
    end
    
  end
  
  describe 'eval_options' do
    
    it 'should process any procs in the options' do
      fb = Cobble::Binding.new(:foo, :one => 1, :email => lambda {fake(:email)})
      fb.execute {}
      fb.options.should == {:one => 1, :email => 'bill.smith@example.org'}
      
      Cobble.define_attributes(:user, :name => lambda {fake(:name)}, :email => lambda {fake(:email)}, 
                                               :password => 'password', :password_confirmation => 'password', :rating => 'G')
      
      Cobble.define(:user) do
        options
      end
      Cobble.build_user.should == {:name => 'Bill Smith', :email => 'bill.smith@example.org', :password => 'password', :password_confirmation => 'password', :rating => 'G'}
    end
    
  end
  
  describe 'attributes_for' do
    
    before(:each) do
      Cobble.define_attributes(:person, :name => 'Mark Bates')
      Cobble.define(:person) do
        options
      end
      
      Cobble.define_attributes(:mark_user, :name => 'Mark Bates')
      Cobble.define(:user, :attributes_for => :mark_user) do
        options
      end
    end
    
    it 'should merge in options that have been previously defined' do
      fb = Cobble::Binding.new(:foo, :one => 1, :email => lambda {fake(:email)}, :attributes_for => :mark_user)
      fb.execute {}
      fb.options.should == {:one => 1, :email => 'bill.smith@example.org', :name => 'Mark Bates'}
      
      Cobble.build_user.should == {:name => 'Mark Bates'}
      Cobble.build_user(:one => 1).should == {:one => 1, :name => 'Mark Bates'}
    end
    
    it 'should automatically try to merge in attributes as the same name as the factory' do
      Cobble.build_person.should == {:name => 'Mark Bates'}
    end
    
  end
  
  describe 'method_missing' do
    
    before(:each) do
      Cobble.define_attributes(:person, :name => 'Mark Bates')
      Cobble.define(:person) do
        user do
          Cobble.user
        end
        person = Person.new
        person.user = options[:user]
        person
      end
      
      Cobble.define(:user) do
        User.new
      end
    end
    
    it 'should call another factory' do
      person = Cobble.build_person
      person.user.should be_kind_of(User)
      
      person = Cobble.person
      person.user.should be_kind_of(User)
    end
    
  end
  
end
