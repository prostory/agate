require_relative 'ast'
require_relative 'context'

module Agate
  class ASTNode
    attr_accessor :type
  end

  class TypeVisitor < Visitor
    attr_accessor :context

    def initialize(context)
      @context = context
    end

    def end_visit_block(node)
      if node.empty?
        node.type = context.nil_class
      else
        node.type = node.last.type
      end
    end

    def visit_nil(node)
      node.type = context.nil_class
      false
    end

    def visit_lit(node)
      case node.value
      when Fixnum
        node.type = context.fixnum
      when Float
        node.type = context.float
      end
      false
    end

    def visit_true(node)
      node.type = context.true_class
      false
    end

    def visit_false(node)
      node.type = context.false_class
      false
    end

    def visit_str(node)
      node.type = context.string
      false
    end

    def visit_xstr(node)
      node.type = context.quote
      false
    end

    def end_visit_evstr(node)
      node.type = context.string
    end

    def end_visit_dstr(node)
      node.type = context.string
    end

    def visit_lvar(node)
      node.type = context.lookup_lvar(node.name) or raise "variable '#{node.name}' not found"
    end

    def visit_ivar(node)
      node.type = context.lookup_ivar(node.name) or raise "instance variable '#{node.name}' not found"
    end

    def visit_cvar(node)
      node.type = context.lookup_cvar(node.name) or raise "class variable '#{node.name}' not found"
    end

    def visit_gvar(node)
      node.type = context.lookup_gvar(node.name) or raise "global variable '#{node.name}' not found"
    end

    def visit_self(node)
      node.type = context.scope.type
    end

    def visit_const(node)
      node.type = context.lookup_const(node.name) or raise "const '#{node.name}' not found"
    end

    def visit_colon2(node)
      node.owner.accept self
      node.type = node.owner.type.lookup_const(node.name) or raise "const '#{node.name}' not found"
      false
    end

    def visit_colon3(node)
      node.type = context.main.lookup_const(node.name) or raise "const '#{node.name}' not found"
      false
    end

    def visit_splat(node)
      node.value.accept self
      node.type = context.varlist
      false
    end

    def visit_block_pass(node)
      node.value.accept self
      node.type = context.block
      false
    end

    def visit_call(node)
      if node.obj
        node.obj.accept self
        scope = node.obj.type
      else
        scope = context.scope.type
      end

      node.args.each {|arg| arg.accept self}


    end

    def visit_lasgn(node)
      node.value.accept self
      node.type = node.target.type = node.value.type

      context.define_lvar node.target
      false
    end

    def visit_iasgn(node)
      node.value.accept self
      node.type = node.target.type = node.value.type

      context.define_ivar node.target
      false
    end

    def visit_cvasgn(node)
      node.value.accept self
      node.type = node.target.type = node.value.type

      context.define_cvar node.target
      false
    end

    def visit_gasgn(node)
      node.value.accept self
      node.type = node.target.type = node.value.type

      context.define_gvar node.target
      false
    end

    def visit_cdecl(node)
      node.value.accept self
      node.type = node.target.type = node.value.type
      if node.target.owner
        node.target.owner.accept self
        node.target.owner.type.define_const node.target
      elsif node.target.is_a?(Colon3)
        context.main.define_const node.target
      else
        context.define_const node.target
      end
      false
    end
  end
end
