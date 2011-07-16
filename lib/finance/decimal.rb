require 'rubygems'
require 'flt'

class Numeric
  def to_d
    if self.instance_of? Flt::DecNum
      self
    else
      Flt::DecNum self.to_s
    end
  end
end
