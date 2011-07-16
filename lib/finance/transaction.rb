require_relative 'decimal'

module Finance
  # the Transaction class provides an interface for individual cash flows.
  # @api public
  class Transaction
    # @return [DecNum] the cash value of the transaction
    # @api public
    attr_accessor :amount

    # @return [DecNum] the difference between the 
    # @api public
    def additional_amount
      @amount - @original
    end

    # create a new Transaction
    # @return [Transaction]
    # @param [Numeric] amount the cash value of the transaction
    def initialize(amount, type=nil)
      @amount = amount
      @original = amount
      @type = type
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
    def modify(&modifier)
      @amount = modifier.call(self).to_decimal
    end

    # (see #amount)
    # @depreciated Provided for backwards compatibility
    def payment
      @amount
    end

    def payment?
      @type.eql? :payment
    end
  end
end
