require 'spec_helper'

RSpec.describe DSeL::DSL::Nodes::Proxy do
    include_examples DSeL::DSL::Nodes::Base

    it "uses #{described_class::Environment}" do
        subject.run{}
        expect(subject.environment).to be_kind_of described_class::Environment
    end

end
