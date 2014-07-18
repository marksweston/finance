require_relative '../decimal'
require_relative '../rates'

require 'bigdecimal'
require 'bigdecimal/newton'
include Newton

# Base class for working with Newton's Method.
class Function
  values = {
    eps: "1.0e-16",
    one: "1.0",
    two: "2.0",
    ten: "10.0",
    zero: "0.0"
    }

  values.each do |key, value|
    define_method key do
      BigDecimal.new value
    end
  end

  def initialize(transactions, calculator_type)
    @transactions = transactions
    @calculator_type = calculator_type
  end

  def values(x)
    calculator = @calculator_type.new(@transactions, Flt::DecNum.new(x[0].to_s))
    value = calculator.compute
    [ BigDecimal.new(value.to_s) ]
  end
end
