shared_examples_for DSeL::Node do
    subject { described_class.new( context, options ) }
    let(:options) { {} }
    let(:context) { '2' }

    let(:other)  { described_class.new( other_context, other_options ) }
    let(:other_options) { {} }
    let(:other_context) { '1' }

    describe '#initialize' do
        describe 'subject' do
            it 'sets the DSL subject' do
                expect(subject.subject).to be context
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

    describe '#hash' do
        it 'takes into account .class' do
            h1 = subject.hash

            expect(subject).to receive(:class).and_return( Object )

            expect(h1).to_not eq subject.hash
        end

        it 'takes into account subject#object_id' do
            h1 = subject.hash

            expect(subject.subject).to receive(:object_id).and_return( 1 )

            expect(h1).to_not eq subject.hash
        end
    end

    describe '#_dsel_node' do
        it 'returns self' do
            expect(subject._dsel_node).to be subject
        end
    end
end
