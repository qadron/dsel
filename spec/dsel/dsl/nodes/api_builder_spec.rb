require 'spec_helper'

RSpec.describe DSeL::DSL::Nodes::APIBuilder do
    include_examples DSeL::DSL::Nodes::Base

    let(:name) { "MyAPI#{rand(999)}".to_sym }
    let(:klass) { Object.const_get( name ) }

    let(:child_name) { "MyAPIChild#{rand(999)}".to_sym }

    let(:clean_api_spec) { Factory[:clean_api_spec] }
    let(:context) { Factory[:clean_api_spec] }
    let(:other_context) { Factory[:clean_api_spec] }

    it 'uses the context as the environment' do
        subject.run{}
        expect(subject.environment).to be subject.context
    end

    describe '.build' do
        it 'runs the given block' do
            described_class.build( name ){}
            expect(klass).to be < DSeL::API::Node
        end

        it 'returns the API node' do
            api = described_class.build( name ){}
            expect(klass).to be api
        end

        context 'when no block has been given' do
            it 'raises ArgumentError' do
                expect do
                    described_class.build( name )
                end.to raise_error ArgumentError
            end
        end
    end

    describe '#initialize' do
        describe 'node' do
            context 'when given a' do
                context 'Symbol' do
                    let(:context){ name }

                    it 'creates an API node by the same name' do
                        subject
                        expect(klass).to be < DSeL::API::Node
                    end

                    it 'uses it as a context' do
                        subject
                        expect(subject.context).to be klass
                    end

                    context 'when the name has already been taken' do
                        it 'raises ArgumentError' do
                            subject

                            expect do
                                described_class.new( name )
                            end.to raise_error ArgumentError
                        end
                    end
                end

                context 'DSeL::API::Node' do
                    let(:context){ clean_api_spec }

                    it 'uses it as a context' do
                        expect(subject.context).to be clean_api_spec
                    end
                end

                context 'other' do
                    let(:context){ '' }

                    it 'raises ArgumentError' do
                        expect do
                            subject
                        end.to raise_error ArgumentError
                    end
                end
            end
        end

        describe 'options' do
            describe 'when creating a new API node' do
                let(:context) do
                    name
                end

                describe ':namespace' do
                    let(:namespace) { module MyNamespace;end; MyNamespace }
                    let(:options) do
                        { namespace: namespace }
                    end

                    it 'is placed under that namespace' do
                        subject.context
                        expect(namespace.constants).to include name
                    end
                end

                describe ':superclass' do
                    let(:superclass) { other_context }
                    let(:options) do
                        { superclass: superclass }
                    end

                    it 'sets the API node superclass' do
                        expect(subject.context).to be < superclass
                    end

                    context "when not an #{DSeL::API::Node} subclass" do
                        let(:superclass) { Object }

                        it 'raises ArgumentError' do
                            expect do
                                subject
                            end.to raise_error ArgumentError
                        end
                    end
                end
            end
        end
    end

    describe '#node_for' do
        let(:child_node) { subject.node_for( child_name ) }

        it 'uses the current context as the namespace' do
            expect(child_node.context).to be subject.context.const_get( child_name )
        end

        context 'when a superclass has been set' do
            let(:superclass) { other_context }
            let(:options) do
                { superclass: superclass }
            end

            it 'uses it as the superclass' do
                expect(child_node.context).to be < superclass
            end
        end
    end

end
