module DSeL
module DSL
module Nodes

class API < Base
    require_relative 'api/environment'

    private

    def prepare_environment
        return if @environment

        @environment = Environment.new

        @context.class.children.each do |name, child|
            scope_name = child[:node].to_s.split( '::' ).last
            environment.define_singleton_method scope_name do |&b|
                _dsl_runner.runner_for( send( name ) ).run( &b )
            end
        end
    end

end

end
end
end
