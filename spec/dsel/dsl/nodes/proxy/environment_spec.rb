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

    describe "##{described_class::DSL_RUNNER_ACCESSOR}=" do
        context 'when a node is given' do
            it 'undefines methods with the same name as the context' do
                expect(subject.hash).to eq node.context.hash
            end
        end

        context 'when nil is given' do
            it 'does nothing' do
                subject._dsl_runner = nil
                expect(subject._dsl_runner).to be_nil
            end
        end
    end

    describe '#shared_variables' do
        it 'delegates to node' do
            expect(subject.shared_variables).to be node.shared_variables
        end
    end

    describe '#root?' do
        it 'delegates to node' do
            expect(node).to receive(:root?).and_return(1)
            expect(subject.root?).to be 1
        end
    end

    describe '#real_self' do
        it 'returns the context' do
            expect(subject.real_self).to be node.context
        end
    end

    describe '#variables' do
        it 'returns instance variables' do
            subject.instance_variable_set( :@tmp, 1 )
            expect(subject.variables).to eq( tmp: 1 )
        end
    end

    describe '#respond_to?' do
        it 'returns false' do
            expect(subject).to_not respond_to :stuff
        end

        context 'when self responds' do
            it 'returns true' do
                expect(subject).to respond_to :variables
            end
        end

        context 'when the context responds' do
            it 'returns true' do
                expect(subject).to respond_to :test
            end
        end
    end
end
