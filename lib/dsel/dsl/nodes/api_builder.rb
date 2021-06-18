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
        node.subject
    end

    API_NODE = DSeL::API::Node

    def initialize( node, options = {} )
        @superclass = options[:superclass] || API_NODE
        if !(@superclass <= API_NODE)
            fail ArgumentError, "Superclass not subclass of #{API_NODE}."
        end

        if node.is_a?( Symbol )
            namespace = options[:namespace]  || Object

            if namespace.constants.include?( node )
                fail ArgumentError, "Node name taken: #{c.inspect}"
            end

            subject = namespace.const_set( node, Class.new( @superclass ) )

        elsif node.is_a?( Class ) && node < DSeL::API::Node
            subject = node

        else
            fail ArgumentError,
                 "Expected #{Symbol} or #{DSeL::API::Node}, got: #{node.inspect}"
        end

        super( subject, options )
    end

    # @private
    def node_for( subject, options = {} )
        super( subject, options.merge(
            namespace:  @subject,
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
