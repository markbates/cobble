require 'spec_helper'

describe Cobble::Fakes do
  
  describe 'execute' do
    
    it 'should execute a registered proc' do
      fakes.add(:add) {|x, y| x + y}
      fakes.execute(:add, 1, 3).should == 4
      fakes.add(:subtract) {|x, y| x - y}
      fakes.execute(:subtract, 9, 3).should == 6
    end
    
    it 'should raise an error if no registered proc' do
      lambda {
        fakes.execute(:i_dont_exist)
      }.should raise_error(Cobble::Errors::NoFakeRegistered, "No fake has been registered for 'i_dont_exist'!")
    end
    
    it 'should call an aliased proc' do
      fakes.list.should_not have_key(:ass_kicker)
      fakes.list.should_not have_key(:hard_ass)
      fakes.add(:ass_kicker) {'Jack Bauer'}
      fakes.execute(:ass_kicker).should == 'Jack Bauer'
      fakes.alias(:hard_ass, :ass_kicker)
      fakes.execute(:hard_ass).should == 'Jack Bauer'
    end
    
  end
  
  describe 'add' do
    
    it 'should add a new proc to the list' do
      fakes.list.should_not have_key(:ass_kicker)
      fakes.add(:ass_kicker) {'Jack Bauer'}
      fakes.list.should have_key(:ass_kicker)
    end
    
  end
  
  describe 'alias' do
    
    it 'should create an alias to another fake' do
      fakes.list.should_not have_key(:ass_kicker)
      fakes.list.should_not have_key(:hard_ass)
      fakes.add(:ass_kicker) {'Jack Bauer'}
      fakes.alias(:hard_ass, :ass_kicker)
      hard_ass = fakes.list[:hard_ass]
      hard_ass.should be_kind_of(Cobble::Fakes::Alias)
      hard_ass.to.should == :ass_kicker
    end
    
  end
  
end
