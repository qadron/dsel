require 'dsel'

api = DSeL::DSL::Nodes::APIBuilder.build :MyAPI do
    # Import external root declerations.
    import_relative 'my_api/root'

    # You can also use globs to import multiple files.
    # import_relative_many 'my_api/children/*'

    p self
    # => MyAPI

    describe "Sets the 'start' procedure."
    def_to :start do |*args, &block|
        p :start
        p [args, block.call]
    end

    describe "Sets the 'stop' procedure."
    def_to :stop do |*args, &block|
        p :stop
        p [args, block.call]
    end

    describe 'This section handles...stuff.'
    configure generator:  { do: :stuff },
              node:       { do: :other_stuff }
    child :section_1, :Section_1 do
        p self
        # => MyAPI::Section_1

        describe 'Handles stuff that happen when other other stuff are about to happen.'
        configure generator:  { do: :stuff },
                  node:       { do: :other_stuff }
        define :on # Enables 'def_on'.

        describe 'Handles stuff that happen after other stuff.'
        define :after # Enables 'def_after'.

        describe 'This does that and some other stuff some times...'
        configure api: { do: :other_stuff },
                  dsl: { do_not: :do_stuff }
        def_on :stuff do |*args|
            p :stuff
            p args
        end

        # Catch-all.
        def_after do |*args|
            p :catch_all
            p args
        end

        child :section_1_0, :Section_1_0 do
            p self
            # => MyAPI::Section_1::Section_1_0

            define :before

            def_before :this do |*args|
                p :this
                p args
            end

            def_before :the do |*args|
                p :the
                p args
            end
        end
    end

    describe 'This section handles...other stuff.'
    child :section_2, :Section_2 do
        # Import some decleration for this section.
        import_relative 'my_api/sections/section_2'

        def_after :more_stuff do |*args|
            p :more_stuff
            p args
        end
    end

end

p api
# => MyAPI

# Tree data can help you generate API documentation dynamically.
ap api.tree
# {
#          :definers => [
#         [0] {
#                    :type => :to,
#             :description => "Fills in missing functionality.",
#                  :method => :def_to
#         }
#     ],
#     :call_handlers => [
#         [0] {
#                    :type => :to,
#                  :object => :start,
#             :description => "Sets the 'start' procedure."
#         },
#         [1] {
#                    :type => :to,
#                  :object => :stop,
#             :description => "Sets the 'stop' procedure."
#         }
#     ],
#          :children => {
#         :section_1 => {
#                      :name => :section_1,
#                      :node => MyAPI::Section_1 < DSeL::DSL::Nodes::APIBuilder::APINode,
#                   :options => [
#                 [0] {
#                     :generator => {
#                         :do => :stuff
#                     },
#                          :node => {
#                         :do => :other_stuff
#                     }
#                 }
#             ],
#               :description => "This section handles...stuff.",
#                  :definers => [
#                 [0] {
#                            :type => :on,
#                         :options => [
#                         [0] {
#                             :generator => {
#                                 :do => :stuff
#                             },
#                                  :node => {
#                                 :do => :other_stuff
#                             }
#                         }
#                     ],
#                     :description => "Handles stuff that happen when other other stuff are about to happen.",
#                          :method => :def_on
#                 },
#                 [1] {
#                            :type => :after,
#                     :description => "Handles stuff that happen after other stuff.",
#                          :method => :def_after
#                 }
#             ],
#             :call_handlers => [
#                 [0] {
#                            :type => :on,
#                          :object => :stuff,
#                         :options => [
#                         [0] {
#                             :api => {
#                                 :do => :other_stuff
#                             },
#                             :dsl => {
#                                 :do_not => :do_stuff
#                             }
#                         }
#                     ],
#                     :description => "This does that and some other stuff some times..."
#                 },
#                 [1] {
#                     :type => :after
#                 }
#             ],
#                  :children => {
#                 :section_1_0 => {
#                              :name => :section_1_0,
#                              :node => MyAPI::Section_1::Section_1_0 < DSeL::DSL::Nodes::APIBuilder::APINode,
#                          :definers => [
#                         [0] {
#                               :type => :before,
#                             :method => :def_before
#                         }
#                     ],
#                     :call_handlers => [
#                         [0] {
#                               :type => :before,
#                             :object => :this
#                         },
#                         [1] {
#                               :type => :before,
#                             :object => :the
#                         }
#                     ],
#                          :children => {}
#                 }
#             }
#         },
#         :section_2 => {
#                      :name => :section_2,
#                      :node => MyAPI::Section_2 < DSeL::DSL::Nodes::APIBuilder::APINode,
#               :description => "This section handles...other stuff.",
#                  :definers => [
#                 [0] {
#                       :type => :after,
#                     :method => :def_after
#                 }
#             ],
#             :call_handlers => [
#                 [0] {
#                       :type => :after,
#                     :object => :more_stuff
#                 }
#             ],
#                  :children => {}
#         }
#     }
# }
