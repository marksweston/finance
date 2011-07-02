require 'rubygems'
require 'flt'

class Rate
  attr_accessor :duration
  attr_accessor :periods

  attr_reader :effective
  attr_reader :nominal

  def ==(rate)
    @effective == rate.effective
  end

  # (see #effective=)
  # @api public
  def apr=(apr)
    self.effective = apr
  end

  # @api public
  def apr
    self.effective
  end

  # (see #effective=)
  # @api public
  def apy=(apy)
    self.effective = apy
  end

  # @api public
  def apy
    self.effective
  end

  # set the effective interest rate
  # @param [Numeric] rate the effective interest rate
  def effective=(rate)
    @effective = rate
    @nominal = Rate.to_nominal(rate, @periods)
  end

  # @api public
  def initialize(rate, type, opts={})
    # Make sure the rate is a decimal.
    unless rate.class == Flt::DecNum
      rate = Flt::DecNum rate.to_s 
    end

    # Set the compounding interval.
    compounding = opts.fetch(:compounds, :monthly)

    translate = {
      :annually => Flt::DecNum(1),
      :continuously => Flt::DecNum.infinity,
      :daily => Flt::DecNum(365),
      :monthly => Flt::DecNum(12),
      :quarterly => Flt::DecNum(4),
      :semiannually => Flt::DecNum(2)
      }

    if translate.has_key? compounding
      @periods = translate.fetch compounding
    elsif compounding.kind_of? Numeric
      @periods = Flt::DecNum compounding.to_s 
    end

    # Set the rate in the proper way, based on the value of :type:.
    if %w{apr apy effective}.include? type.to_s
      self.effective = rate
    else
      self.nominal = rate
    end

    # Set the remainder of the attributes provided in :opts:.
    opts.each do |key, value|
      unless key == :compounds
        send("#{key}=", value)
      end
    end
  end

  # @api public
  def inspect
    "Rate.new(#{self.apr.round(6)}, :apr)"
  end

  # @return [Numeric] the monthly effective interest rate
  # @api public
  def monthly
    (self.effective / 12).round(15)
  end

  # set the nominal interest rate
  # @param [Numeric] rate the nominal interest rate
  # @api public
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
  # @see http://en.wikipedia.org/wiki/Effective_interest_rate
  # @see http://en.wikipedia.org/wiki/Nominal_interest_rate
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
  # @see http://en.wikipedia.org/wiki/Effective_interest_rate
  # @see http://en.wikipedia.org/wiki/Nominal_interest_rate
  # @see http://www.miniwebtool.com/nominal-interest-rate-calculator/
  # @api public
  def Rate.to_nominal(rate, periods)
    unless periods == Flt::DecNum.infinity
      periods * ((1 + rate) ** (1 / periods) - 1)
    else
      Math.log(rate + 1)
    end
  end
end
