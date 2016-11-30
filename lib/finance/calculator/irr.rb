require_relative '../decimal'
require_relative '../rates'

require 'bigdecimal'
require 'bigdecimal/newton'
include Newton

module Finance
  module Calculator
    class Irr
      def initialize(values)
        @values = values
      end

      # calculate the internal rate of return for a sequence of cash flows
      # @return [DecNum] the internal rate of return
      # @example
      #   Finance::Calculator::Irr.new([-4000,1200,1410,1875,1050]).compute #=> 0.143
      # @see http://en.wikipedia.org/wiki/Internal_rate_of_return
      # @api public
      def compute
        # Make sure we have a valid sequence of cash flows.
        positives, negatives = @values.partition{ |i| i >= 0 }
        if positives.empty? || negatives.empty?
          raise ArgumentError, "Calculation does not converge."
        end

        func = Function.new(@values, Npv)
        rate = [ func.one ]
        nlsolve( func, rate )
        rate[0]
      end
    end
  end
end
