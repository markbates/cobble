class Cobble
  class Fakes
    include Singleton
  
    attr_accessor :list
  
    def initialize
      self.reset!
    end
  
    def reset!
      self.list = {}
    end
  
    def add(name, &block)
      self.list[name.to_sym] = block
    end
  
    def alias(from, to)
      self.list[from.to_sym] = Cobble::Fakes::Alias.new(to)
    end
  
    def execute(name, *args)
      block = self.list[name.to_sym]
      if block.is_a?(Cobble::Fakes::Alias)
        return execute(block.to, *args)
      end
      if block
        return block.call(*args)
      end
      raise Cobble::Errors::NoFakeRegistered.new(name)
    end
  
    class << self
      def method_missing(sym, *args, &block)
        Cobble::Fakes.instance.send(sym, *args, &block)
      end
    end # class << self
  
    private
    class Alias
      attr_accessor :to
      def initialize(to)
        self.to = to
      end
    end
    
  end # Fakes
end # Cobble

%w{first_name last_name name prefix suffix}.each do |m|
  eval("Cobble::Fakes.add(:#{m}) {|*args| Faker::Name.#{m}(*args)}")
end

%w{city city_prefix city_suffix secondary_address street_address street_name 
   street_suffix uk_country uk_county uk_postcode us_state us_state_abbr zip_code}.each do |m|
  eval("Cobble::Fakes.add(:#{m}) {|*args| Faker::Address.#{m}(*args)}")
end

%w{bs catch_phrase name suffix}.each do |m|
  eval("Cobble::Fakes.add(:#{m}) {|*args| Faker::Company.#{m}(*args)}")
end

%w{domain_name domain_suffix domain_word email free_email user_name}.each do |m|
  eval("Cobble::Fakes.add(:#{m}) {|*args| Faker::Internet.#{m}(*args)}")
end

%w{paragraph paragraphs sentence sentences words}.each do |m|
  eval("Cobble::Fakes.add(:#{m}) {|*args| Faker::Lorem.#{m}(*args)}")
end

%w{phone_number}.each do |m|
  eval("Cobble::Fakes.add(:#{m}) {|*args| Faker::PhoneNumber.#{m}(*args)}")
end

Cobble::Fakes.add(:url) {|*args| 'http://' + Faker::Internet.domain_name(*args)}
Cobble::Fakes.add(:lorem) {|*args| Faker::Lorem.paragraphs(*args).join("\n")}
Cobble::Fakes.add(:name) {|*args| Faker::Name.first_name + ' ' + Faker::Name.last_name}
Cobble::Fakes.add(:birth_date) {|*args| (rand(80) + 13).years.ago}
Cobble::Fakes.add(:title) {|*args| Faker::Company.catch_phrase.slice(0..250)}
Cobble::Fakes.alias(:body, :lorem)
Cobble::Fakes.alias(:full_name, :name)
