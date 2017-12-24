class MyClass

    def initialize
        @iv1 = 1
        @iv2 = 'hello'
        @iv3 = { 3 => 4 }
    end

    def more_ivars
        @iv4 = [4]
    end

    def create_set
        Set.new
    end

    def show_new
        @new
    end

    private

    def private_method
        :private
    end

end
