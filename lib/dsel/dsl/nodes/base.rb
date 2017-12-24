module DSeL
module DSL
module Nodes

class Base
    require_relative 'base/environment'

    attr_reader :context
    attr_reader :environment
    attr_reader :parent
    attr_reader :root

    def initialize( context, options = {} )
        @context = context

        @parent = options[:parent]

        @root_runner   = nil
        @parent_runner = nil
        if !@parent
            @parent = self
            @root   = self

            @parent_runner = self
            @root_runner   = self
        else
            @root = @parent._dsl_runner.root
            @root.runners[@context.object_id] = self
        end

        @shared_variables = {}
        @runners          = {}
    end

    def run( script = nil, &block )
        if script && block
            fail ArgumentError, 'Cannot use both script and &block.'
        end

        prepare_environment
        @environment._dsl_runner = self

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
        return if calling?
        @environment._dsl_runner = nil
    end

    # @private
    def runners
        # TODO: Is this necessary?
        root? ? @runners : @root.runners
    end

    def shared_variables
        root? ? @shared_variables : @root.shared_variables
    end

    def root?
        @root == self
    end

    # @private
    def push_runner( runner )
        runners[runner] ||= runner
    end

    # @private
    def runner_for( context, options = {} )
        runners[calc_runner_hash( context )] ||=
            self.class.new( context, options.merge( parent: self ) )
    end

    def hash
        "#{self.class}:#{@context.object_id}".hash
    end

    # @private
    def _dsl_runner
        self
    end

    private

    # @abstract
    def prepare_environment
        fail 'Not implemented.'
    end

    def calc_runner_hash( context )
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
