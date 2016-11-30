require_relative '../decimal'
require_relative '../rates'

require 'bigdecimal'
require 'bigdecimal/newton'
include Newton

module Finance
  module Calculator
    class Xirr
      def initialize(transactions)
        @transactions = transactions
      end

      # calculate the internal rate of return for a sequence of cash flows with dates
      # @return [Rate] the internal rate of return
      # @example
      #   @transactions = []
      #   @transactions << Transaction.new(-1000, :date => Time.new(1985,01,01))
      #   @transactions << Transaction.new(  600, :date => Time.new(1990,01,01))
      #   @transactions << Transaction.new(  600, :date => Time.new(1995,01,01))
      #   Finance::Calculator::Xirr.new(@transactions, 0.5).compute #=> Rate("0.024851", :apr, :compounds => :annually)
      # @api public
      def compute
        # Make sure we have a valid sequence of cash flows.
        positives, negatives = @transactions.partition{ |t| t.amount >= 0 }
        if positives.empty? || negatives.empty?
          raise ArgumentError, "Calculation does not converge."
        end

        func = Function.new(@transactions, Xnpv)
        rate = [ func.one ]
        nlsolve( func, rate )
        Rate.new(rate[0], :apr, :compounds => :annually)
      end
    end
  end
end
