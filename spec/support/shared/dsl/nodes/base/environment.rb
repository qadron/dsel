require 'tempfile'

shared_examples_for DSeL::DSL::Nodes::Base::Environment do
    if !defined? :subject
        subject do
            Class.new( described_class ).new
        end
    end

    let(:node_class) do
        sep = '::'
        splits = described_class.to_s.split( sep )
        splits.pop

        Object.const_get( splits.join( sep ) )
    end
    let(:node) { node_class.new( node_context, node_options ) }
    let(:node_options) { {} }
    let(:node_context) { '2' }

    let(:other_node) { node_class.new( other_node_context, other_node_options ) }
    let(:other_node_options) { {} }
    let(:other_node_context) { '1' }

    let(:another_node) { node_class.new( another_node_context, another_node_options ) }
    let(:another_node_options) { {} }
    let(:another_node_context) { '3' }

    before do
        subject.send( "#{described_class::DSEL_NODE_ACCESSOR}=", node )
    end

    describe '#instance_variables' do
        it "excludes #{described_class::DSEL_NODE_IVAR}" do
            expect(subject.instance_variables).to_not include described_class::DSEL_NODE_IVAR
        end
    end

    describe '#_dsel_shared_variables' do
        it 'delegates to node' do
            expect(subject._dsel_shared_variables).to be node.shared_variables
        end
    end

    describe '#_dsel_self' do
        it 'returns the context' do
            expect(subject._dsel_self).to be node.context
        end
    end

    describe '#_dsel_variables' do
        it 'returns instance variables' do
            subject.instance_variable_set( :@tmp, 1 )
            expect(subject._dsel_variables).to eq( tmp: 1 )
        end
    end

    describe '#Parent' do
        context 'when #root?' do
            it 'raises error' do
                expect do
                    subject.Parent{}
                end.to raise_error RuntimeError
            end
        end

        context 'when not #root?' do
            let(:node_options) { { parent: other_node } }

            it 'runs the block in the parent' do
                node = nil
                p = proc { node = send( DSeL::DSL::Nodes::Base::Environment::DSEL_NODE_ACCESSOR ) }

                subject.Parent( &p )

                expect(node).to be other_node
            end
        end
    end

    describe '#Root' do
        context 'when #root?' do
            it 'raises error' do
                expect do
                    subject.Root{}
                end.to raise_error RuntimeError
            end
        end

        context 'when not #root?' do
            let(:node_options) { { parent: other_node } }
            let(:other_node_options) { { parent: another_node } }

            it 'runs the block in the root' do
                n = nil
                p = proc { n = send( DSeL::DSL::Nodes::Base::Environment::DSEL_NODE_ACCESSOR ) }

                subject.Root( &p )

                expect(n).to be another_node
            end
        end
    end
end
