class Transaction
  attr_accessor :amount

  def additional_amount
    @amount - @original
  end

  def initialize(amount)
    @amount = amount
    @original = amount
  end

  def inspect
    "Payment(#{@amount})"
  end

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
