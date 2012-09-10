require_relative 'cashflows'
require_relative 'decimal'
require_relative 'transaction'

module Finance

  class EffectiveInterestRate

    FINANCIAL_PRECISION = 0.00000001
    FINANCIAL_MAX_ITERATIONS = 128


    # Implementation of Execl's RATE function
    # RATE  RATE(NPER, PMT, PV, FV, type, guess)  
    # Returns the constant interest rate per period of an annuity. 
    # => NPER is the total number of periods, during which payments are made (payment period). 
    # => PMT is the constant payment (annuity) paid during each period. 
    # => PV is the cash value in the sequence of payments. 
    # => FV (optional) is the future value, which is reached at the end of the periodic payments. 
    # => Type (optional) defines whether the payment is due at the beginning (1) or the end (0) of a period. 
    # => Guess (optional) determines the estimated value of the interest with iterative calculation.
    # see test/test_effective_interest_rate.rb for examples
    # adapted from Java code found here: http://www.pcpros.com/software/programming/java/java.shtml
    # Example:
    # Finance::EffectiveInterestRate.calc_effective_interest_rate(360, -1433.39, 200000)
    def self.calc_effective_interest_rate(nper, pmt, pv, fv = 0.0, type = 0, guess = 0.1) 
      
      y = 0; y0 = 0; y1 = 0; x0 = 0; x1 = 0; f = 0; i = 0
      
      # convert to floats
      rate = guess * 1.0
      pmt = pmt * 1.0
      pv = pv * 1.0
      fv = fv * 1.0
      
      if rate.abs < FINANCIAL_PRECISION
        y = pv * (1.0 + nper * rate) + pmt * (1.0 + rate * type) * nper + fv
      else
        # puts "r1 #{rate}"
        f = Math.exp(nper * Math.log(1.0 + rate))
        y = pv * f + pmt * (1.0 / rate + type) * (f - 1) + fv
      end

      y0 = pv + pmt * nper + fv
      y1 = pv * f + pmt * (1.0 / rate + type) * (f - 1) + fv
      
      # find root by secant method
      i = x0 = 0.0
      x1 = rate
      
      while (((y0 - y1).abs > FINANCIAL_PRECISION) && (i < FINANCIAL_MAX_ITERATIONS))
        rate = (y1 * x0 - y0 * x1) / (y1 - y0)
        x0 = x1
        x1 = rate

        if (rate.abs < FINANCIAL_PRECISION) 
          y = pv * (1.0 + nper * rate) + pmt * (1.0 + rate * type) * nper + fv
        else
          # puts "r2 #{rate}"
          f = Math.exp(nper * Math.log(1.0 + rate))
          y = pv * f + pmt * (1.0 / rate + type) * (f - 1) + fv
        end

        y0 = y1
        y1 = y
        i += 1
      end
      
      return rate * 100
    end

    # This will return identical results that Finance::Amortization will given annual_fee = 0
    # Simply adds ability to use annual_fee
    # see test/test_effective_interest_rate.rb for examples
    def self.calc_payment(principal, rate, periods, annual_fee = 0)
      -(rate/12)*((annual_fee*periods/12)+principal)/(1-(1+rate/12) ** -periods)
    end

  end
end