require_relative 'direct'

module DSeL
module DSL
module Nodes

class APIBuilder < Nodes::Direct
    require_relative 'api_builder/environment'

    def self.build( *args, &block )
        fail ArgumentError, 'Missing block.' if !block

        node = new( *args )
        node.run( &block )
        node.context
    end

    API_NODE = DSeL::API::Node

    def initialize( node, options = {} )
        @superclass = options[:superclass] || API_NODE
        if !(@superclass <= API_NODE)
            fail ArgumentError, "Superclass not subclass of #{API_NODE}."
        end

        if node.is_a?( Symbol )
            namespace = options[:namespace]  || Object

            begin
                c = namespace.const_get( node )
                fail ArgumentError, "Node name taken: #{c.inspect}"
            rescue NameError
            end

            context = namespace.const_set( node, Class.new( @superclass ) )

        elsif node.is_a?( Class ) && node < DSeL::API::Node
            context = node

        else
            fail ArgumentError,
                 "Expected #{Symbol} or #{DSeL::API::Node}, got: #{node.inspect}"
        end

        super( context, options )
    end

    # @private
    def node_for( context, options = {} )
        super( context, options.merge(
            namespace:  @context,
            superclass: @superclass
        ))
    end

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
