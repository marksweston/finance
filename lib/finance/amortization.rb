require_relative 'cashflows'
require_relative 'decimal'
require_relative 'transaction'

module Finance
  # the Amortization class provides an interface for working with loan amortizations.
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
    # @return [Numeric] the balance of the loan at the end of the amortization period (usually zero)
    # @api public
    attr_reader :balance
    # @return [Array] the interest charges on the loan
    # @api public
    attr_reader :interest
    # @return [Numeric] the required monthly payment.  For loans with more than one rate, returns nil
    # @api public
    attr_reader :payment
    # @return [Numeric] the principal amount of the loan
    # @api public
    attr_reader :principal
    # @return [Array] the interest rates used for calculating the amortization
    # @api public
    attr_reader :rates

    # @return [Numeric] -1, 0, or +1
    # @param [Amortization]
    # @api public
    def ==(amortization)
      self.principal == amortization.principal and self.rates == amortization.rates and self.payments == amortization.payments
    end

    # @return [Array] the amount of any additional payments in each period
    # @api public
    def additional_payments
      @transactions.find_all(&:payment?).collect{ |p| p.additional_amount }
    end

    # amortize the balance of loan with the given interest rate
    # @return none
    # @param [Rate] rate the interest rate to use in the amortization
    # @api private
    def amortize(rate)
      # For the purposes of calculating a payment, the relevant time
      # period is the remaining number of periods in the loan, not
      # necessarily the duration of the rate itself.
      periods = @periods - @period
      amount = Amortization.payment @balance, rate.monthly, periods

      pmt = Transaction.new(amount, :payment)
      if @block then pmt.modify(&@block) end
        
      rate.duration.times do
        # Do this first in case the balance is zero already.
        if @balance.zero? then break end

        # Compute and record interest on the outstanding balance.
        int = (@balance * rate.monthly).round(2)
        interest = Transaction.new(int, :interest)
        @balance += interest.amount
        @transactions << interest.dup

        # Don't pay more than the outstanding balance
        if pmt.amount.abs > @balance then pmt.amount = -@balance end

        @transactions << pmt.dup
        @balance += pmt.amount
        @period += 1
      end
    end

    # compute the amortization of the principal
    # @return none
    # @api private
    def compute
      @balance = @principal
      @transactions = []

      @rates.each do |rate|
        amortize(rate)
      end

      # Add any remaining balance due to rounding error to the last payment.
      unless @balance.zero?
        @transactions.find_all(&:payment?)[-1].amount -= @balance
        @balance = 0
      end

      if @rates.length == 1
        @payment = self.payments[0]
      else
        @payment = nil
      end

      @transactions.freeze
    end

    # @return [Integer] the time required to pay off the loan, in months
    # @example
    #   rate = 
    # @api public
    def duration
      self.payments.length
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
      @principal = principal.to_d
      @rates     = rates
      @block     = block
      
      # compute the total duration from all of the rates.
      @periods = (rates.collect { |r| r.duration }).sum
      @period  = 0

      compute
    end

    # @api public
    def inspect
      "Amortization.new(#{@principal})"
    end

    # @return [Array] the amount of interest charged in each period
    # @api public
    def interest
      @transactions.find_all(&:interest?).collect{ |p| p.amount }
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

    # @return [Array] the amount of the payment in each period
    # @api public
    def payments
      @transactions.find_all(&:payment?).collect{ |p| p.amount }
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
