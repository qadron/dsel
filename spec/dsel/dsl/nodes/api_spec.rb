require 'spec_helper'

RSpec.describe DSeL::DSL::Nodes::API do
    include_examples DSeL::DSL::Nodes::Base

    let(:api_spec) { Factory[:clean_api_spec] }
    let(:other_api_spec) { Factory[:clean_api_spec] }
    let(:context) { api_spec.new }

    it "uses #{described_class::Environment}" do
        subject.run{}
        expect(subject.environment).to be_kind_of described_class::Environment
    end

end
