require 'amortization'
require 'cashflows'
require 'interval'
require 'rates'

# The *Finance* module adheres to the following conventions for
# financial calculations:
#
#  * Positive values represent cash inflows (money received); negative
#    values represent cash outflows (payments).
#  * *principal* represents the outstanding balance of a loan or annuity.
#  * *rate* represents the interest rate _per period_.
module Finance

  # Return the number of periods needed to pay off a loan with the
  # given payment.
  def Finance.nper(payment, rate, principal)
    -(Math.log(1-((principal/payment)*rate))) / Math.log(1+rate)
  end
end
