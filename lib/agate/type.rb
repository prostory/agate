module Agate
  class DefList
    attr_accessor :name

    def initialize(name)
      @name = name
      @defs = {}
    end

    def <<(a_def)
      if @defs.has_key?(a_def.signature)
        @defs[a_def.signature].push a_def
      else
        @defs[a_def.signature] = [a_def]
        @defs = Hash[@defs.sort_by{|key, _| key}] if defs.size > 1
      end
    end

    def [](signature)
      list = @defs.values.find {|v| signature.child_of? v.last.signature}
      list.last if list
    end

    def to_s
      name
    end
  end

  class Defn
    def signature
    end
  end

  class Type
    attr_accessor :name
    attr_accessor :vars
    attr_accessor :defs

    def initialize(name)
      @name = name
      @vars = {}
      @defs = {}
    end

    def define_var(var)
      @vars[var.name] = var.type
    end

    def lookup_var(name)
      @vars[name]
    end

    def define_def(a_def)
      defs[a_def.name] ||= DefList.new(a_def.name)
      defs[a_def.name] << a_def
    end

    def lookup_def(name, signature)
      type = ancestors.find {|type| type.defs.has_key?(name)}
      type.defs[name][signature] if type
    end

    def ancestors
      []
    end
  end

  class ObjectType < Type
    attr_accessor :instances
    attr_accessor :class_type
    attr_accessor :parent

    def initialize(name, parent = nil, class_type = nil)
      super(name)
      @instances = []
      @parent = parent
      @class_type = class_type || ClassType.new(self, parent)
    end

    def ancestors
      class_type.ancestors
    end

    def lookup_def(name, signature)
      type = ancestors.find {|type| type.object_type.defs.has_key?(name)}
      type.object_type.defs[name][signature] if type
    end

    def include_module(mod)
      ancestors.insert(1, mod)
    end

    def new_instance
      instance = self.clone
      instances << instance
      instance
    end

    def define_ivar(var)
      define_var(var)
    end

    def lookup_ivar(name)
      lookup_var(name)
    end

    def define_cvar(var)
      class_type.define_var(var)
    end

    def lookup_cvar(name)
      class_type.lookup_var(name)
    end

    def define_const(const)
      class_type.define_const(const)
    end

    def lookup_const(name)
      class_type.lookup_const(name)
    end

    def clone
      self.class.new(name, parent, class_type)
    end
  end

  class ModuleType < ObjectType
  end

  class ClassType < Type
    attr_accessor :constants
    attr_accessor :ancestors
    attr_accessor :object_type

    def initialize(obj, parent = nil, modules = nil)
      super(obj.name)
      @constants = {}
      @ancestors = [self]
      modules.each {|mod| @ancestors.push *mod.ancestors } if modules
      @ancestors.push *parent.ancestors if parent
      @object_type = obj
    end

    def include_module(mod)
      @ancestors.insert(1, *mod.ancestors)
    end

    def lookup_var(name)
      type = ancestors.find {|type| type.vars.has_key?(name)}
      type.vars[name] if type
    end

    def define_ivar(var)
      object_type.define_var(var)
    end

    def lookup_ivar(name)
      object_type.lookup_var(name)
    end

    def define_cvar(var)
      define_var(var)
    end

    def lookup_cvar(name)
      lookup_var(name)
    end

    def define_const(const)
      constants[const.name] = const.type
    end

    def lookup_const(name)
      type = ancestors.find {|type| type.constants.has_key?(name)}
      type.constants[name] if type
    end

    def to_s
      name
    end
  end
end