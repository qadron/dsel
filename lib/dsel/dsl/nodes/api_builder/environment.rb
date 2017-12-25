module DSeL
module DSL
module Nodes
class APIBuilder

module Environment
    include Base::Environment

    def import( file )
        f = _dsel_caller_dir
        f << file
        f << '.rb' if !file.end_with?( '.rb' )

        _dsel_import f
    end

    def import_many( glob )
        Dir["#{_dsel_caller_dir}#{glob}.rb"].each { |file| _dsel_import( file ) }
    end

    def child( method_name, class_name, *args, &block )
        runner = _dsel_runner.runner_for(
            class_name,
            namespace: _dsel_runner.context
        )
        runner.run( &block )

        _dsel_runner.context.push_child(
            method_name,
            runner.context,
            *args
        )
    end

    def _dsel_import( file )
        _dsel_runner.context.instance_eval( IO.read( file ) )
    end

    def _dsel_caller_dir( offset = 1 )
        File.dirname( caller[offset].split( ':', 2 ).first ) << '/'
    end

end

end
end
end
end
