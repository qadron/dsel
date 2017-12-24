require_relative '../proxy/environment'

module DSeL
module DSL
module Nodes
class API

class Environment < Proxy::Environment

    def also( *args, &block )
        last_call = DSeL::API::Generator.last_call
        type      = last_call[:type]

        if last_call.include? :object
            # Search in real_self.class.call_handlers to see if there is a handler
            # that matches our possible object, if so treat it as object.
            # If not, use the last object and assume arguments.
            arguments_match_object = api.class.call_handlers.
                find do |handler|
                    handler[:type]  == type &&
                        handler[:object] == args.first
                end

            if !arguments_match_object
                args.unshift last_call[:object]
            end
        end

        send( type, *args, &block )

        self
    end

    def api
        real_self
    end

    def api_root
        _dsl_runner.root.context
    end

    def api_parent
        _dsl_runner.parent.context
    end

end
end
end
end
end
