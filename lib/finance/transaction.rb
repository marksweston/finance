require_relative 'decimal'

module Finance
  # the Transaction class provides an interface for individual cash flows.
  # @api public
  class Transaction
    # @return [DecNum] the cash value of the transaction
    # @api public
    attr_accessor :amount
    attr_accessor :period
    attr_accessor :type

    # @return [DecNum] the difference between the 
    # @api public
    def additional_amount
      @amount - @original
    end

    # create a new Transaction
    # @return [Transaction]
    # @param [Numeric] amount the cash value of the transaction
    def initialize(amount, opts={})
      @amount = amount
      @original = amount
      
      # Set optional attributes..
      opts.each do |key, value|
        send("#{key}=", value)
      end
    end

    def interest?
      @type.eql? :interest
    end

    # @api public
    def inspect
      "Payment(#{@amount})"
    end

    # @return none
    # @param [Block] modifier a block which returns a modified amount for the transaction
    # @api public
    def modify
      @amount = yield(self).to_d
    end

    # (see #amount)
    # @deprecated Provided for backwards compatibility
    def payment
      @amount
    end

    def payment?
      @type.eql? :payment
    end
  end
end
