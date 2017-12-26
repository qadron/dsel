module DSeL
module DSL
module Nodes

class Base
    require_relative 'base/environment'

    # @return   [Object]
    attr_reader :context

    # @return   [Environment]
    attr_reader :environment

    # @return   [Base, nil]
    attr_reader :parent

    # @return   [Base]
    #   `self` if {#root?}.
    attr_reader :root

    # @param   [Object] context
    # @param   [Hash] options
    # @option   options [Base, nil] :parent (nil)
    def initialize( context, options = {} )
        @context = context
        @parent  = options[:parent]
        @root    = (@parent ? @parent._dsel_node.root : self)

        @shared_variables = {}
        @nodes            = {}

        # Let everyone know we're here to avoid creating an identical node for
        # this context.
        cache_node self
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

    # @private
    def nodes
        root? ? @nodes : @root.nodes
    end

    def shared_variables
        root? ? @shared_variables : @root.shared_variables
    end

    def root?
        @root == self
    end

    # @private
    def cache_node(node )
        nodes[node.hash] ||= node
    end

    # @private
    def node_for( context, options = {} )
        nodes[calc_node_hash( context )] ||=
            self.class.new( context, options.merge( parent: self ) )
    end

    def hash
        "#{self.class}:#{@context.object_id}".hash
    end

    # @private
    def _dsel_node
        self
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

    def calc_node_hash( context )
        "#{self.class}:#{context.object_id}".hash
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
