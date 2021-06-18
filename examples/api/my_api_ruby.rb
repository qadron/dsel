require_relative 'my_api'

p self.class
# => Object

api = MyAPI.new
p api
# => #<MyAPI ..>

api.to :start, :this do
    :stuff
end
# => :start
# => [[:this], :stuff]

api.to :stop, :that do
    :other_stuff
end
# => :stop
# => [[:that], :other_stuff]

p api.section_1
# => <#MyAPI::Section_1 ..>

api.section_1.on :stuff, :other_stuff
# => :stuff
# => [:other_stuff]

api.section_1.after :stuff
# => :catch_all
# => [:stuff]

p api.section_1.section_1_0
# => <#MyAPI::Section_1::Section_1_0 ..>

api.section_1.section_1_0.before :this, :that
api.section_1.section_1_0.before :the, :other
api.section_1.section_1_0.before :the, :last, 'I promise.'
# => :this
# => [:that]
# => :the
# => [:other]
# => :the
# => [:last, "I promise."]

p api.section_2
# => <#MyAPI::Section_2 ..>

api.section_2.after :more_stuff, :even_more_stuff
# => :more_stuff
# => [:even_more_stuff]
