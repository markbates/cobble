require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Cobble do

  before(:each) do
    Cobble.reset!
  end

  describe 'define' do
    
    it 'should register different factories' do
      Cobble.factories.should be_empty
      Cobble.define(:user) {}
      Cobble.factories.should_not be_empty
    end
    
  end
  
  describe 'define_attributes' do
    
    it 'should register different attributes' do
      Cobble.attributes.should be_empty
      Cobble.define_attributes(:user, {:name => 'Mark Bates'})
      Cobble.attributes.should_not be_empty
    end
    
  end
  
  describe 'attributes_for_*' do
    
    before(:each) do
      Cobble.define_attributes(:user, {:name => 'Mark Bates'})
      Cobble.define_attributes(:another_user, {:name => 'Mark Bates', :email => lambda{fake(:email)}})
      Cobble.define_attributes(:yet_another_user, {:email => lambda{rand}})
      Cobble.define(:user) do
        User.new(options)
      end
      Cobble.define(:another_user) do
        User.new(options)
      end
      Cobble.define(:yet_another_user) do
        User.new(options)
      end
    end
    
    it 'should return the attributes that have been defined' do
      Cobble.attributes_for_user.should == {:name => 'Mark Bates'}
    end
    
    it 'should execute the procs in the attributes' do
      Cobble.attributes_for_another_user.should == {:name => 'Mark Bates', :email => 'bill.smith@example.org'}
    end
    
    it 'should not cache the attributes' do
      Cobble.attributes_for_yet_another_user.should_not == Cobble.attributes_for_yet_another_user
    end
    
    it 'should map to attributes_for' do
      Cobble.attributes_for(:another_user).should == Cobble.attributes_for_another_user
      Cobble.attributes_for('another_user').should == Cobble.attributes_for_another_user
    end
    
  end
  
  describe 'build_*' do
    
    before(:each) do
      Cobble.define(:user) do
        {:email => fake(:email)}.merge(options)
      end
    end
    
    it 'should execute the block defined and except no args' do
      Cobble.build_user.should == {:email => 'bill.smith@example.org'}
    end
    
    it 'should execute the block defined and except Hash args' do
      Cobble.build_user(:name => 'Mark Bates').should == {:email => 'bill.smith@example.org', :name => 'Mark Bates'}
    end
    
    it 'should map to build' do
      Cobble.build(:user).should == Cobble.build_user
      Cobble.build('user').should == Cobble.build_user
    end
    
  end
  
  describe 'create' do
    
    before(:each) do
      Cobble.define(:user) do
        user = User.new(options)
        user
      end
    end
    
    it 'should save the object and return it' do
      user = Cobble.user
      user.should be_kind_of(User)
      user.should_not be_new_record
    end
    
    it 'should map to create' do
      Cobble.create(:user, :name => 'Mark').should == Cobble.user(:name => 'Mark')
      Cobble.create('user', :name => 'Mark').should == Cobble.user(:name => 'Mark')
    end
    
  end

end
