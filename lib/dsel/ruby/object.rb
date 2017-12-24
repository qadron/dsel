class Object

    def as_dsl( parent = nil, &block )
        _dsl_determine_runner( DSeL::DSL::Nodes::Proxy, parent ).run( &block )
    end

    def dsl_script( script, parent = nil )
        _dsl_determine_runner( DSeL::DSL::Nodes::Proxy, parent ).run( script )
    end

    def as_direct_dsl( parent = nil, &block )
        _dsl_determine_runner( DSeL::DSL::Nodes::Direct, parent ).run( &block )
    end

    def direct_dsl_script( script, parent = nil )
        _dsl_determine_runner( DSeL::DSL::Nodes::Direct, parent ).run( script )
    end

    def DSL( object = self, &block )
        object.as_dsl( _dsl_self_if_runner, &block )
    end

    def DSLScript( script, object = self )
        object.dsl_script( script, _dsl_self_if_runner )
    end

    def DirectDSL( object = self, &block )
        object.as_direct_dsl( _dsl_self_if_runner, &block )
    end

    def DirectDSLScript( script, object = self )
        object.direct_dsl_script( script, _dsl_self_if_runner )
    end

    private

    def _dsl_self_if_runner
        respond_to?( DSeL::DSL::Nodes::Base::Environment::DSL_RUNNER_ACCESSOR ) ? self : nil
    end

    def _dsl_determine_runner( klass, parent = nil )
        return klass.new( self ) if !parent

        if parent._dsl_runner.is_a?( klass )
            parent._dsl_runner.runner_for( self )
        else
            runner = klass.new( self, parent: parent )
            parent._dsl_runner.push_runner runner
            runner
        end
    end

end
