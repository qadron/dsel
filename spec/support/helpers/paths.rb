def name_from_filename
    File.basename( caller.first.split( ':' ).first, '_spec.rb' )
end

def spec_path
    File.expand_path( File.dirname( File.absolute_path( __FILE__ )  ) + '/../../' ) << '/'
end

def examples_path
    File.expand_path( "#{spec_path}/../examples" ) << '/'
end

def support_path
    "#{spec_path}support/"
end

def fixtures_path
    "#{support_path}fixtures/"
end
