require_relative 'decimal'

module Finance
  # the Transaction class provides a general interface for working with individual cash flows.
  # @api public
  class Transaction
    # @return [DecNum] the cash value of the transaction
    # @api public
    attr_reader :amount
    # @return [Integer] the period number of the transaction
    # @note this attribute is mainly used in the case of mortgage amortization with no dates
    # @api public
    attr_accessor :period

    # Set the cash value of the transaction
    # @return None
    # @param [Numeric] value the cash value
    # @example
    #   t = Transaction.new(500)
    #   t.amount = 750
    #   t.amount #=> 750
    # @api public
    def amount=(value)
      @amount = value.to_d
    end

    # @return [DecNum] the difference between the original transaction
    #   amount and the current amount
    # @example
    #   t = Transaction.new(500)
    #   t.amount = 750
    #   t.difference #=> DecNum('250')
    # @api public
    def difference
      @amount - @original
    end

    # create a new Transaction
    # @return [Transaction]
    # @param [Numeric] amount the cash value of the transaction
    # @param [optional, Hash] opts sets optional attributes
    # @option opts [String] :period the period number of the transaction
    # @example a simple transaction
    #   t = Transaction.new(400)
    # @example a transaction with a period number
    #   t = Transaction.new(400, :period => 3)
    # @api public
    def initialize(amount, opts={})
      @amount = amount
      @original = amount
      
      # Set optional attributes..
      opts.each do |key, value|
        send("#{key}=", value)
      end
    end

    # @return [Boolean] whether or not the Transaction is an Interest transaction
    # @example
    #   pmt = Payment.new(500)
    #   int = Interest.new(500)
    #   pmt.interest? #=> False
    #   int.interest? #=> True
    # @api public
    def interest?
      self.instance_of? Interest
    end

    # @api public
    def inspect
      "Transaction(#{@amount})"
    end

    # Modify a Transaction's amount by passing a block
    # @return none
    # @note self is passed as the argument to the block.  This makes any public attribute available.
    # @example add $100 to a monthly payment
    #   pmt = Payment.new(-500)
    #   pmt.modify { |t| t.amount-100 }
    #   pmt.amount #=> -600
    # @api public
    def modify
      @amount = yield(self)
    end

    # (see #amount)
    # @deprecated Provided for backwards compatibility
    def payment
      @amount
    end

    # @return [Boolean] whether or not the Transaction is a Payment transaction
    # @example
    #   pmt = Payment.new(500)
    #   int = Interest.new(500)
    #   pmt.payment? #=> True
    #   int.payment? #=> False
    # @api public
    def payment?
      self.instance_of? Payment
    end
  end

  class Interest < Transaction
    def inspect
      "Interest(#{@amount})"
    end
  end

  class Payment < Transaction
    def inspect
      "Payment(#{@amount})"
    end
  end
end
