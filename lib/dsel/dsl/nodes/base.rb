module DSeL
module DSL
module Nodes

class Base < Node
    require_relative 'base/environment'

    # @return   [Environment]
    attr_reader :environment

    def initialize(*)
        super

        @shared_variables = {}
        @nodes            = {}

        cache_node( self )
    end

    # @private
    def nodes
        root? ? @nodes : @root.nodes
    end

    def shared_variables
        root? ? @shared_variables : @root.shared_variables
    end

    # @private
    def cache_node( node )
        nodes[node.hash] ||= node
    end

    # @private
    def node_for( subject, options = {} )
        nodes[calc_node_hash( subject )] ||=
            self.class.new( subject, options.merge( parent: self ) )
    end

    def run( script = nil, &block )
        if script && block
            fail ArgumentError, 'Cannot use both script and &block.'
        end

        begin
            prepare

            calling do
                if block
                    return @environment.instance_eval( &block )
                end

                if script
                    @environment.instance_eval do
                        return eval( IO.read( script ) )
                    end
                end
            end
        ensure
            # Re-entry, don't touch anything.
            return if calling?

            # May not have been prepared yet.
            return if !@environment.respond_to?( Environment::DSEL_NODE_ACCESSOR )

            cleanup
        end
    end

    private

    def prepare
        prepare_environment
        @environment._dsel_node = self
    end

    def cleanup
        @environment._dsel_node = nil
        cleanup_environment
    end

    # @abstract
    def cleanup_environment
    end

    # @abstract
    def prepare_environment
        fail 'Not implemented.'
    end

    def calling( &block )
        return block.call if @calling

        @calling = true
        begin
            block.call
        ensure
            @calling = false
        end
    end

    def calling?
        @calling
    end

end

end
end
end
