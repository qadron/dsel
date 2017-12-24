module DSeL
module DSL
module Nodes
class Direct

module Environment
    include Base::Environment

    def _dsl_shared_variables
        _dsl_runner.shared_variables
    end

    def _dsl_root?
        _dsl_runner.root?
    end

    def _dsl_real_self
        _dsl_runner.context
    end

    def _dsl_variables
        s = {}
        instance_variables.each do |ivar|
            s[ivar.to_s.sub( '@', '' ).to_sym] = instance_variable_get( ivar )
        end
        s.freeze
    end

end

end
end
end
end
