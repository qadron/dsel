require 'spec_helper'

RSpec.describe DSeL::DSL::Nodes::Direct::Environment do
    include_examples DSeL::DSL::Nodes::Base::Environment

    subject do
        def node.cleanup_environment
        end

        node.run{}
        node.environment
    end

end
