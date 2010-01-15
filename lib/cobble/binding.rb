class Cobble
  class Binding
    attr_accessor :name
    attr_accessor :type
    attr_accessor :options
    attr_accessor :built_options # :nodoc:
  
    def initialize(name, options = {}) # :nodoc:
      self.name = name
      self.type = :build
      self.options = {}
      self.built_options = {}
      parse_options(options)

      self.attributes_for(name)
    
      attr_for = self.options.delete(:attributes_for)
      if attr_for
        self.attributes_for(attr_for)
      end
    end
  
    def fake(name, *args)
      Cobble::Fakes.execute(name.to_sym, *args)
    end
  
    def execute(&block)
      eval_options
      instance_eval(&block)
    end
  
    def attributes_for(names)
      [names].flatten.each do |name|
        self.options = Cobble.attribs(name).dup.merge(self.options)
      end
    end
  
    def method_missing(sym, *args, &block)
      val = self.options.delete(sym) || self.built_options[sym]
      unless val
        if block_given?
          val = yield
        end
      end
      self.built_options[sym] = val
      return val
    end
  
    private
    def parse_options(options)
      case options
      when Hash
        self.options = options
      when Array
        if options.empty?
          self.options = {}
        else
          options.each do |val|
            if val.is_a?(Hash)
              self.options = val
              break
            end
          end
        end
      end
    end
  
    def eval_options
      self.options.each do |key, val|
        if val.is_a?(Proc)
          self.options[key] = instance_eval(&val)
        end
      end
    end
  
  end # Binding
end # Cobble