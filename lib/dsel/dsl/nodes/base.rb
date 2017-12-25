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
        @root    = (@parent ? @parent._dsel_runner.root : self)

        @shared_variables = {}
        @runners          = {}

        # Let everyone know we're here to avoid creating an identical node for
        # this context.
        push_runner self
    end

    def run( script = nil, &block )
        if script && block
            fail ArgumentError, 'Cannot use both script and &block.'
        end

        begin
            prepare_environment
            @environment.send "#{Environment::DSEL_RUNNER_ACCESSOR}=", self

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
            return if !@environment.respond_to?( Environment::DSEL_RUNNER_ACCESSOR )

            @environment.send "#{Environment::DSEL_RUNNER_ACCESSOR}=", nil
        end
    end

    # @private
    def runners
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
        runners[runner.hash] ||= runner
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
    def _dsel_runner
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
