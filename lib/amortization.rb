require 'cashflows'
require 'transaction'

require 'rubygems'
require 'flt'

# 
# @example Borrow $250,000 under a 30 year, fixed-rate loan with a 4.25% APR
#   rate = Rate.new(0.0425, :apr, :duration => 30.years)
#   amortization = 250000.amortize(rate)
# @example Borrow $250,000 under a 30 year, adjustable rate loan, with an APR starting at 4.25%, and increasing by 1% every five years
#   values = %w{ 0.0425 0.0525 0.0625 0.0725 0.0825 0.0925 }
#   rates = values.collect { |value| Rate.new( value, :apr, :duration = 5.years ) }
#   arm = Amortization.new(250000, *rates)
# @example Borrow $250,000 under a 30 year, fixed-rate loan with a 4.25% APR, but pay $150 extra each month
#   rate = Rate.new(0.0425, :apr, :duration => 30.years)
#   extra_payments = 250000.amortize(rate){ |period| period.payment - 150 }
# @api public
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

    pmt = Transaction.new(amount)
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

  # @return [Integer] the time required to pay off the loan, in months
  # @example
  #   rate = 
  # @api public
  def duration
    @payments.length
  end

  # create a new Amortization instance
  # @return [Amortization]
  # @param [DecNum] principal the initial amount of the loan or investment
  # @param [Rate] rates the applicable interest rates
  # @param [Proc] block
  # @example there are two ways to create a new Amortization
  #   rate = 
  # @api public
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

  # @return [DecNum] the periodic payment due on a loan
  # @param [DecNum] principal the initial amount of the loan or investment
  # @param [Rate] rate the applicable interest rate (per period)
  # @param [Integer] periods the number of periods needed for repayment
  # @note in most cases, you will probably want to use rate.monthly when calling this function outside of an Amortization instance.
  # @example
  #   rate = Rate.new(0.0375, :apr, :duration => 30.years)
  #   rate.duration #=> 360
  #   Amortization.payment(200000, rate.monthly, rate.duration) #=> DecNum('-926.23')
  # @see http://en.wikipedia.org/wiki/Amortization_calculator
  # @api public
  def Amortization.payment(principal, rate, periods)
    -(principal * (rate + (rate / ((1 + rate) ** periods - 1)))).round(2)
  end

  # "Pretty print" a text amortization table.
  def pprint
    @periods.each_with_index do |p, i|
      puts "%03d  $%9s  %8s  $%7s  $%7s  $%9s" % [i, p.principal, p.rate, p.payment, p.interest, p.balance]
    end
  end
end

class Numeric
  # @see Amortization#new
  # @api public
  def amortize(*rates, &block)
    amortization = Amortization.new(self, *rates, &block)
  end
end
