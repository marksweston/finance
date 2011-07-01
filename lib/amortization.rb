require_relative 'cashflows'

require 'rubygems'
require 'flt'

class Payment
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

  # Return the amount of the payment.  Provided for backwards compatibility.
  def payment
    @amount
  end
end

class Amortization
  attr_accessor :additional_payments
  attr_accessor :balance
  attr_accessor :block
  attr_accessor :interest
  attr_accessor :rate_duration
  attr_accessor :payment
  attr_accessor :payments
  attr_accessor :principal
  attr_accessor :rates

  def ==(amortization)
    self.principal == amortization.principal and self.rates == amortization.rates and self.payments == amortization.payments
  end

  def amortize(rate)
    # For the purposes of calculating a payment, the relevant time
    # period is the remaining number of periods in the loan, not
    # necessarily the duration of the rate itself.
    periods = @rate_duration - @payments.length
    amount = Amortization.payment @balance, rate.monthly, periods

    pmt = Payment.new(amount)
    if @block then pmt.modify(&@block) end
      
    rate.duration.times do
      # Do this first in case the balance is zero already.
      if @balance.zero? then break end

      # Compute and record interest on the outstanding balance.
      interest = (@balance * rate.monthly).round(2)
      @balance += interest
      @interest << interest

      # Don't pay more than the outstanding balance
      if pmt.amount.abs > @balance then pmt.amount = -@balance end

      @payments << pmt.amount
      @additional_payments << pmt.additional_amount
      @balance += pmt.amount
    end
  end

  # Compute the amortization of the principal.
  def compute
    @balance = @principal
    @interest = []
    @payments = []
    @additional_payments = []

    @rates.each do |rate|
      amortize(rate)
    end

    # Add any remaining balance due to rounding error to the last payment.
    unless @balance.zero?
      @payments[-1] -= @balance
      @balance = 0
    end

    if @rates.length == 1
      @payment = self.payments[0]
    else
      @payment = nil
    end
  end

  def duration
    @payments.length
  end

  def initialize(principal, *rates, &block)
    @principal = principal
    @rates     = rates
    @rate_duration  = (rates.collect { |r| r.duration }).sum
    @block     = block

    compute
  end

  def inspect
    "Amortization.new(#{@principal})"
  end

  # Return the periodic payment due on a loan, based on the
  #{http://en.wikipedia.org/wiki/Amortization_calculator amortization process}.
  def Amortization.payment(balance, rate, periods)
    -(balance * (rate + (rate / ((1 + rate) ** periods - 1)))).round(2)
  end

  # "Pretty print" a text amortization table.
  def pprint
    @periods.each_with_index do |p, i|
      puts "%03d  $%9s  %8s  $%7s  $%7s  $%9s" % [i, p.principal, p.rate, p.payment, p.interest, p.balance]
    end
  end
end

class Numeric
  def amortize(*rates, &block)
    amortization = Amortization.new(self, *rates, &block)
  end
end
