require_relative '../../mixins/environment/ivar_explorer'

module DSeL
module DSL
module Nodes
class Proxy

class Environment
    include Base::Environment
    include Mixins::Environment::IvarExplorer

    define_method "#{DSEL_RUNNER_ACCESSOR}=" do |runner|
        super( runner )

        if runner
            _dsel_runner.context.public_methods( false ).each do |m|
                instance_eval( "undef :'#{m}'" ) rescue nil
            end
        end

        runner
    end

    def method_missing( name, *args, &block )
        if _dsel_runner && _dsel_self.respond_to?( name )
            return _dsel_self.send( name, *args, &block )
        end

        super( name, *args, &block )
    end

    def respond_to?( *args )
        super( *args ) || (_dsel_runner && _dsel_self.respond_to?( *args ))
    end

end

end
end
end
end
