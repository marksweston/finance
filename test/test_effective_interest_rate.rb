require_relative '../lib/finance/effective_interest_rate.rb'

require 'flt/d'
require 'minitest/unit'
require 'shoulda'

# @see http://tinyurl.com/6zroqvd for detailed calculations for the
#   examples in these unit tests.
class TestEffectiveInterestRate < Test::Unit::TestCase

  context "fixed rate loan on 200,000 over 360 months" do
    [
      [0, -1609.24523388957],
      [60, -1623.72844099457],
      [120, -1638.21164809958],
    ].each do |set|
      should "with fees of #{set[0]} has a payment of #{set[1]}" do
        res = Finance::EffectiveInterestRate.calculate_payment(200000, BigDecimal.new('9.0'), 360, set[0])
        assert_equal BigDecimal.new(set[1].to_s).round(10), res.round(10)
      end
    end

    should "with a payment of $1,439.39 has a annual percetage rate of 7.75" do
      res = Finance::EffectiveInterestRate.calc_effective_interest_rate(360, -1433.39, 200000)
      assert_equal BigDecimal.new(res * 12, 5), BigDecimal.new(7.7540914, 5)
    end

    [
      [-1411.01, BigDecimal.new(0.63264, 5)],
      [-1405.42, BigDecimal.new(0.62925, 5)],
      [-1617.29, BigDecimal.new(0.75465, 5)],
      [-3259.84, BigDecimal.new(1.62500, 5)],
    ].each do |set|
      should "with a payment of #{set[0]} has a monthly percetage rate of #{set[1].to_f}" do
        res = Finance::EffectiveInterestRate.calc_effective_interest_rate(360, set[0], 200000)
        assert_equal set[1], BigDecimal.new(res, 5)
      end
    end

    should "have a nper of 360" do
      assert_equal Finance::EffectiveInterestRate.calc_nper(0.0750/12, -1398.43, 200000), 360
    end

  end
end

