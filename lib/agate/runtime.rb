require 'blankslate'

module Agate
  class Runtime < BlankSlate
    module Kernel
      instance_variable_set(:@type, ModuleType.new(simple_name.to_sym))

      def self.included(obj)
        super
        type = obj.instance_variable_get(:@type)
        type.include_module(@type) if type
      end
    end

    class BasicObject < ::BasicObject
      instance_variable_set(:@type, ObjectType.new(simple_name.to_sym))

      def self.inherited(subclass)
        super
        type = ObjectType.new(subclass.simple_name.to_sym, @type)
        subclass.instance_variable_set(:@type, type)
      end
    end

    class Object < BasicObject
      include Kernel
    end

    class Module < Object
    end

    class Class < Module
    end

    module Comparable
      instance_variable_set(:@type, ModuleType.new(simple_name.to_sym))

      def self.included(obj)
        super
        type = obj.instance_variable_get(:@type)
        type.include_module(instance_variable_get(:@type)) if type
      end
    end

    class Numeric < Object
      include Comparable
    end

    class Integer < Numeric
    end

    class Fixnum < Integer
    end

    class Float < Numeric
    end

    class String < Object
    end

    class NilClass < Object
    end

    class Quote < Object
    end

    module Enumerable
      instance_variable_set(:@type, ModuleType.new(simple_name.to_sym))

      def self.included(obj)
        super
        type = obj.instance_variable_get(:@type)
        type.include_module(instance_variable_get(:@type)) if type
      end
    end

    class VarList < Object
      include Enumerable
    end

    class Block < Object
    end
  end
end