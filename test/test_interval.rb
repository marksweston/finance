require_relative '../lib/finance/interval.rb'

require 'minitest/autorun'
require 'minitest/spec'

describe "Interval" do
  describe "a time interval" do
    describe "can be created from an integer" do
      it "should convert an integer into months" do
        assert_equal 360, 360.months
      end

      it "should convert an integer into years" do
        assert_equal 360, 30.years
      end
    end
  end
end
