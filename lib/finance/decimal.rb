require 'rubygems'
require 'flt'
include Flt

DecNum.context.define_conversion_from(BigDecimal) do |x, context|
  DecNum(x.to_s)
end

DecNum.context.define_conversion_to(BigDecimal) do |x|
  BigDecimal(x.to_s)
end

class Numeric
  def to_d
    if self.instance_of? DecNum
      self
    else
      DecNum self.to_s
    end
  end
end
