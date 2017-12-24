module DSeL
module DSL
module Mixins
module Environment

module IvarExplorer

    def method_missing( name, *args, &block )
        first_letter = name[0...1]

        if block && first_letter == first_letter.capitalize
            ivar = "@#{name}".to_sym
            return _dsl_runner_for_ivar( ivar, &block )
        end

        super( name, *args, &block )
    end

    # @private
    def _dsl_runner_for_ivar( ivar, &block )
        ivar = ivar.downcase
        if !_dsl_runner.context.instance_variable_defined?( ivar )
            fail ArgumentError, "Instance variable not defined: #{ivar}"
        end

        _dsl_runner.runner_for( _dsl_runner.context.instance_variable_get( ivar ) ).run( &block )
    end

end

end
end
end
end
