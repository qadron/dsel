require 'spec_helper'

RSpec.describe DSeL::API::Node do
    it_should_behave_like DSeL::Node

    subject { Factory[:clean_api_spec] }
    let(:other) { Factory[:clean_api_spec] }
    let(:another) { Factory[:clean_api_spec] }
    let(:api) { subject.new }

    describe '.define' do
        it "delegates to #{DSeL::API::Generator}#define_definers" do
            types = [:stuff, :stuff2]
            expect(DSeL::API::Generator).to receive(:define_definers).with( subject, *types )

            subject.define *types
        end

        context 'when a description has been set' do
            context 'and more than 1 type is given' do
                it 'raises ArgumentError' do
                    subject.describe 'Stuff'

                    expect do
                        subject.define :stuff, :stuff2
                    end.to raise_error ArgumentError
                end
            end
        end

        context 'when options have been set' do
            context 'and more than 1 type is given' do
                it 'raises ArgumentError' do
                    subject.configure []

                    expect do
                        subject.define :stuff, :stuff2
                    end.to raise_error ArgumentError
                end
            end
        end
    end

    describe '.describe' do
        let(:description) { 'Blah' }

        it 'sets a description for the following definer' do
            subject.describe description
            subject.define :on

            expect(subject.definers).to eq [{ type: :on, description: description, method: :def_on}]
        end

        it 'sets a description for the following call handler' do
            subject.define :on

            subject.describe description
            subject.def_on( :stuff ) {}

            ch = subject.call_handlers.first
            ch.delete :method
            expect(ch).to eq( type: :on, description: description, object: :stuff)
        end

        it 'sets a description for the following child' do
            subject.describe description
            subject.push_child :blah, other

            expect(subject.children).to eq(
                blah: {
                    name: :blah,
                    node: other,
                    description: description
                }
            )
        end
    end

    describe '.configure' do
        let(:options) { { blah: :stuff } }

        it 'sets a description for the following definer' do
            subject.configure options
            subject.define :on

            expect(subject.definers).to eq [{ type: :on, options: [options], method: :def_on}]
        end

        it 'sets a description for the following call handler' do
            subject.define :on

            subject.configure options
            subject.def_on( :stuff ) {}

            ch = subject.call_handlers.first
            ch.delete :method
            expect(ch).to eq( type: :on, options: [options], object: :stuff)
        end

        it 'sets a description for the following child' do
            subject.configure options
            subject.push_child :blah, other

            expect(subject.children).to eq(
                blah: {
                    name: :blah,
                    node: other,
                    options: [options]
                }
            )
        end
    end

    describe '.has_options?' do
        context 'when options are available in the buffer' do
            it 'returns true' do
                subject.configure []
                expect(subject).to have_options
            end
        end

        context 'when options are not available in the buffer' do
            it 'returns false' do
                expect(subject).to_not have_options
            end
        end
    end

    describe '.has_description?' do
        context 'when a description is available in the buffer' do
            it 'returns true' do
                subject.describe ''
                expect(subject).to have_description
            end
        end

        context 'when no description is available in the buffer' do
            it 'returns false' do
                expect(subject).to_not have_description
            end
        end
    end

    describe '.root' do
        it 'returns the root node' do
            subject.push_child :blah, other
            other.push_child :another, another

            expect(another.root).to be subject
        end

        context 'when .root?' do
            it 'returns self' do
                expect(subject.root).to be subject
            end
        end
    end

    describe '.parent' do
        it 'returns the parent node' do
            subject.push_child :blah, other
            expect(other.parent).to be subject

            other.push_child :another, another
            expect(another.parent).to be other
        end

        context 'when .root?' do
            it 'returns nil' do
                expect(subject.parent).to be_nil
            end
        end
    end

    describe '.has_call_handler?' do
        context 'when there is a call handler' do
            it 'returns true' do
                subject.define :on

                subject.def_on {}
                expect( subject ).to have_call_handler :on

                subject.def_on( :stuff ) {}
                expect( subject ).to have_call_handler :on, :stuff
            end
        end

        context 'when there is no such call handler' do
            it 'returns false'  do
                expect( subject ).to_not have_call_handler :blah

                subject.define :on

                expect( subject ).to_not have_call_handler :on
                expect( subject ).to_not have_call_handler :on, :stuff
            end
        end
    end

    describe '.root?' do
        context 'when there is no parent' do
            it 'returns true' do
                expect(subject).to be_root
            end
        end

        context 'when there is a parent' do
            it 'returns false' do
                subject.push_child :blah, other
                expect(other).to_not be_root
            end
        end
    end

    describe '.child?' do
        context 'when there is no parent' do
            it 'returns false' do
                expect(subject).to_not be_child
            end
        end

        context 'when there is a parent' do
            it 'returns true' do
                subject.push_child :blah, other
                expect(other).to be_child
            end
        end
    end

    describe '.push_child' do
        before do
            subject.push_child :blah, other
        end

        it 'sets the given node as a child' do
            expect(subject.children).to eq(
                blah: {
                    name: :blah,
                    node: other
                }
            )
        end

        it 'creates an instance method for access' do
            expect(api.blah).to be_kind_of other
            expect(api.blah).to be api.blah
        end
    end

    describe '.push_children' do
        it 'delegates to .push_child' do
            expect(subject).to receive(:push_child).with(:blah, other)
            expect(subject).to receive(:push_child).with(:another, another)

            subject.push_children(
                blah:    other,
                another: another
            )
        end
    end

    describe '.tree' do
        it 'returns the API tree' do
            subject.push_child :blah, other
            other.push_child :another, another

            tree = {
                definers:      [],
                call_handlers: [],
                children:      {
                    :blah => {
                        :name          => :blah,
                        :node          => other,
                        :definers      => [],
                        :call_handlers => [],
                        :children      => {
                            another: {
                                :name          => :another,
                                :node          => another,
                                :definers      => [],
                                :call_handlers => [],
                                :children      => {}
                            }
                        }
                    }
                }
            }

            expect(another.tree). to eq tree
        end
    end

    describe '.branch' do
        it "returns the node's branch" do
            subject.push_child :blah, other
            other.push_child :another, another

            expect(subject.branch). to eq other.tree
        end
    end
end
