require 'minitest/autorun'
require 'minitest/spec'

require 'flt'
require 'flt/d'

require_relative '../lib/finance/amortization.rb'
require_relative '../lib/finance/cashflows.rb'
require_relative '../lib/finance/interval.rb'
require_relative '../lib/finance/rates.rb'
require_relative '../lib/finance/transaction.rb'
include Finance
