module DSeL
module DSL
module Nodes
class Base

module Environment

    DSL_RUNNER_ACCESSOR = :_dsl_runner
    DSL_RUNNER_IVAR     = "@#{DSL_RUNNER_ACCESSOR}".to_sym

    # @private
    attr_accessor DSL_RUNNER_ACCESSOR

    def instance_variables
        super.tap { |ivars| ivars.delete DSL_RUNNER_IVAR }
    end

    def Parent( &block )
        fail 'Already root.' if _dsl_runner.root?

        _dsl_runner.parent.run( &block )
    end

    def Root( &block )
        fail 'Already root.' if _dsl_runner.root?
        _dsl_runner.root.run( &block )
    end

end

end
end
end
end
