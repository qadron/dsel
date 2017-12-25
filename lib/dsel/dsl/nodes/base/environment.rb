module DSeL
module DSL
module Nodes
class Base

module Environment

    DSEL_RUNNER_ACCESSOR = :_dsel_runner
    DSEL_RUNNER_IVAR     = "@#{DSEL_RUNNER_ACCESSOR}".to_sym

    # @private
    attr_accessor DSEL_RUNNER_ACCESSOR

    def instance_variables
        super.tap { |ivars| ivars.delete DSEL_RUNNER_IVAR }
    end

    def _dsel_shared_variables
        _dsel_runner.shared_variables
    end

    def _dsel_root?
        _dsel_runner.root?
    end

    def _dsel_self
        _dsel_runner.context
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

        _dsel_runner.parent.run( &block )
    end

    def Root( &block )
        fail 'Already root.' if _dsel_root?
        _dsel_runner.root.run( &block )
    end

end

end
end
end
end
