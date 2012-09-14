require_relative '../lib/finance/effective_interest_rate.rb'
require_relative '../lib/finance/amortization.rb'
require_relative '../lib/finance/interval.rb'
require_relative '../lib/finance/rates.rb'

include Finance

require 'flt/d'
require 'minitest/unit'
require 'shoulda'
require 'bigdecimal'

# @see http://tinyurl.com/6zroqvd for detailed calculations for the
#   examples in these unit tests.
class TestAprScenarios < Test::Unit::TestCase

  def self.break_up(garbage)
    garbage.split("\n").collect {|r| r.strip.gsub(/\%|\$|,/,"").split(" ") }.select {|r| r.empty? == false}
  end

  context "Loan value variance examples" do
    setup do
      @interest_rate    = 0.0750
      @loan_fees        = 0.0
      @term_in_months   = 360

      @rate = Rate.new(@interest_rate, :apr, :duration => @term_in_months)
    end

    break_up(%($200,000    $1,398.43 
      $205,000    $1,433.39 
      $210,000    $1,468.35 
      $215,000    $1,503.31 
      $220,000    $1,538.27 
      $225,000    $1,573.23 
      $230,000    $1,608.19 
      $235,000    $1,643.15 
      $240,000    $1,678.11 
      $250,000    $1,748.04 
      $500,000    $3,496.07 
      $510,000    $3,565.99 
      $520,000    $3,635.92 
      $530,000    $3,705.84 
      $540,000    $3,775.76 
      $550,000    $3,845.68 
      $570,000    $3,985.52 
      $580,000    $4,055.44 
      $590,000    $4,125.37 
      $600,000    $4,195.29)).each do |arr|

      should "have payments of #{arr.last} for loan amount #{arr.first}" do
        amort = Amortization.new(arr.first.to_i, @rate)
        assert_equal amort.payment.abs.to_s, arr.last
      end
    end

  end

  context "Interest Rate Variance" do
    setup do
      @loan_fees        = 0.0
      @term_in_months   = 360
      @loan_amount      = 200000
    end

    break_up(%(4.00%   $954.83 
      4.10%  $966.40 
      4.20%  $978.03 
      4.30%  $989.74 
      4.40%  $1,001.52 
      4.50%  $1,013.37 
      4.60%  $1,025.29 
      4.70%  $1,037.28 
      4.80%  $1,049.33 
      4.90%  $1,061.45 
      5.00%  $1,073.64 
      5.10%  $1,085.90 
      5.20%  $1,098.22 
      5.30%  $1,110.61 
      5.40%  $1,123.06 
      5.50%  $1,135.58 
      5.60%  $1,148.16 
      5.70%  $1,160.80 
      5.80%  $1,173.51 
      5.90%  $1,186.27 
      )).each do |arr|

      should "have payments of #{arr.last} for interest rate of #{arr.first}" do
        # require 'finance'; require 'bigdecimal'; include Finance; data.each do |arr|; rate = Rate.new( (BigDecimal(arr.first) / 100).to_f, :apr, :duration => 360); end
        rate = Rate.new( (BigDecimal(arr.first) / 100).to_f, :apr, :duration => @term_in_months)
        amort = Amortization.new(@loan_amount, rate)
        assert_equal amort.payment.abs.to_s, arr.last
      end
    end
  end

  context "Term in Months Variance" do
    setup do
      @loan_fees        = 0.0
      @loan_amount      = 200000
      @interest_rate    = 0.0750
    end

    break_up(%(120   $2,374.04 
      126  $2,298.20 
      132  $2,229.60 
      138  $2,167.28 
      144  $2,110.45 
      150  $2,058.46 
      156  $2,010.74 
      162  $1,966.82 
      168  $1,926.29 
      174  $1,888.79 
      180  $1,854.02 
      186  $1,821.72 
      192  $1,791.66 
      198  $1,763.61 
      204  $1,737.42 
      210  $1,712.91 
      216  $1,689.95 
      222  $1,668.40 
      228  $1,648.16 
      234  $1,629.12)).each do |arr|

      should "have payments of #{arr.last} for loan term of #{arr.first} months" do
        rate = Rate.new(@interest_rate, :apr, :duration => arr.first.to_i)
        amort = Amortization.new(@loan_amount, rate)
        assert_equal amort.payment.abs.to_s, arr.last
      end
    end
  end

  context "Term in Months Variance" do
    setup do
      @loan_fees        = 0.0
      @loan_amount      = 200000
      @interest_rate    = 0.0750
      @term_in_months   = 360
    end

    # annual loan fee; repayments; effect interest rate %
    break_up(%( $60   -$1,411.01   7.59 
      $72  -$1,413.53   7.61 
      $84  -$1,416.05   7.63 
      $96  -$1,418.57   7.65 
      $108   -$1,421.08   7.66 
      $120   -$1,423.60   7.68 
      $132   -$1,426.12   7.70 
      $144   -$1,428.64   7.72 
      $156   -$1,431.15   7.74 
      $168   -$1,433.67   7.76 
      $180   -$1,436.19   7.77 
      $192   -$1,438.70   7.79 
      $204   -$1,441.22   7.81 
      $216   -$1,443.74   7.83 
      $228   -$1,446.26   7.85 
      $240   -$1,448.77   7.87 
      $252   -$1,451.29   7.88 
      $264   -$1,453.81   7.90 
      $276   -$1,456.32   7.92 
      $288   -$1,458.84   7.94)).each do |arr|

      should "have effective interest rate of #{arr.last} and repayments of #{arr[1]} for loan fees #{arr.first} " do
        loan_fees = arr.first.to_i
        repayment = arr[1]
        eir = arr.last.to_f

        payment = Finance::EffectiveInterestRate.calc_payment(@loan_amount, @interest_rate, @term_in_months, loan_fees)
        assert_equal repayment.to_f, payment.round(2)

        # res = Finance::EffectiveInterestRate.calc_effective_interest_rate(360, -1433.39, 200000)
        rate = Finance::EffectiveInterestRate.calc_effective_interest_rate(@term_in_months, payment, @loan_amount)
        assert_equal eir, (rate * 12).round(2)
      end
    end
  end

  context "Loan Term (NPER)" do
    setup do
      @loan_fees        = 0.0
      @loan_amount      = 200000
      @interest_rate    = 0.0750
    end

    break_up(%(120   $2,374.04 
      126  $2,298.20 
      132  $2,229.60 
      138  $2,167.28 
      144  $2,110.45 
      150  $2,058.46 
      156  $2,010.74 
      162  $1,966.82 
      168  $1,926.29 
      174  $1,888.79 
      180  $1,854.02 
      186  $1,821.72 
      192  $1,791.66 
      198  $1,763.61 
      204  $1,737.42 
      210  $1,712.91 
      216  $1,689.95 
      222  $1,668.40 
      228  $1,648.16 
      234  $1,629.12)).each do |arr|

      should "have loan term (nper) of #{arr.first} for payments #{arr.first}" do
        assert_equal Finance::EffectiveInterestRate.calc_nper(@interest_rate/12, -(arr.last.to_f), 200000), arr.first.to_i
      end
    end
  end

end

