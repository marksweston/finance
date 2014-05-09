require 'minitest/autorun'
require 'minitest/spec'

require 'active_support/all'

require 'flt'
require 'flt/d'

require_relative '../lib/finance/config.rb'
require_relative '../lib/finance/amortization.rb'
require_relative '../lib/finance/cashflows.rb'
require_relative '../lib/finance/rates.rb'
require_relative '../lib/finance/transaction.rb'
include Finance
