require 'rubygems'
require 'flt'

class Rate
	attr_accessor :duration
	attr_accessor :periods
	attr_accessor :nominal

  # Alias method for *effective*.
	def apr=(apr)
		self.effective = apr
	end

  # Alias method for *effective*.
	def apy=(apy)
		self.effective = apy
	end

	def decimal(value)
		unless value.class == Flt::DecNum
			Flt::DecNum(value.to_s)
		else
			value
		end
	end

	def effective=(rate)
		rate = decimal(rate)

		unless @periods == Flt::DecNum.infinity
			@nominal = @periods * ((1 + rate) ** (1 / @periods) - 1)
		else
			@nominal = Math.log(rate + 1)
		end
	end

	def effective
		unless @periods == Flt::DecNum.infinity
			(1 + @nominal / @periods) ** @periods - 1
		else
			@nominal.exp - 1
		end
	end

	def initialize(opts={})
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

		opts.each do |key, value|
			unless key == :compounds
			  send("#{key}=", value)
			end
		end
	end

	def monthly
		(self.effective / 12).round(6)
	end

	def nominal=(nominal)
		@nominal = decimal(nominal)
	end
end
