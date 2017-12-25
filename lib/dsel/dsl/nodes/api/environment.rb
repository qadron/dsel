require_relative '../proxy/environment'

module DSeL
module DSL
module Nodes
class API

class Environment < Proxy::Environment

    define_method "#{DSEL_RUNNER_ACCESSOR}=" do |runner|
        super( runner )

        if runner
            runner.context.class.children.keys.each do |name|
                define_singleton_method name.capitalize do |&b|
                    runner.runner_for( send( name ) ).run( &b )
                end
            end
        end

        runner
    end

    def also( *args, &block )
        # TODO: Store #last_call on Node at the instance level,
        # this global state can be interfered with by other DSLs.
        last_call = DSeL::API::Generator.last_call
        type      = last_call[:type]

        # Check to see if there is a handler that matches our possible object.
        # If so, treat it as object.
        # If not, use the last object and assume arguments.
        if last_call.include?( :object ) &&
            !_dsel_self.class.has_call_handler?( type, args.first )

            args.unshift last_call[:object]
        end

        send( type, *args, &block )

        self
    end

end

end
end
end
end
