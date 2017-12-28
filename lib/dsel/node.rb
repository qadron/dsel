module DSeL
class Node

    # @return   [Object]
    attr_reader :subject

    # @return   [Base, nil]
    attr_reader :parent

    # @return   [Base]
    #   `self` if {#root?}.
    attr_reader :root

    # @param   [Object] subject
    # @param   [Hash] options
    # @option   options [Base, nil] :parent (nil)
    def initialize( subject = nil, options = {} )
        @subject = subject
        @parent  = options[:parent]
        @root    = (@parent ? @parent._dsel_node.root : self)
    end

    def root?
        @root == self
    end

    # @private
    def _dsel_node
        self
    end

    def calc_node_hash( subject )
        "#{self.class}:#{subject.object_id}".hash
    end

    def hash
        calc_node_hash( @subject )
    end

end

end
