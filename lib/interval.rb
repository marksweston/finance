class Integer
  # convert an integer value representing months into months
  # @return [Integer] the number of months
  # @example
  #   360.months #=> 360
  # @api public
  def months
    self
  end

  # convert an integer value representing years into months
  # @return [Integer] the number of months
  # @example
  #   30.years #=> 360
  # @api public
  def years
    self * 12
  end
end
