require_relative 'extend'
require_relative 'runtime'

module Agate
  class Context
    Scope = Struct.new(:vars, :type, :def)

    Runtime.constants(false).each do |name|
      klass = Runtime.const_get(name)
      type = klass.instance_variable_get(:@type)
      define_method(type.name.underscore) do
        type
      end
    end

    def initialize
      @main = object.new_instance
      @scopes = [Scope.new({}, @main)]
      @vars = {}
    end

    def define_lvar(var)
      scope.vars[var.name] = var.type
    end

    def lookup_lvar(name)
      scope.vars[name]
    end

    def define_ivar(var)
      scope.type.define_ivar(var)
    end

    def lookup_ivar(name)
      scope.type.lookup_ivar(name)
    end

    def define_cvar(var)
      scope.type.define_cvar(var)
    end

    def lookup_cvar(name)
      scope.type.lookup_cvar(name)
    end

    def define_gvar(var)
      @vars[var.name] = var.type
    end

    def lookup_gvar(name)
      @vars[name]
    end

    def define_const(const)
      scope.type.define_const(const)
    end

    def lookup_const(name)
      scope.type.lookup_const(name)
    end

    def define_def(a_def)
      scope = a_def.owner ? a_def.owner.type : scope.type
      scope.define_def a_def
    end

    def lookup_def(name, arg_types, type)
      type.lookup_def(name, arg_types) || main.lookup_def(name, arg_types)
    end

    def with_new_scope(a_def, type)
      @scopes.push(Scope.new({}, a_def, type))
      yield
      @scopes.pop
    end

    def scope
      @scopes.last
    end

    def type(name)
      @@types[name]
    end

    def main
      @main
    end
  end
end