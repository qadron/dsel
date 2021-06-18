require 'dsel'
require 'dsel/ruby/object'
require_relative 'my_class'

MyClass.new.as_direct_dsel do
    p private_method
    # => :private

    Iv2 {
        Parent {
            p self.class
            # => MyClass
        }

        p self.class
        # => String

        p to_s
        # => "hello"

        concat ' world!'
        capitalize!

        p to_s
        # => "Hello world!"
    }

    more_ivars

    Iv4 {
        # This is being run inside the actual instance.
        @only_visible_to_Iv4 = true

        def only_visible_to_Iv4
            @only_visible_to_Iv4
        end

        p self.class
        # => Array
        p self
        # => [4]

        push 6
        push 7

        p self
        # => [4, 6, 7]

        Parent {
            Iv2 {
                Root {
                    ap self.class
                    # => MyClass
                }
            }
        }
    }

    p @only_visible_to_Iv4
    # => nil

    p @iv4.only_visible_to_Iv4
    # => true

    p Iv4 { @only_visible_to_Iv4 }
    # => true

    set = create_set.as_direct_dsel do
        merge [1,2,3,4]
    end

    p set
    # => #<Set: {1, 2, 3, 4}>
end
