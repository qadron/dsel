require 'spec_helper'

RSpec.describe DSeL::API::Generator do
    let(:api_spec) { MockAPI }
    let(:api) { api_spec.new }
    let(:clean_api_spec) do
        Object.const_set(
            "MockNode#{rand(9999)}".to_sym,
            Class.new( DSeL::API::Node )
        )
    end
    let(:clean_api) { clean_api_spec.new }
    subject { described_class }

    describe '#last_call' do
        let(:last_call) { subject.last_call }

        before do
            api.on
            api.on 2
        end

        it 'returns the last call' do
            expect(last_call[:node]).to be api_spec
            expect(last_call[:type]).to be :on
            expect(last_call[:args]).to eq [2]
        end

        context '#last_call_with_caller?' do
            context 'true' do
                before do
                    subject.last_call_with_caller!
                    api.on 3
                end

                it 'includes caller information' do
                    expect(last_call[:caller]).to be_kind_of Array
                end
            end

            context 'false' do
                before do
                    subject.last_call_without_caller!
                    api.on 3
                end

                it 'does not include caller information' do
                    expect(last_call).to_not include :caller
                end
            end

            context 'default' do
                before do
                    api.on 3
                end

                it 'does not include caller information' do
                    expect(last_call).to_not include :caller
                end
            end
        end
    end

    describe '#last_call_with_caller?' do
        it 'returns false' do
            expect(subject).to_not be_last_call_with_caller
        end

        context 'when #last_call_with_caller! has been called' do
            before do
                subject.last_call_with_caller!
            end

            it 'returns true' do
                expect(subject).to be_last_call_with_caller
            end
        end
    end

    describe '#last_call_without_caller!' do
        it 'disables tracking of last call callers' do
            subject.last_call_with_caller!
            expect(subject).to be_last_call_with_caller

            subject.last_call_without_caller!
            expect(subject).to_not be_last_call_with_caller
        end
    end

    describe '#last_call_witt_caller!' do
        it 'enables tracking of last call callers' do
            subject.last_call_with_caller!
            expect(subject).to be_last_call_with_caller
        end
    end

    describe '#on_call' do
        it 'sets callbacks for each call' do
            calls = Hash.new

            subject.on_call do |call|
                (calls[:first] ||= []) << call
            end

            subject.on_call do |call|
                (calls[:second] ||= []) << call
            end

            api.on 4

            expect(calls[:first]).to eq calls[:second]
            {
                node: api_spec,
                type: :on,
                args: [4]
            }.each do |k, v|
                calls[:first].each do |call|
                    expect(call[k]).to eq v
                end
            end
        end

        it 'returns self' do
            expect(subject.on_call{}).to be subject.instance
        end

        context 'when no block is given' do
            it 'raises ArgumentError' do
                expect do
                    subject.on_call
                end.to raise_error ArgumentError
            end
        end
    end

    describe '#call_object_hasher=' do
        before do
            subject.define_definers( clean_api_spec, :on )
        end

        context 'nil' do
            before do
                subject.call_object_hasher = nil
            end

            it 'uses #hash' do
                o = Object.new
                expect(o).to receive(:hash).and_return(1)

                called = false
                subject.define_call_handler clean_api_spec, :on, o do |*a, &block|
                    called = true
                end

                o2 = Object.new
                expect(o2).to receive(:hash).and_return(1)

                clean_api.on o2
                expect(called).to be_truthy
            end

            it 'treats strings as case-insensitive' do
                o = 'StFuFf'

                called = false
                subject.define_call_handler clean_api_spec, :on, o do |*a, &block|
                    called = true
                end

                clean_api.on o.downcase
                expect(called).to be_truthy
            end
        end

        context 'Symbol' do
            before do
                subject.call_object_hasher = :object_id
            end

            it 'uses it as a method on the object' do
                o = Object.new

                called = false
                subject.define_call_handler clean_api_spec, :on, o do |*a, &block|
                    called = true
                end

                expect do
                    clean_api.on Object.new
                end.to raise_error NoMethodError

                clean_api.on o
                expect(called).to be_truthy
            end
        end

        context '#call' do
            before do
                subject.call_object_hasher = proc do |o|
                    o.hash
                end
            end

            it 'passes the object to it' do
                o = Object.new
                expect(o).to receive(:hash).and_return(1)

                called = false
                subject.define_call_handler clean_api_spec, :on, o do |*a, &block|
                    called = true
                end

                o2 = Object.new
                expect(o2).to receive(:hash).and_return(1)

                clean_api.on o2
                expect(called).to be_truthy
            end
        end

        context 'other' do
            it 'raises ArgumentError' do
                expect do
                    subject.call_object_hasher = 'stuff'
                end.to raise_error ArgumentError
            end
        end

        context 'when the return value is not an Integer' do
            before do
                subject.call_object_hasher = :to_s
            end

            it 'raises ArgumentError' do
                o = Object.new

                expect do
                    subject.define_call_handler( clean_api_spec, :on, o ){}
                end.to raise_error ArgumentError
            end
        end
    end

    describe '#define_definers' do
        it 'defines the given definers on the given node' do
            subject.define_definers( clean_api_spec, :on, :after )

            expect(clean_api_spec.definers).to eq [
                { type: :on,    method: :def_on },
                { type: :after, method: :def_after }
            ]

            expect(clean_api_spec).to respond_to :def_on
            expect(clean_api_spec).to respond_to :def_after
        end

        context 'when a definer already exists' do
            it 'raises NameError' do
                subject.define_definers( clean_api_spec, :on )

                expect do
                    subject.define_definers( clean_api_spec, :on )
                end.to raise_error NameError
            end
        end

        context 'when a definer is given more than 2 objects' do
            it 'raises ArgumentError' do
                subject.define_definers( clean_api_spec, :on )

                expect do
                    clean_api_spec.def_on :stuff, :stuff2 do

                    end
                end.to raise_error ArgumentError
            end
        end
    end

    describe '#define_call_handler' do
        before do
            subject.define_definers( clean_api_spec, :on, :after )
        end

        it 'defines a handler for the given type and object' do
            on_args = []
            subject.define_call_handler clean_api_spec, :on, :stuff do |*a, &block|
                on_args << [a, block]
            end

            after_args = []
            subject.define_call_handler clean_api_spec, :after, :stuff do |*a, &block|
                after_args << [a, block]
            end

            b1 = proc{}
            clean_api.on :stuff, 1, &b1

            b2 = proc{}
            clean_api.after :stuff, 2, &b2

            expect(on_args).to eq [[[1], b1]]
            expect(after_args).to eq [[[2], b2]]
        end

        it 'enforces argument arity' do
            subject.define_call_handler clean_api_spec, :on, :none do
            end

            expect do
                clean_api.on :none
            end.to_not raise_error

            expect do
                clean_api.on :none, 1
            end.to raise_error ArgumentError


            subject.define_call_handler clean_api_spec, :on, :one do |x|
            end

            expect do
                clean_api.on :one, 1
            end.to_not raise_error

            expect do
                clean_api.on :one
            end.to raise_error ArgumentError

            expect do
                clean_api.on :one, 1, 2
            end.to raise_error ArgumentError


            subject.define_call_handler clean_api_spec, :on, :two do |x, y|
            end

            expect do
                clean_api.on :two, 1, 2
            end.to_not raise_error

            expect do
                clean_api.on :two
            end.to raise_error ArgumentError

            expect do
                clean_api.on :two, 1
            end.to raise_error ArgumentError

            expect do
                clean_api.on :two, 1, 2, 3
            end.to raise_error ArgumentError


            subject.define_call_handler clean_api_spec, :on, :var do |*args|
            end

            expect do
                clean_api.on :var
            end.to_not raise_error

            expect do
                clean_api.on :var, 1
            end.to_not raise_error
        end

        context 'when object is' do
            context 'nil' do
                it 'is treated as an object' do
                    args = []
                    subject.define_call_handler clean_api_spec, :on, nil do |*a|
                        args << a
                    end

                    expect do
                        clean_api.on
                    end.to raise_error NoMethodError

                    clean_api.on nil, :stuff

                    expect(args).to eq [[:stuff]]
                end
            end
        end

        context 'when no object is given' do
            it 'is treated as a catch-call' do
                args = []
                subject.define_call_handler clean_api_spec, :on do |*a|
                    args << a
                end

                subject.define_call_handler clean_api_spec, :on, :something do |*a|
                end

                clean_api.on
                clean_api.on nil
                clean_api.on [:stuff]
                clean_api.on :stuff2, { mode: :stuff }

                clean_api.on :something

                expect(args).to eq [[], [nil], [[:stuff]], [:stuff2, { mode: :stuff }]]
            end
        end
    end
end
