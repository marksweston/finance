require_relative '../lib/finance/interval.rb'

require 'minitest/unit'
require 'shoulda'

class TestInterval < Test::Unit::TestCase
  context "a time interval" do
    context "can be created from an integer" do
      should "convert an integer into months" do
        assert_equal 360, 360.months
      end

      should "convert an integer into years" do
        assert_equal 360, 30.years
      end
    end
  end
end
