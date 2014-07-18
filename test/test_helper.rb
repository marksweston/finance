require 'minitest/autorun'
require 'minitest/spec'

require 'active_support/all'

require 'flt'
require 'flt/d'

require_relative '../lib/finance/amortization.rb'
require_relative '../lib/finance/rates.rb'
require_relative '../lib/finance/transaction.rb'
require_relative '../lib/finance/calculator/function.rb'
require_relative '../lib/finance/calculator/irr.rb'
require_relative '../lib/finance/calculator/xirr.rb'
require_relative '../lib/finance/calculator/npv.rb'
require_relative '../lib/finance/calculator/xnpv.rb'
include Finance
