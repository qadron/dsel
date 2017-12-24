module DSeL
module DSL
module Nodes
class APIBuilder

module Environment
    include Base::Environment

    def import( file )
        f = _dsl_caller_dir
        f << file
        f << '.rb' if !file.end_with?( '.rb' )

        _dsl_import f
    end

    def import_many( glob )
        Dir["#{_dsl_caller_dir}#{glob}.rb"].each { |file| _dsl_import( file ) }
    end

    def child( method_name, class_name, *args, &block )
        runner = _dsl_runner.runner_for(
            class_name,
            namespace: _dsl_runner.context
        )
        runner.run( &block )

        _dsl_runner.context.push_child(
            method_name,
            runner.context,
            *args
        )
    end

    def _dsl_import( file )
        _dsl_runner.context.instance_eval( IO.read( file ) )
    end

    def _dsl_caller_dir( offset = 1 )
        File.dirname( caller[offset].split( ':', 2 ).first ) << '/'
    end

end

end
end
end
end
