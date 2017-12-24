require 'singleton'
require 'securerandom'

module DSeL
module API

class Generator
    include Singleton

    # @return   [Hash]
    #   Data on the last call made.
    attr_reader :last_call

    def last_call_with_caller?
        @last_call_with_caller
    end

    def last_call_without_caller!
        @last_call_with_caller = false
    end

    def last_call_with_caller!
        @last_call_with_caller = true
    end

    def on_call( &block )
        fail ArgumentError, 'Missing &block' if !block

        synchronize do
            @on_call << block
        end

        self
    end

    # @note Defaults to `Object#hash` and assumes case-insensitive strings.
    #
    # Sets a way to calculate unique routing hashes for call objects.
    #
    # @param    [Symbol, #call] hasher
    #   * `Symbol`: Object method.
    #   * `#call`: To be passed each object and return an Integer hash.
    def call_object_hasher=( hasher )
        if hasher && !(hasher.is_a?( Symbol ) || hasher.respond_to?( :call ))
            fail ArgumentError,
                 "Expected Symbol or #call-able hasher, got: #{hasher.inspect}"
        end

        @call_object_hasher = hasher
    end

    # @private
    def initialize
        reset
    end
    
    # @private
    def reset
        @mutex   = Monitor.new
        @on_call = []

        @last_call_with_caller = false
        @call_object_hasher    = false

        self
    end

    # @private
    def define_definers( node, *types )
        synchronize do
            types.each do |type|
                define_definer( node, type )
            end
        end

        nil
    end

    # @private
    def define_call_handler( node, type, *possible_object, &block )
        node.instance_eval do
            handler = Generator.call_handler_name( type, *possible_object )

            if method_defined?( handler )
                fail ArgumentError,
                     'Call handler already exists: ' <<
                         Generator.handler_to_s( self, type, *possible_object )
            end

            # We can get the options from here and do stuff...I don't know.
            push_call_handler( type, handler, *possible_object )
            define_method handler, &block
        end

        define_call_router( node, type )

        nil
    end

    # @private
    def calling( node, type, handler, args, *possible_object, &block )
        synchronize do
            begin
                @last_call = {
                    node: node,
                    type: type
                }

                if !possible_object.empty?
                    @last_call.merge!( object: possible_object.first )
                end

                @last_call.merge!(
                    handler: handler,
                    args:    args
                )

                if last_call_with_caller?
                    @last_call[:caller] = caller
                end

                t = Time.now
                r = block.call
                @last_call[:time] = Time.now - t

                call_on_call( @last_call )

                r
            end
        end
    end

    # @private
    def definer_name( type )
        "def_#{type}".to_sym
    end

    # @private
    def call_handler_name( type, *possible_object )
        possible_object.empty? ?
            call_handler_catch_all_name( type ) :
            call_handler_with_object_name( type, possible_object.first )
    end

    # @private
    def call_handler_with_object_name( type, object )
        "_#{type}_#{call_object_hash_for( object )}_#{token}".to_sym
    end

    # @private
    def call_handler_catch_all_name( type )
        "_#{type}_catch_all_#{token}".to_sym
    end

    # @private
    def handler_to_s( node, type, *possible_object )
        r = "#{node} #{type}"

        if !possible_object.empty?
            object = possible_object.first
            r << ' '
            r << (object.nil? ? 'nil' : object.to_s)
        end

        r
    end

    private

    def call_on_call( *args )
        @on_call.each do |b|
            b.call *args
        end
    end

    def call_object_hash_for( object )
        if !@call_object_hasher
            default_call_object_hash_for( object )
        elsif @call_object_hasher.is_a?( Symbol )
            object.send( @call_object_hasher )
        else
            @call_object_hasher.call( object )
        end.tap do |h|
            next if h.is_a? Integer

            fail ArgumentError,
                 "Hasher #{@call_object_hasher.inspect} returned non-Integer" <<
                 " hash #{h.inspect} for object #{object.inspect}."
        end
    end

    def default_call_object_hash_for( object )
        object = object.downcase if object.is_a?( String )
        object.hash
    end

    def token
        @token ||= SecureRandom.hex
    end

    def define_definer( node, type )
        definer = Generator.definer_name( type )

        # We can get the options from here and do stuff...I don't know.
        node.push_definer( type, definer )

        node.class_eval( "undef :#{definer} if defined? #{definer}" )
        node.define_singleton_method definer do |*possible_object, &block|
            if possible_object.size > 1
                fail ArgumentError,  'No more than 1 objects are allowed.'
            end

            Generator.define_call_handler( self, type, *possible_object, &block )
        end
    end

    def define_call_router( node, type )
        node.instance_eval do
            return if method_defined?( type )

            # Basically a router, object-based and catch-all.
            define_method type do |*args, &block|
                if !args.empty?
                    object      = args.shift
                    with_object = Generator.call_handler_with_object_name( __method__, object )

                    if respond_to?( with_object )
                        Generator.calling( self.class, type, with_object, args, object ) do
                            send( with_object, *args, &block )
                        end

                        return self
                    end

                    args.unshift object
                end

                catch_all = Generator.call_handler_catch_all_name( __method__ )
                if respond_to?( catch_all )
                    Generator.calling( self.class, type, catch_all, args ) do
                        send( catch_all, *args, &block )
                    end

                    return self
                end

                fail NoMethodError,
                     "No handler for: #{Generator.handler_to_s( self.class, type, *args )}"
            end
        end
        nil
    end

    def synchronize( &block )
        @mutex.synchronize( &block )
    end

    class <<self

        def method_missing( sym, *args, &block )
            if instance.respond_to?( sym )
                instance.send( sym, *args, &block )
            else
                super( sym, *args, &block )
            end
        end

        def respond_to?( *args )
            super || instance.respond_to?( *args )
        end

        # Ruby 2.0 doesn't like my class-level method_missing for some reason.
        # @private
        public :allocate

    end

end

end
end
