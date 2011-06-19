require 'rubygems'
require 'flt'

class Rate
	attr_accessor :duration
	attr_accessor :periods
	attr_accessor :nominal

	def compounds(input)

		translate= {
			:annually => Flt::DecNum(1),
			:continuously => Flt::DecNum.infinity,
			:daily => Flt::DecNum(365),
			:monthly => Flt::DecNum(12),
			:quarterly => Flt::DecNum(4),
			:semiannually => Flt::DecNum(2)
			}

		if translate.has_key? input
			@periods = translate.fetch input
		elsif input.kind_of? Numeric
			@periods = Flt::DecNum input.to_s 
		end
	end

	def decimal(value)
		unless value.class == Flt::DecNum
			Flt::DecNum(value.to_s)
		else
			value
		end
	end

	def effective=(rate)
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
		unless opts.has_key? :compounds
			opts[:compounds] = :monthly
		end
		
		compounds opts[:compounds]

		if opts.has_key? :effective: self.effective = decimal(opts[:effective])
		elsif opts.has_key? :nominal: @nominal = decimal(opts[:nominal])
		end
	end

	def monthly
		(self.effective / 12).round(6)
	end
end
