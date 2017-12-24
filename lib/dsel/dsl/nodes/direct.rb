require_relative 'base'
require_relative '../mixins/environment/ivar_explorer'

module DSeL
module DSL
module Nodes

class Direct < Base
    require_relative 'direct/environment'

    class Env
    end

    def run( script = nil, &block )
        super
    ensure
        return if calling?
        restore_context
    end

    private

    def extend_env
        [
            Environment,
            Mixins::Environment::IvarExplorer
        ]
    end

    def reset_methods
        [
            :instance_variables,
            :method_missing
        ]
    end

    def prepare_environment
        capture_context
        decorate_context

        @environment = @context
    end

    def capture_context
        @original_methods = reset_methods.map do |m|
            @context.instance_eval do
                method( m ) if respond_to? m
            end
        end.compact
    end

    def decorate_context
        # We could use @context.extend but that only works the first time.
        env = Env.new
        extend_env.each do |mod|
            env.extend mod

            mod.instance_methods( true ).each do |m|
                @context.instance_eval do
                    define_singleton_method m, &env.method( m )
                end
            end
        end
    end

    def restore_context
        cmethods = @context.methods
        extend_env.each do |mod|
            mod.instance_methods( true ).each do |m|
                next if !cmethods.include?( m )
                @context.instance_eval( "undef :'#{m}'" )
            end
        end

        @original_methods.each do |m|
            @context.define_singleton_method m.name, &m
        end
    end

end

end
end
end
