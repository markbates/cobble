class Cobble
  include Singleton
  
  attr_accessor :factories
  attr_accessor :attributes
  
  def initialize
    self.reset!
  end
  
  def reset!
    self.factories = {}
    self.attributes = {}
  end
  
  def define(factory_name, options = {}, &block)
    self.factories[factory_name.to_sym] = [options, block]
  end
  
  def define_attributes(name, options = {})
    self.attributes[name.to_sym] = options
  end
  
  def attribs(name)
    self.attributes[name.to_sym] || {}
  end
  
  def build(factory, *args, &block)
    return execute(factory.to_sym, :build, *args)
  end
  
  def create(factory, *args, &block)
    res = self.execute(factory.to_sym, :create, *args)
    res.save!
    return res
  end
  
  def attributes_for(factory, *args, &block)
    fb = self.cobble_binding(factory.to_sym, :build, *args)
    fb.execute {}
    return fb.options
  end
  
  def method_missing(sym, *args, &block)
    meth = sym.to_s
    case meth
    when /^build_(.+)$/
      return self.build($1, *args, &block)
    when /^attributes_for_(.+)$/
      return self.attributes_for($1, *args, &block)
    when /^create_(.+)$/
      return self.create($1, *args, &block)
    else
      return self.create(sym, *args, &block)
    end
  end
  
  class << self
    
    def method_missing(sym, *args, &block)
      Cobble.instance.send(sym, *args, &block)
    end
    
  end
  
  protected
  def cobble_binding(name, type, *args)
    factory = self.factories[name.to_sym]
    raise ArgumentError.new("No Factory defined for '#{name}'!!!") if factory.nil?
    
    fb = Cobble::Binding.new(name.to_sym, *args)
    fb.type = type
    options = (factory[0] || {}).dup
    attr_for = options.delete(:attributes_for)
    if attr_for
      fb.attributes_for(attr_for)
    end
    return fb
  end
  
  def execute(name, type, *args)
    factory = self.factories[name.to_sym]
    fb = cobble_binding(name, type, *args)
    return fb.execute(&factory[1])
  end
  
end