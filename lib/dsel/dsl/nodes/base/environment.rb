module DSeL
module DSL
module Nodes
class Base

module Environment

    DSEL_NODE_ACCESSOR = :_dsel_node
    DSEL_NODE_IVAR     = "@#{DSEL_NODE_ACCESSOR}".to_sym

    # @private
    attr_accessor DSEL_NODE_ACCESSOR

    def instance_variables
        super.tap { |ivars| ivars.delete DSEL_NODE_IVAR }
    end

    def _dsel_shared_variables
        _dsel_node.shared_variables
    end

    def _dsel_root?
        _dsel_node.root?
    end

    def _dsel_self
        _dsel_node.context
    end

    def _dsel_variables
        s = {}
        instance_variables.each do |ivar|
            s[ivar.to_s.sub( '@', '' ).to_sym] = instance_variable_get( ivar )
        end
        s.freeze
    end

    def Parent( &block )
        fail 'Already root.' if _dsel_root?

        _dsel_node.parent.run( &block )
    end

    def Root( &block )
        fail 'Already root.' if _dsel_root?
        _dsel_node.root.run( &block )
    end

end

end
end
end
end
