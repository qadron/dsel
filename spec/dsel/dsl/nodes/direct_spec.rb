require 'spec_helper'

RSpec.describe DSeL::DSL::Nodes::Direct do
    include_examples DSeL::DSL::Nodes::Base

    it 'uses the context as the environment' do
        subject.run{}
        expect(subject.environment).to be subject.subject
    end

    describe '#run' do
        let(:environment) do
            subject.run{}
            subject.environment
        end

        it 'removes environment methods from the object' do
            called = true

            subject.extend_env.each do |mod|
                mod.instance_methods( true ).each do |m|
                    next if subject.reset_methods.include? m

                    expect(environment).to_not respond_to m
                end
            end

            expect(called).to be_truthy
        end

        it 'resets overridden object methods' do
            called = true

            subject.reset_methods.each do |m|
                next if !environment.respond_to? m

                expect(environment.method(m).source_location).to be_nil
            end

            expect(called).to be_truthy
        end
    end
end
