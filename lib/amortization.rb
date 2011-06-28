require 'rubygems'
require 'cashflows'
require 'flt'

class Period
  attr_accessor :payment
  attr_accessor :principal
  attr_accessor :rate

  def additional_payment
    @payment-@original_payment
  end

  # Return the remaining balance at the end of the period.
  def balance
    @principal + @payment + self.interest
  end

  def initialize(principal, rate, payment)
    @principal = principal
    @rate = rate
    @payment = payment
    @original_payment = payment
  end

  # Return the interest charged for the period.
  def interest
    (@principal * @rate).round(2)
  end

  def modify_payment(&modifier)
    value = modifier.call(self)
    
    # There's a chance that the block does not return a decimal.
    unless value.class == Flt::DecNum
      value = Flt::DecNum value.to_s
    end

    self.payment = value
  end

  def payment=(value)
    total = @principal + self.interest
    if value.abs > total
      @payment = -total
    else
      @payment = value
    end
  end
end

class Amortization
  attr_accessor :balance
  attr_accessor :block
  attr_accessor :rate_duration
  attr_accessor :payment
  attr_accessor :periods
  attr_accessor :principal
  attr_accessor :rates

  def ==(amortization)
    self.principal == amortization.principal and self.rates == amortization.rates and self.payments == amortization.payments
  end

  def additional_payments
    @periods.collect{ |period| period.additional_payment }
  end

  def amortize(rate)
    # For the purposes of calculating a payment, the relevant time
    # period is the remaining number of periods in the loan, _not_ the
    # duration of the rate itself.
    duration = @rate_duration - @periods.length
    payment = Amortization.payment @balance, rate.monthly, duration

    rate.duration.times do
      # Do this first in case the balance is zero already.
      if @balance.zero?
        break
      end

      period = Period.new(@balance, rate.monthly, payment)

      if @block
        period.modify_payment(&@block)
      end
      
      @periods << period
      @balance = period.balance
    end

    if @rates.length == 1
      @payment = self.payments[0]
    else
      @payment = nil
    end
  end

  # Compute the amortization of the principal.
  def compute
    @balance = @principal
    @periods = []

    @rates.each do |rate|
      amortize(rate)
    end

    # Add any remaining balance due to rounding error to the last payment.
    unless @balance.zero?
      @periods[-1].payment -= @balance
      @balance = 0
    end
  end

  def duration
    @periods.length
  end

  def initialize(principal, *rates, &block)
    @principal = principal
    @rates     = rates
    @rate_duration  = (rates.collect { |r| r.duration }).sum
    @block     = block

    compute
  end

  def inspect
    "Amortization.new(#{@principal}"
  end

  # Return an Array with the amount of interest charged in each period.
  def interest
    @periods.collect { |period| period.interest }
  end

  # Return the periodic payment due on a loan, based on the
  #{http://en.wikipedia.org/wiki/Amortization_calculator amortization process}.
  def Amortization.payment(balance, rate, periods)
    -(balance * (rate + (rate / ((1 + rate) ** periods - 1)))).round(2)
  end

  # Return an array with the payment amount for each period.
  def payments
    @periods.collect { |period| period.payment }
  end

  # "Pretty print" a text amortization table.
  def pprint
    @periods.each_with_index do |p, i|
      puts "%03d  $%9s  %8s  $%7s  $%7s  $%9s" % [i, p.principal, p.rate, p.payment, p.interest, p.balance]
    end
  end
end

class Numeric
  def amortize(rate, &block)
    amortization = Amortization.new(self, rate, &block)
  end
end
