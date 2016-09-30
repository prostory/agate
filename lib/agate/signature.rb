module SLang
  class Signature
    attr_accessor :types

    def initialize(types = [])
      @types = types.clone
      if types.last.is_a?(VarList)
        @types.pop
        @types.push *types.last.members
        @is_var_list = true
      else
        @is_var_list = false
      end
    end

    def var_list?
      @is_var_list
    end

    def self.child_of_types?(child_types, types)
      return false if types.size != child_types.size

      result = types.each_with_index do |type, idx|
        break unless child_types[idx].child_of?(type)
      end

      return result.nil? ? false : true
    end

    def child_of_types?(types, is_var_list)
      if is_var_list
        if var_list?
          return false if @types.size < types.size
          new_types = types.clone
          (@types.size- types.size).times {new_types.push Type.any}
          return self.class.child_of_types?(@types, new_types)
        else
          return true
        end
      else
        if var_list?
          return false
        else
          return self.class.child_of_types?(@types, types)
        end
      end
    end

    def child_of?(other)
      child_of_types?(other.types, other.var_list?)
    end

    def parent_of?(other)
      other.child_of_types?(types, var_list?)
    end

    def hash
      types.hash
    end

    def eql?(other)
      other.types == types
    end

    def ==(other)
      other.types == types
    end

    def <=>(other)
      if eql?(other)
        0
      elsif child_of?(other)
        -1
      else
        1
      end
    end

    def to_s
      s = types.join ', '
      s << ', VarList' if var_list?
      s
    end
  end
end