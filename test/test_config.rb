require_relative 'test_helper'

describe "Cashflows" do

  describe "default values" do
    it "should have default values" do
      assert_equal D("1.0"), D(Finance.config.guess.to_s)
      assert_equal D("1.0e-16"), D(Finance.config.eps)
    end
  end

  describe 'overriding defaults' do
    it "should be permanent" do
      Finance.config.guess = 0.25
      Finance.config.eps = '1.0e-9'
      assert_equal 0.25, Finance.config.guess
      assert_equal '1.0e-9', Finance.config.eps
    end
  end

end
