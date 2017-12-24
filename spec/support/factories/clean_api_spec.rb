Factory.define :clean_api_spec do
    Object.const_set(
        "MockNode#{rand(9999)}".to_sym,
        Class.new( DSeL::API::Node )
    )
end
