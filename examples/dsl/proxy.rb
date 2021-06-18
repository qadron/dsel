require 'dsel'
require 'dsel/ruby/object'
require_relative 'my_class'

MyClass.new.as_dsel do
    # p private_method
    # => NameError

    Iv1 {
        upto 5 do |i|
            p i
        end
        # => 1
        # => 2
        # => 3
        # => 4
        # => 5
    }

    Iv2 {
        Parent {
            p self.class
            # => DSeL::DSL::Nodes::Proxy::Environment
        }

        p self.class
        # => DSeL::DSL::Nodes::Proxy::Environment

        p to_s
        # => "hello"

        concat ' world!'
        capitalize!

        p to_s
        # => "Hello world!"
    }

    more_ivars

    Iv4 {
        @only_visible_to_Iv4 = true

        p self.class
        # => DSeL::DSL::Nodes::Proxy::Environment
        p self
        # => [4]

        push 6
        push 7

        p self
        # => [4, 6, 7]

        Parent {
            Iv2 {
                Root {
                    p self.class
                    # => DSeL::DSL::Nodes::Proxy::Environment
                }
            }
        }
    }

    p @only_visible_to_Iv4
    # => nil

    p Iv4 { @only_visible_to_Iv4 }
    # => true

    set = create_set.as_dsel do
        merge [1,2,3,4]
    end

    p set
    # => #<Set: {1, 2, 3, 4}>
end
