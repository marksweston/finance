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
  def initialize(amount)
    @amount = amount
    @original = amount
  end

  # @api public
  def inspect
    "Payment(#{@amount})"
  end

  # @return none
  # @param [Block] modifier a block which returns a modified amount for the transaction
  # @api public
  def modify(&modifier)
    value = modifier.call(self)
    
    # There's a chance that the block does not return a decimal.
    unless value.class == Flt::DecNum
      value = Flt::DecNum value.to_s
    end

    @amount = value
  end

  # (see #amount)
  # @depreciated Provided for backwards compatibility
  def payment
    @amount
  end
end
