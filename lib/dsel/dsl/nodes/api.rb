module DSeL
module DSL
module Nodes

class API < Proxy
    require_relative 'api/environment'

    private

    def prepare_environment
        @environment ||= Environment.new
    end

end

end
end
end
