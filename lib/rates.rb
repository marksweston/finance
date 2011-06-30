require 'rubygems'
require 'flt'

class Rate
  attr_accessor :duration
  attr_accessor :periods

  attr_reader :effective
  attr_reader :nominal

  def ==(rate)
    self.nominal == rate.nominal and self.periods == rate.periods
  end

  # Alias method for *effective*.
  def apr=(apr)
    self.effective = apr
  end

  def apr
    self.effective
  end

  # Alias method for *effective*.
  def apy=(apy)
    self.effective = apy
  end

  def apy
    self.effective
  end

  def effective=(rate)
    @effective = rate
    @nominal = Rate.to_nominal(rate, @periods)
  end

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

  def inspect
    "Rate.new(#{self.apr.round(6)}, :apr)"
  end

  def monthly
    (self.effective / 12).round(15)
  end

  def nominal=(rate)
    @nominal = rate
    @effective = Rate.to_effective(rate, @periods)
  end

  def Rate.to_effective(rate, periods)
    unless periods == Flt::DecNum.infinity
      (1 + rate / periods) ** periods - 1
    else
      rate.exp - 1
    end
  end

  def Rate.to_nominal(rate, periods)
    unless periods == Flt::DecNum.infinity
      periods * ((1 + rate) ** (1 / periods) - 1)
    else
      Math.log(rate + 1)
    end
  end
end
