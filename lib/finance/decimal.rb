require 'rubygems'
require 'flt'

class Numeric
  def to_decimal
    Flt::DecNum self.to_s
  end
end
