require_relative 'cashflows'
require_relative 'decimal'
require_relative 'transaction'

module Finance
  # the Amortization class provides an interface for working with loan amortizations.
  # @note There are _two_ ways to create an amortization.  The first
  #   example uses the amortize method for the Numeric class.  The second
  #   calls Amortization.new directly.
  # @example Borrow $250,000 under a 30 year, fixed-rate loan with a 4.25% APR
  #   rate = Rate.new(0.0425, :apr, :duration => (30 * 12))
  #   amortization = 250000.amortize(rate)
  # @example Borrow $250,000 under a 30 year, adjustable rate loan, with an APR starting at 4.25%, and increasing by 1% every five years
  #   values = %w{ 0.0425 0.0525 0.0625 0.0725 0.0825 0.0925 }
  #   rates = values.collect { |value| Rate.new( value, :apr, :duration = (5 * 12) ) }
  #   arm = Amortization.new(250000, *rates)
  # @example Borrow $250,000 under a 30 year, fixed-rate loan with a 4.25% APR, but pay $150 extra each month
  #   rate = Rate.new(0.0425, :apr, :duration => (5 * 12))
  #   extra_payments = 250000.amortize(rate){ |period| period.payment - 150 }
  # @api public
  class Amortization
    # @return [DecNum] the balance of the loan at the end of the amortization period (usually zero)
    # @api public
    attr_reader :balance
    # @return [DecNum] the required monthly payment.  For loans with more than one rate, returns nil
    # @api public
    attr_reader :payment
    # @return [DecNum] the principal amount of the loan
    # @api public
    attr_reader :principal
    # @return [Array] the interest rates used for calculating the amortization
    # @api public
    attr_reader :rates

    # compare two Amortization instances
    # @return [Numeric] -1, 0, or +1
    # @param [Amortization]
    # @api public
    def ==(amortization)
      self.principal == amortization.principal and self.rates == amortization.rates and self.payments == amortization.payments
    end

    # @return [Array] the amount of any additional payments in each period
    # @example
    #   rate = Rate.new(0.0375, :apr, :duration => (30 * 12))
    #   amt = 300000.amortize(rate){ |payment| payment.amount-100}
    #   amt.additional_payments #=> [DecNum('-100.00'), DecNum('-100.00'), ... ]
    # @api public
    def additional_payments
      @transactions.find_all(&:payment?).collect{ |p| p.difference }
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

      pmt = Payment.new(amount, :period => @period)
      if @block then pmt.modify(&@block) end

      rate.duration.to_i.times do
        # Do this first in case the balance is zero already.
        if @balance.zero? then break end

        # Compute and record interest on the outstanding balance.
        int = (@balance * rate.monthly).round(2)
        interest = Interest.new(int, :period => @period)
        @balance += interest.amount
        @transactions << interest.dup

        # Record payment.  Don't pay more than the outstanding balance.
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
    # @example In most cases, the duration is equal to the total duration of all rates
    #   rate = Rate.new(0.0375, :apr, :duration => (30 * 12))
    #   amt = 300000.amortize(rate)
    #   amt.duration #=> 360
    # @example Extra payments may reduce the duration
    #   rate = Rate.new(0.0375, :apr, :duration => (30 * 12))
    #   amt = 300000.amortize(rate){ |payment| payment.amount-100}
    #   amt.duration #=> 319
    # @api public
    def duration
      self.payments.length
    end

    # create a new Amortization instance
    # @return [Amortization]
    # @param [DecNum] principal the initial amount of the loan or investment
    # @param [Rate] rates the applicable interest rates
    # @param [Proc] block
    # @api public
    def initialize(principal, *rates, &block)
      @principal = Flt::DecNum.new(principal.to_s)
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
    # @example find the total cost of interest for a loan
    #   rate = Rate.new(0.0375, :apr, :duration => (30 * 12))
    #   amt = 300000.amortize(rate)
    #   amt.interest.sum #=> DecNum('200163.94')
    # @example find the total interest charges in the first six months
    #   rate = Rate.new(0.0375, :apr, :duration => (30 * 12))
    #   amt = 300000.amortize(rate)
    #   amt.interest[0,6].sum #=> DecNum('5603.74')
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
    #   rate = Rate.new(0.0375, :apr, :duration => (30 * 12))
    #   rate.duration #=> 360
    #   Amortization.payment(200000, rate.monthly, rate.duration) #=> DecNum('-926.23')
    # @see http://en.wikipedia.org/wiki/Amortization_calculator
    # @api public
    def Amortization.payment(principal, rate, periods)
      -(principal * (rate + (rate / ((1 + rate) ** periods - 1)))).round(2)
    end

    # @return [Array] the amount of the payment in each period
    # @example find the total payments for a loan
    #   rate = Rate.new(0.0375, :apr, :duration => (30 * 12))
    #   amt = 300000.amortize(rate)
    #   amt.payments.sum #=> DecNum('-500163.94')
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
    Finance::Amortization.new(self, *rates, &block)
  end
end
