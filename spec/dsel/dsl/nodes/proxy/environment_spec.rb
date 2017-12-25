require 'spec_helper'

RSpec.describe DSeL::DSL::Nodes::Proxy::Environment do
    include_examples DSeL::DSL::Nodes::Base::Environment
    # include_examples DSeL::DSL::Mixins::Environment::IvarExplorer

    subject { described_class.new }
    let(:node_context) do
        Class.new do
            def test
                __method__
            end

            def hash
                1
            end
        end.new
    end

    it 'forwards methods to the context' do
        expect(subject.test).to be :test
    end

    describe "##{described_class::DSEL_RUNNER_ACCESSOR}=" do
        context 'when a node is given' do
            it 'undefines methods with the same name as the context' do
                expect(subject.hash).to eq node.context.hash
            end
        end

        context 'when nil is given' do
            it 'does nothing' do
                subject._dsel_runner = nil
                expect(subject._dsel_runner).to be_nil
            end
        end
    end

    describe '#respond_to?' do
        it 'returns false' do
            expect(subject).to_not respond_to :stuff
        end

        context 'when self responds' do
            it 'returns true' do
                expect(subject).to respond_to :_dsel_variables
            end
        end

        context 'when the context responds' do
            it 'returns true' do
                expect(subject).to respond_to :test
            end
        end
    end
end
