require 'tempfile'

shared_examples_for DSeL::DSL::Nodes::Base do
    subject { described_class.new( context, options ) }
    let(:options) { {} }
    let(:context) { '2' }

    let(:other)  { described_class.new( other_context, other_options ) }
    let(:other_options) { {} }
    let(:other_context) { '1' }

    let(:other_dup)  { described_class.new( other_context, other_options ) }

    describe '#initialize' do
        describe 'context' do
            it 'sets the DSL context' do
                expect(subject.context).to be context
            end
        end

        describe 'options' do
            describe ':parent' do
                let(:options) { { parent: other } }

                it 'sets the parent' do
                    expect(subject.parent).to be other
                end
            end
        end
    end

    describe '#run' do
        let(:script) do
            <<RUBY
                _dsel_self
RUBY
        end
        let(:file) do
            f = Tempfile.new
            f.write script
            f.flush
            f.path
        end

        it 'preserves the same environment between runs' do
            subject.run{}

            e = subject.environment
            subject.run{}

            expect(subject.environment).to be e
        end

        describe 'script' do
            it 'runs the script within the context' do
                expect(subject.run( file )).to be context
            end
        end

        describe '&block' do
            it 'runs the block within the context' do
                expect(subject.run { _dsel_self }).to be context
            end
        end

        context 'if both are given' do
            it 'raises ArgumentError' do
                expect do
                    subject.run( file ){}
                end.to raise_error ArgumentError
            end
        end

        context 'before running' do
            it "sets ##{described_class::Environment::DSEL_RUNNER_ACCESSOR}" do
                expect(subject.run { _dsel_runner }).to be subject
            end
        end

        context 'after running' do
            it "removes ##{described_class::Environment::DSEL_RUNNER_ACCESSOR}" do
                subject.run { _dsel_self }
                expect(subject.environment._dsel_runner).to be_nil
            end
        end
    end

    describe '#runners' do
        it 'includes self' do
            expect(subject.runners.values).to eq [subject]
        end

        context 'when #root?' do
            let(:other_options) { { parent: subject } }

            it 'provides access to all nodes' do
                other
                expect(subject.runners.values).to eq [subject, other]
            end
        end

        context 'when not #root?' do
            let(:other_options) { { parent: subject } }

            it "delegates to root's #runners" do
                expect(other.runners).to be subject.runners
            end
        end
    end

    describe '#shared_variables' do
        let(:other_options) { { parent: subject } }

        it 'provides shared access to a hash' do
            other.shared_variables[1] = 2
            expect(subject.shared_variables).to eq(  1 => 2 )

            expect(subject.shared_variables).to be other.shared_variables
        end
    end

    describe '#root?' do
        context 'when root' do
            let(:other_options) { { parent: subject } }

            it 'returns true' do
                other
                expect(subject).to be_root
            end
        end

        context 'when not root' do
            let(:other_options) { { parent: subject } }

            it 'returns false' do
                expect(other).to_not be_root
            end
        end
    end

    describe '#push_runner' do
        context 'when given a unique runner' do
            it 'pushes it to #runners' do
                expect(subject.runners.values).to eq [subject]

                subject.push_runner other
                expect(subject.runners.values).to eq [subject, other]
            end

            it 'returns it' do
                expect(subject.push_runner( other )).to be other
            end
        end

        context 'when given a duplicate runner' do
            it 'ignores it' do
                expect(subject.runners.values).to eq [subject]

                subject.push_runner other
                subject.push_runner other_dup

                expect(subject.runners.values).to eq [subject, other]
            end

            it 'returns the existing one' do
                subject.push_runner other
                expect(subject.push_runner( other_dup )).to be other
            end
        end
    end

    describe '#runner_for' do
        let(:runner) { subject.runner_for( other_context ) }

        context 'when given a unique context' do
            it 'returns a runner' do
                expect(runner.context).to be other_context
            end

            it 'stores it' do
                runner
                expect(subject.runners.values).to eq [subject, runner]
            end
        end

        context 'when given a duplicate context' do
            it 'ignores it' do
                expect(subject.runners.values).to eq [subject]

                subject.push_runner other
                runner

                expect(subject.runners.values).to eq [subject, other]
            end

            it 'returns the existing one' do
                subject.push_runner other
                expect(runner).to be other
            end

            it 'sets self as #parent' do
                expect(runner.parent).to be subject
            end
        end
    end

    describe '#hash' do
        it 'takes into account .class' do
            h1 = subject.hash

            expect(subject).to receive(:class).and_return( Object )

            expect(h1).to_not eq subject.hash
        end

        it 'takes into account context#object_id' do
            h1 = subject.hash

            expect(subject.context).to receive(:object_id).and_return( 1 )

            expect(h1).to_not eq subject.hash
        end
    end

    describe '#_dsel_runner' do
        it 'returns self' do
            expect(subject._dsel_runner).to be subject
        end
    end
end
