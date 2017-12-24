require 'spec_helper'

RSpec.describe DSeL do

    it 'has a version number' do
        expect(DSeL::VERSION).not_to be nil
    end

    describe 'examples/' do
        let(:examples_dir) { examples_path }

        describe 'api/' do
            let(:api_dir) { "#{examples_dir}/api/" }

            describe 'my_api' do
                before do
                    require "#{api_dir}/my_api"
                end

                describe 'my_api_dsl' do
                    it 'works' do
                        expect do
                            MyAPI.run "#{api_dir}/my_api_dsl.rb"
                        end.to_not raise_error
                    end
                end

                describe 'my_api_ruby' do
                    it 'works' do
                        expect do
                            require "#{api_dir}/my_api_ruby"
                        end.to_not raise_error
                    end
                end
            end
        end

        describe 'dsl/' do
            let(:dsl_dir) { "#{examples_dir}/dsl/" }

            before do
                require "#{dsl_dir}/object"
            end

            describe 'proxy' do
                it 'works' do
                    expect do
                        require "#{dsl_dir}/proxy"
                    end.to_not raise_error
                end
            end

            describe 'direct' do
                it 'works' do
                    expect do
                        require "#{dsl_dir}/direct"
                    end.to_not raise_error
                end
            end
        end
    end

end
