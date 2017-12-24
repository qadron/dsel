require_relative 'base'

module DSeL
module DSL
module Nodes

class Proxy < Base
    require_relative 'proxy/environment'

    private

    def prepare_environment
        @environment ||= Environment.new
    end

end

end
end
end
