require 'finance/decimal'
require 'finance/cashflows'

# The *Finance* module adheres to the following conventions for
# financial calculations:
#
#  * Positive values represent cash inflows (money received); negative
#    values represent cash outflows (payments).
#  * *principal* represents the outstanding balance of a loan or annuity.
#  * *rate* represents the interest rate _per period_.
module Finance
  require 'finance/amortization'
  require 'finance/rates'
  require 'finance/transaction'
end
