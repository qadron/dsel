module DSeL
module DSL
module Nodes
class APIBuilder

module Environment
    include Base::Environment

    def import( file )
        f = file.dup
        f << '.rb' if !file.end_with?( '.rb' )

        _dsel_import f
    end

    def import_many( glob )
        Dir["#{glob}.rb"].each { |file| _dsel_import( file ) }
    end

    def import_relative( file )
        f = _dsel_caller_dir
        f << file
        f << '.rb' if !file.end_with?( '.rb' )

        _dsel_import f
    end

    def import_relative_many( glob )
        Dir["#{_dsel_caller_dir}#{glob}.rb"].each { |file| _dsel_import( file ) }
    end

    def child( method_name, class_name, *args, &block )
        node = _dsel_node.node_for( class_name )
        node.run( &block )

        _dsel_node.context.push_child(
            method_name,
            node.context,
            *args
        )
    end

    def _dsel_import( file )
        _dsel_node.context.instance_eval( IO.read( file ) )
    end

    def _dsel_caller_dir( offset = 1 )
        File.dirname( caller[offset].split( ':', 2 ).first ) << '/'
    end

end

end
end
end
end
