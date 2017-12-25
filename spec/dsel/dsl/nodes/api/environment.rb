require 'spec_helper'

RSpec.describe DSeL::DSL::Nodes::API::Environment do
    include_examples DSeL::DSL::Nodes::Base::Environment

    let(:api_spec) { Factory[:clean_api_spec] }
    let(:other_api_spec) { Factory[:clean_api_spec] }
    let(:node_context) { api_spec.new }

    let(:other_node_context) { api_spec.new }
    let(:another_node_context) { api_spec.new }

    context 'when the API node has children' do
        before do
            api_spec.push_child :other_api_spec, other_api_spec
        end

        it 'creates DSL helpers for them' do
            child = node.run { Other_api_spec { real_self } }
            expect(child).to be node_context.other_api_spec
        end
    end

    describe '#also' do
        let(:calls) { [] }

        context 'when repeating a catch-all' do
            before do
                api_spec.define :on

                c = calls
                api_spec.def_on do |*args|
                    c << [:on, args]
                end
            end

            context 'that had no arguments' do
                it 'does not send any arguments' do
                    node.run do
                        on
                        also
                    end

                    expect(calls).to eq [[:on, []], [:on, []]]
                end

                context 'with new arguments' do
                    it 'sends the new arguments' do
                        node.run do
                            on
                            also :stuff
                        end

                        expect(calls).to eq [[:on, []], [:on, [:stuff]]]
                    end
                end
            end

            context 'that had arguments' do
                it 'does not send any arguments' do
                    node.run do
                        on :stuff
                        also
                    end

                    expect(calls).to eq [[:on, [:stuff]], [:on, []]]
                end

                context 'with new arguments' do
                    it 'sends the new arguments' do
                        node.run do
                            on :stuff
                            also :stuff2
                        end

                        expect(calls).to eq [[:on, [:stuff]], [:on, [:stuff2]]]
                    end
                end
            end
        end

        context 'when repeating an object call' do
            before do
                api_spec.define :on

                c = calls

                api_spec.def_on :stuff do |*args|
                    c << [:stuff, args]
                end

                api_spec.def_on :other_stuff do |*args|
                    c << [:other_stuff, args]
                end
            end

            context 'with a specified object' do
                it 'changes the call handler' do
                    node.run do
                        on :stuff
                        also :other_stuff
                    end

                    expect(calls).to eq [[:stuff, []], [:other_stuff, []]]
                end

                context 'that had no arguments' do
                    it 'does not send any arguments' do
                        node.run do
                            on :stuff
                            also :other_stuff
                        end

                        expect(calls).to eq [[:stuff, []], [:other_stuff, []]]
                    end

                    context 'with new arguments' do
                        it 'sends the new arguments' do
                            node.run do
                                on :stuff
                                also :other_stuff, :arg
                            end

                            expect(calls).to eq [[:stuff, []], [:other_stuff, [:arg]]]
                        end
                    end
                end

                context 'that had arguments' do
                    it 'does not send any arguments' do
                        node.run do
                            on :stuff, :arg
                            also :other_stuff
                        end

                        expect(calls).to eq [[:stuff, [:arg]], [:other_stuff, []]]
                    end

                    context 'with new arguments' do
                        it 'sends the new arguments' do
                            node.run do
                                on :stuff
                                also :other_stuff, :arg
                            end

                            expect(calls).to eq [[:stuff, []], [:other_stuff, [:arg]]]
                        end
                    end
                end
            end

            context 'without an object' do
                it 'uses the previous call handler' do
                    node.run do
                        on :stuff
                        also :stuff2
                    end

                    expect(calls).to eq [[:stuff, []], [:stuff, [:stuff2]]]
                end

                context 'that had no arguments' do
                    it 'does not send any arguments' do
                        node.run do
                            on :stuff
                            also
                        end

                        expect(calls).to eq [[:stuff, []], [:stuff, []]]
                    end

                    context 'with new arguments' do
                        it 'sends the new arguments' do
                            node.run do
                                on :stuff
                                also :arg
                            end

                            expect(calls).to eq [[:stuff, []], [:stuff, [:arg]]]
                        end
                    end
                end

                context 'that had arguments' do
                    it 'does not send any arguments' do
                        node.run do
                            on :stuff, :arg
                            also
                        end

                        expect(calls).to eq [[:stuff, [:arg]], [:stuff, []]]
                    end

                    context 'with new arguments' do
                        it 'sends the new arguments' do
                            node.run do
                                on :stuff
                                also :arg
                            end

                            expect(calls).to eq [[:stuff, []], [:stuff, [:arg]]]
                        end
                    end
                end
            end
        end
    end
end
