require_relative '../decimal'
require_relative '../rates'

require 'bigdecimal'
require 'bigdecimal/newton'
include Newton

module Finance
  module Calculator
    class Xnpv
      def initialize(transactions, rate)
        @transactions = transactions
        @rate = rate
      end

      # calculate the net present value of a sequence of cash flows
      # @return [DecNum]
      # @example
      #   @transactions = []
      #   @transactions << Transaction.new(-1000, :date => Time.new(1985,01,01))
      #   @transactions << Transaction.new(  600, :date => Time.new(1990,01,01))
      #   @transactions << Transaction.new(  600, :date => Time.new(1995,01,01))
      #   Finance::Calculator::Xnpv.new(@transactions, 0.6).compute.round(2) #=> -937.41
      # @api public
      def compute
        rate  = Flt::DecNum.new(@rate.to_s)
        start = @transactions[0].date

        @transactions.inject(0) do |sum, t|
          n = t.amount / ( (1 + rate) ** ((t.date-start) / Flt::DecNum.new(31536000.to_s))) # 365 * 86400
          sum + n
        end
      end
    end
  end
end
