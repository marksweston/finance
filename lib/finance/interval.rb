class Integer
  # convert an integer value representing months (or years) into months
  # @return [Integer] the number of months
  # @example
  #   360.months #=> 360
  #   30.years #=> 360
  # @api public
  def method_missing(name, *args, &block)
    return self      if name.to_s == "months"
    return self * 12 if name.to_s == "years"
    super
  end
end
