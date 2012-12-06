module SalesforceBulk
  class ResponseObject
    attr_reader :result

    FIELDS = []
    INT_FIELDS = []

    def initialize( result )
      @result = result.freeze
    end
 
    def field( name )
      name  = name.to_s
      type  = self.class.name.gsub(/.*::/, '')
      type  = type[0, 1].downcase + type[1..-1] #uncapitalize
      value = result[type][name]

      if self.class.int_field? name
        (value.nil? || value == '') ? nil : value.to_i
      else
        value
      end

    end

    def method_missing(meth, *args)
      if args.empty? && self.class.has_field?( meth )
        field( meth )
      else
        super
      end
    end

    # def to_s
    #   result.body
    # end

    class << self

      def has_field?(name)
        (const_get(:FIELDS) | const_get(:INT_FIELDS)).include? name.to_s
      end

      def int_field?(name)
        (const_get(:INT_FIELDS)).include? name.to_s
      end

    end
  end
end
