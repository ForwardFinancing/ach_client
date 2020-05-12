module AchClient
  class ICheckGateway
    # ICheckGateway sometimes returns an API error when a valid ACH transaction is sent in a handful of
    #   rejection scenarios. This is unusual because most providers will accept the transaction, return an
    #   external_ach_id, and then supply the rejection info when you poll for responses at a later date.
    # So far we have observed this happening in the following scenarios:
    #   - When an invalid routing number is supplied (X13 - Invalid ACH Routing Number - Entry contains a Receiving DFI
    #       Identification or Gateway Identification that is not a valid ACH routing number.)
    #   - When there is a Notice of Change for the account number (C01 - ACH Change Code. Incorrect Account Number)
    #   - When there is a Notice of Change for the routing number (C02 - ACH Change Code. Incorrect Transit Route)
    # This exception can be caught to handle the API error in the appropriate manner.
    # The NACHA return code inferred from the error message is retrievable from the exception instance as well as any
    #   addendum information provided by the API error (ie the correct new account/routing number)
    class InstantRejectionError < RuntimeError
      attr_reader :ach_response

      def initialize(message = nil, nacha_return_code:, addendum: nil, transaction:)
        super(message)
        return_code = ReturnCodes.find_by(code: nacha_return_code)
        response_args = {
          amount: transaction.amount,
          date: transaction.effective_entry_date,
          return_code: return_code,
        }
        @ach_response = if return_code.correction?
          CorrectedAchResponse.new(**response_args, corrections: addendum)
        else
          ReturnedAchResponse.new(**response_args)
        end
      end
    end
  end
end
