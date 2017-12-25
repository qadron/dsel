require_relative '../../mixins/environment/ivar_explorer'

module DSeL
module DSL
module Nodes
class Proxy

class Environment
    include Base::Environment
    include Mixins::Environment::IvarExplorer

    define_method "#{DSL_RUNNER_ACCESSOR}=" do |runner|
        super( runner )

        if runner
            _dsl_runner.context.public_methods( false ).each do |m|
                instance_eval( "undef :'#{m}'" ) rescue nil
            end
        end

        runner
    end

    def shared_variables
        _dsl_runner.shared_variables
    end

    def root?
        _dsl_runner.root?
    end

    def real_self
        _dsl_runner.context
    end

    def variables
        s = {}
        instance_variables.each do |ivar|
            s[ivar.to_s.sub( '@', '' ).to_sym] = instance_variable_get( ivar )
        end
        s.freeze
    end

    def method_missing( name, *args, &block )
        if _dsl_runner && real_self.respond_to?( name )
            return real_self.send( name, *args, &block )
        end

        super( name, *args, &block )
    end

    def respond_to?( *args )
        super( *args ) || (_dsl_runner && real_self.respond_to?( *args ))
    end

end

end
end
end
end
