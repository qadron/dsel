class Object

    def as_dsel( parent = nil, &block )
        _dsel_determine_runner( DSeL::DSL::Nodes::Proxy, parent ).run( &block )
    end

    def dsel_script( script, parent = nil )
        _dsel_determine_runner( DSeL::DSL::Nodes::Proxy, parent ).run( script )
    end

    def as_direct_dsel( parent = nil, &block )
        _dsel_determine_runner( DSeL::DSL::Nodes::Direct, parent ).run( &block )
    end

    def direct_dsel_script( script, parent = nil )
        _dsel_determine_runner( DSeL::DSL::Nodes::Direct, parent ).run( script )
    end

    def DSeL( object = self, &block )
        object.as_dsel( _dsel_self_if_runner, &block )
    end

    def DSeLScript( script, object = self )
        object.dsel_script( script, _dsel_self_if_runner )
    end

    def DirectDSeL( object = self, &block )
        object.as_direct_dsel( _dsel_self_if_runner, &block )
    end

    def DirectDSeLScript( script, object = self )
        object.direct_dsel_script( script, _dsel_self_if_runner )
    end

    private

    def _dsel_self_if_runner
        respond_to?( DSeL::DSL::Nodes::Base::Environment::DSEL_RUNNER_ACCESSOR ) ? self : nil
    end

    def _dsel_determine_runner( klass, parent = nil )
        return klass.new( self ) if !parent

        if parent._dsel_runner.is_a?( klass )
            parent._dsel_runner.runner_for( self )
        else
            runner = klass.new( self, parent: parent )
            parent._dsel_runner.push_runner runner
            runner
        end
    end

end
