require 'rubygems'
require 'flt'

# the Rate class provides an interface for working with interest rates.
# @example test
#   rate = Rate.new()
# @see http://en.wikipedia.org/wiki/Effective_interest_rate
# @see http://en.wikipedia.org/wiki/Nominal_interest_rate
# @api public
class Rate
  # Accepted effective rate types
  @@ETYPES = %w{apr apy effective}
  # Accepted nominal rate types
  @@NTYPES = %w{nominal}

  # @return [Numeric] the duration for which the rate is valid, in months
  # @api public
  attr_accessor :duration
  # @return [Numeric] the effective interest rate
  # @api public
  attr_reader :effective
  # @return [Numeric] the nominal interest rate
  # @api public
  attr_reader :nominal

  # compare two Rates, using the effective rate
  # @return [Numeric] one of -1, 0, +1
  # @param [Rate] rate the comparison Rate
  # @example Which is better, a nominal rate of 15% compounded monthly, or 15.5% compounded semiannually?
  #   r1 = Rate.new(0.15, :nominal) #=> Rate.new(0.160755, :apr)
  #   r2 = Rate.new(0.155, :nominal, :compounds => :semiannually) #=> Rate.new(0.161006, :apr)
  #   r1 <=> r2 #=> -1
  # @api public
  def <=>(rate)
    @effective <=> rate.effective
  end

  # (see #effective)
  # @api public
  def apr
    self.effective
  end

  # (see #effective)
  # @api public
  def apy
    self.effective
  end

  # a convenience method which sets the value of @periods
  # @return none
  # @param [String, Numeric] input the compounding frequency
  # @raises [ArgumentError] if input is not an accepted keyword or Numeric
  # @api private
  def compounds=(input)
    @periods = case input
               when :annually     then Flt::DecNum 1
               when :continuously then Flt::DecNum.infinity
               when :daily        then Flt::DecNum 365
               when :monthly      then Flt::DecNum 12
               when :quarterly    then Flt::DecNum 4
               when :semiannually then Flt::DecNum 2
               when Numeric       then Flt::DecNum input.to_s
               else raise ArgumentError
               end
  end

  # set the effective interest rate
  # @return none
  # @param [Numeric] rate the effective interest rate
  # @api private
  def effective=(rate)
    @effective = rate
    @nominal = Rate.to_nominal(rate, @periods)
  end

  # create a new Rate instance
  # @return [Rate]
  # @param [Numeric] rate the decimal value of the interest rate
  # @param [String] type a valid rate type (see @@ETYPES and @@NTYPES)
  # @param [optional, Hash] opts set optional attributes
  # @option opts [String] :duration a time interval for which the rate is valid
  # @option opts [String] :compounds (:monthly) the number of compounding periods per year
  # @example create a 3.5% APR rate
  #   Rate.new(0.035, :apr) #=> Rate(0.035, :apr)
  # @api public
  def initialize(rate, type, opts={})
    unless rate.class == Flt::DecNum
      rate = Flt::DecNum rate.to_s 
    end

    validate_type type

    # Default monthly compounding.
    opts = { :compounds => :monthly }.merge opts

    # Set optional attributes..
    opts.each do |key, value|
      send("#{key}=", value)
    end

    # Set the rate in the proper way, based on the value of type.
    if @@ETYPES.include? type.to_s
      self.effective = rate
    else
      self.nominal = rate
    end
  end

  def inspect
    "Rate.new(#{self.apr.round(6)}, :apr)"
  end

  # @return [Numeric] the monthly effective interest rate
  # @example
  #   rate = Rate.new(0.15, :nominal)
  #   rate.apr.round(6) #=> DecNum('0.160755')
  #   rate.monthly.round(6) #=> DecNum('0.013396')
  # @api public
  def monthly
    (self.effective / 12).round(15)
  end

  # set the nominal interest rate
  # @return none
  # @param [Numeric] rate the nominal interest rate
  # @api private
  def nominal=(rate)
    @nominal = rate
    @effective = Rate.to_effective(rate, @periods)
  end

  # convert a nominal interest rate to an effective interest rate
  # @return [Numeric] the effective interest rate
  # @param [Numeric] rate the nominal interest rate
  # @param [Numeric] periods the number of compounding periods per year
  # @example
  #   Rate.to_effective(0.05, 4) #=> 0.05095
  # @api public
  def Rate.to_effective(rate, periods)
    unless periods == Flt::DecNum.infinity
      (1 + rate / periods) ** periods - 1
    else
      rate.exp - 1
    end
  end

  # convert an effective interest rate to a nominal interest rate
  # @return [Numeric] the nominal interest rate
  # @param [Numeric] rate the effective interest rate
  # @param [Numeric] periods the number of compounding periods per year
  # @example
  #   Rate.to_nominal(0.06, 365) #=> 0.05827
  # @see http://www.miniwebtool.com/nominal-interest-rate-calculator/
  # @api public
  def Rate.to_nominal(rate, periods)
    unless periods == Flt::DecNum.infinity
      periods * ((1 + rate) ** (1 / periods) - 1)
    else
      Math.log(rate + 1)
    end
  end

  # validate the value of the type variable
  # @return none
  # @raise [ArgumentError] if an acceptable rate type is not provided
  # @param [String] type
  # @api private
  def validate_type(type)
    types = @@ETYPES + @@NTYPES
    unless types.include? type.to_s
      raise ArgumentError, "type must be one of #{types.join(', ')}", caller
    end
  end

  private :compounds=, :effective=, :nominal=, :validate_type
end
