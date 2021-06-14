# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dsel/version'

Gem::Specification.new do |s|
    s.name     = 'dsel'
    s.version  = DSeL::VERSION
    s.email    = 'tasos.laskos@gmail.com'
    s.authors  = [ 'Tasos Laskos' ]
    s.licenses = ['MIT']

    s.summary  = %q{DSL/API generator and runner.}
    s.homepage = 'https://github.com/qadron/dsel'

    s.require_paths = ['lib']
    s.files        += Dir.glob( 'lib/**/**' )
    s.files        += %w(Gemfile Rakefile dsel.gemspec)
    s.test_files   = Dir.glob( 'spec/**/**' )

    s.extra_rdoc_files  = %w(README.md LICENSE.md CHANGELOG.md)
end
