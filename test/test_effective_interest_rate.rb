require_relative '../lib/finance/effective_interest_rate.rb'

require 'flt/d'
require 'minitest/unit'
require 'shoulda'

# @see http://tinyurl.com/6zroqvd for detailed calculations for the
#   examples in these unit tests.
class TestEffectiveInterestRate < Test::Unit::TestCase

  context "fixed rate loan on 200,000 with a month payment of 1433.39" do
    # setup do
    #   @rate = Rate.new(0.0375, :apr, :duration => 30.years)
    #   @principal = D(200000)
    #   @std = Amortization.new(@principal, @rate)
    # end

    should "have a annual percetage rate of 7.75" do
    	res = Finance::EffectiveInterestRate.calc_effective_interest_rate(360, -1433.39, 200000)
      assert_equal res * 12, 7.754091459155666
    end

    should "have a payment of 1411.01" do
    	res = Finance::EffectiveInterestRate.calc_payment(200000, 0.0750, 360)
    	assert_equal res, -1398.4290171055532
    	res = Finance::EffectiveInterestRate.calc_payment(200000, 0.0750, 360, 60)
    	assert_equal res, -1411.0148782595031
    end
    
  end
end

