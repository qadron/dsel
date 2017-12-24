require_relative 'direct'

module DSeL
module DSL
module Nodes

class APIBuilder < Nodes::Direct
    require_relative 'api_builder/environment'

    class APINode < DSeL::API::Node
    end

    def self.build( *args, &block )
        new( *args ).run( &block )
    end

    def initialize( node, options = {} )
        if node.is_a?( Symbol )
            context = (options[:namespace] || Object).const_set(
                node,
                Class.new( APINode )
            )
        else
            context = node
        end

        super( context, options )
    end

    def run
        r = super
        return @context if root?
        r
    end

    private

    def reset_methods
        [
            :instance_variables,
            :method_missing
        ]
    end

    def extend_env
        [
            Environment
        ]
    end
end

end
end
end
