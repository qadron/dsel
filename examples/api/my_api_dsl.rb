p self.class
# => DSeL::DSL::Nodes::API::Environment

p real_self
# => #<MyAPI ..>

to :start, :this do
    :stuff
end
# => :start
# => [[:this], :stuff]

to :stop, :that do
    :other_stuff
end
# => :stop
# => [[:that], :other_stuff]

Section_1 {

    p real_self
    # => #<MyAPI::Section_1 ..>

    on :stuff, :other_stuff
    # => :stuff
    # => [:other_stuff]

    after :stuff
    # => :catch_all
    # => [:stuff]

    Section_1_0 {

        p real_self
        # => #<MyAPI::Section_1::Section_1_0 ..>

        before :this, :that; also :the, :other; also :last, 'I promise.'
        # => :this
        # => [:that]
        # => :the
        # => [:other]
        # => :the
        # => [:last, "I promise."]

        Parent {
            p real_self
            # => #<MyAPI::Section_1 ..>
        }

        Root {
            p real_self
            # => #<MyAPI ..>
        }
    }
}

p real_self
# => #<MyAPI ..>

Section_2 {
    p real_self
    # => #<MyAPI::Section_2 ..>

    after :more_stuff, :even_more_stuff
    # => :more_stuff
    # => [:even_more_stuff]
}
