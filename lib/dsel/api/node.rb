module DSeL
module API

# @author Tasos "Zapotek" Laskos <tasos.laskos@sarosys.com>
class Node

    def self.inherited( base )
        base.extend ClassMethods
    end

    module ClassMethods
        def run( *args, &block )
            DSL::Nodes::API.new( new ).run( *args, &block )
        end

        def define( *types )
            if types.size > 1
                if has_options?
                    fail ArgumentError,
                         "Cannot set options for multiple types: #{types}"
                end

                if has_description?
                    fail ArgumentError,
                         "Cannot set description for multiple types: #{types}"
                end
            end

            Generator.define_definers( self, *types )
        end

        def has_options?
            !!@last_options
        end

        def has_description?
            !!@last_description
        end

        def describe( description )
            @last_description = description
        end

        def configure( options, &block )
            @last_options = [options, block].compact
        end

        def definers
            @definers ||= []
        end

        def has_call_handler?( type, *possible_object )
            method_defined? Generator.call_handler_name( type, *possible_object )
        end

        def call_handlers
            @call_handlers ||= []
        end

        def root?
            !parent
        end

        def child?
            !root?
        end

        def root
            return self if root?

            @root ||= begin
                p = @parent
                while p.parent
                    p = p.parent
                end
                p
            end
        end

        def parent
            @parent
        end

        def push_children( c )
            c.each do |name, (klass, *args)|
                push_child( name, klass, *args )
            end

            nil
        end

        def push_child( name, node, *args )
            node.set_parent( self )

            child = {
                name: name.to_sym,
                node: node
            }

            if (options = self.flush_options)
                child.merge!( options: options )
            end

            if (description = self.flush_description)
                child.merge!( description: description )
            end

            children[name] = child

            define_method name do
                ivar = "@#{name}"

                v = instance_variable_get( ivar )
                return v if v

                instance_variable_set( ivar, node.new( *args ) )
            end

            child
        end

        def children
            @children ||= {}
        end

        def tree
            root.branch
        end

        def branch
            t = {
                definers:      self.definers,
                call_handlers: self.call_handlers.map { |h| c = h.dup; c.delete( :method ); c },
                children:      {}
            }

            self.children.each do |name, child|
                t[:children][name] = child.merge( child[:node].branch )
            end

            t
        end

        # @private
        def flush_description
            d = @last_description
            @last_description = nil
            d
        end

        # @private
        def flush_options
            o = @last_options
            @last_options = nil
            o
        end

        # @private
        def push_call_handler( type, method, *possible_object )
            handler = {
                type: type.to_sym
            }

            if !possible_object.empty?
                handler.merge!( object: possible_object.first )
            end

            if (options = self.flush_options)
                handler.merge!( options: options )
            end

            if (description = self.flush_description)
                handler.merge!( description: description )
            end

            handler.merge!(
                method: method.to_sym
            )

            call_handlers << handler
            handler
        end

        # @private
        def set_parent( node )
            fail if @parent
            @parent = node
        end

        # @private
        def push_definer( type, method )
            definer = {
                type: type.to_sym
            }

            if (options = self.flush_options)
                definer.merge!( options: options )
            end

            if (description = self.flush_description)
                definer.merge!( description: description )
            end

            definer.merge!(
                method: method.to_sym
            )

            definers << definer
            definer
        end

    end

end

end
end
