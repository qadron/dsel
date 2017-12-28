require 'spec_helper'

RSpec.describe DSeL::DSL::Nodes::APIBuilder::Environment do
    include_examples DSeL::DSL::Nodes::Base::Environment

    let(:node_context) { Factory[:clean_api_spec] }
    let(:other_node_context) { Factory[:clean_api_spec] }
    let(:another_node_context) { Factory[:clean_api_spec] }

    subject do
        def node.cleanup_environment
        end

        node.run{}
        node.environment
    end

    let(:script) do
        <<RUBY
        define :on
RUBY
    end
    let(:filename) do
        'script.rb'
    end
    let(:file) do
        File.open "#{Dir.tmpdir}/#{filename}", 'w' do |f|
            f.write script
            f.flush
            f.path
        end
    end

    describe '#import' do
        it 'imports a file' do
            expect(subject.definers).to be_empty
            subject.import file
            expect(subject.definers).to eq [{ type: :on, method: :def_on}]
        end

        context 'without extension' do
            let(:filename) do
                'script'
            end

            it 'assumes .rb' do
                expect(subject.definers).to be_empty
                subject.import file
                expect(subject.definers).to eq [{ type: :on, method: :def_on}]
            end
        end
    end

    describe '#import_many' do
        it 'imports globs' do
            expect(subject.definers).to be_empty
            subject.import_many "#{Dir.tmpdir}/scr*pt"
            expect(subject.definers).to eq [{ type: :on, method: :def_on}]
        end
    end

    describe '#import_relative' do
        it 'imports a file'

        context 'without extension' do
            let(:filename) do
                'script'
            end

            it 'assumes .rb'
        end
    end

    describe '#import_relative_many' do
        it 'imports relative globs'
    end

    describe '#child' do
        it 'adds a child node' do
            subject.child :child, :Child, 1, 2, 3 do
            end

            expect(subject.children).to eq(
                child: {
                    name: :child,
                    node: subject.const_get( :Child )
                }
            )
        end
    end
end
