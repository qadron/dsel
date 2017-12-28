require_relative 'base'
require_relative '../mixins/environment/ivar_explorer'

module DSeL
module DSL
module Nodes

class Direct < Base
    require_relative 'direct/environment'

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

    private

    def prepare_environment
        capture_subject
        decorate_subject

        @environment = @subject
    end

    def cleanup_environment
        restore_subject
    end

    def capture_subject
        @original_methods = reset_methods.map do |m|
            @subject.instance_eval do
                method( m ) if respond_to? m
            end
        end.compact
    end

    def decorate_subject
        # We could use @subject.extend but that only works the first time.
        extend_env.each do |mod|
            mod.instance_methods( true ).each do |m|
                @subject.instance_eval do
                    define_singleton_method m, mod.instance_method( m )
                end
            end
        end
    end

    def restore_subject
        cmethods = @subject.methods
        extend_env.each do |mod|
            mod.instance_methods( true ).each do |m|
                next if !cmethods.include?( m )
                @subject.instance_eval( "undef :'#{m}'" )
            end
        end

        @original_methods.each do |m|
            @subject.define_singleton_method m.name, &m
        end
    end

end

end
end
end
