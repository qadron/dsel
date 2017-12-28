require 'tempfile'

shared_examples_for DSeL::DSL::Nodes::Base do
    include_examples DSeL::Node

    subject { described_class.new( context, options ) }
    let(:options) { {} }
    let(:context) { '2' }

    let(:other)  { described_class.new( other_context, other_options ) }
    let(:other_options) { {} }
    let(:other_context) { '1' }

    let(:other_dup)  { described_class.new( other_context, other_options ) }

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
            it "sets ##{described_class::Environment::DSEL_NODE_ACCESSOR}" do
                expect(subject.run { _dsel_node }).to be subject
            end
        end

        context 'after running' do
            it "removes ##{described_class::Environment::DSEL_NODE_ACCESSOR}" do
                subject.run { _dsel_self }
                expect(subject.environment.instance_variable_get(described_class::Environment::DSEL_NODE_IVAR)).to be_nil
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

    describe '#nodes' do
        it 'includes self' do
            expect(subject.nodes.values).to eq [subject]
        end

        context 'when #root?' do
            let(:other_options) { { parent: subject } }

            it 'provides access to all nodes' do
                other
                expect(subject.nodes.values).to eq [subject, other]
            end
        end

        context 'when not #root?' do
            let(:other_options) { { parent: subject } }

            it "delegates to root's #nodes" do
                expect(other.nodes).to be subject.nodes
            end
        end
    end

    describe '#cache_node' do
        context 'when given a unique node' do
            it 'pushes it to #nodes' do
                expect(subject.nodes.values).to eq [subject]

                subject.cache_node other
                expect(subject.nodes.values).to eq [subject, other]
            end

            it 'returns it' do
                expect(subject.cache_node(other )).to be other
            end
        end

        context 'when given a duplicate node' do
            it 'ignores it' do
                expect(subject.nodes.values).to eq [subject]

                subject.cache_node other
                subject.cache_node other_dup

                expect(subject.nodes.values).to eq [subject, other]
            end

            it 'returns the existing one' do
                subject.cache_node other
                expect(subject.cache_node(other_dup )).to be other
            end
        end
    end

    describe '#node_for' do
        let(:node) { subject.node_for( other_context ) }

        context 'when given a unique context' do
            it 'returns a node' do
                expect(node.subject).to be other_context
            end

            it 'stores it' do
                node
                expect(subject.nodes.values).to eq [subject, node]
            end
        end

        context 'when given a duplicate context' do
            it 'ignores it' do
                expect(subject.nodes.values).to eq [subject]

                subject.cache_node other
                node

                expect(subject.nodes.values).to eq [subject, other]
            end

            it 'returns the existing one' do
                subject.cache_node other
                expect(node).to be other
            end

            it 'sets self as #parent' do
                expect(node.parent).to be subject
            end
        end
    end
end
