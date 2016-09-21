module AchClient
  class AchWorks
    # Turns the gibberish string that AchWorks gives us for correction returns
    # when possible into meaningful data
    class CorrectionDetailsProcessor

      # Turns the gibberish string that AchWorks gives us for correction returns
      # when possible into meaningful data
      # @param gibberish [String] the string that AchWorks gave you
      # @return [Hash] a key value pairing of corrected attributes and their
      #   values. When possible.
      def self.decipher_correction_details(gibberish)
        # The correction code is the first 3 chars of the gibberish.
        # The meaning of the rest of the giberish depends on the correction
        #   code. These meanings are sometimes enumerated in the AchWorks
        #   documentation.
        self.send(('decipher_' + gibberish[0..2]).to_sym, gibberish)
      end

      ##
      # If it looks like we tried to call a function for an unknown correction
      # code, then return the unhanlded correction data hash
      def self.method_missing(method, *args, &block)
        if method.to_s.start_with?('decipher_')
          if (gibberish = args[0]) && gibberish.is_a?(String)
            self.decipher_unknown(gibberish)
          end
        else
          super
        end
      end

      # CO3: The routing number and the account number were wrong.
      def self.decipher_C03(gibberish)
        {
          routing_number: gibberish[3..11],
          account_number: gibberish[15..31]
        }
      end

      # Discrepency between AchWorks and standard correction codes:
      # AchWorks: The account number and transaction code were wrong.
      # Everyone else: The account number and account type (checking/saving)
      #   were wrong.
      # However, AchWorks indicates that the "transaction code" is only 1
      #   character long within their gibberish string. Their transaction
      #   codes are usually 3 characters, while their account types are one
      #   character. So I will assume that "transaction code" means
      #   "account type".
      # C06: The account number and account type were wrong
      def self.decipher_C06(gibberish)
        {
          account_number: gibberish[3..19],
          account_type:
            AchClient::AchWorks::AccountTypeTransformer.deserialize_provider_value(
              gibberish[23]
            )
        }
      end

      # C07: The account number, routing number, and account type were all
      #   incorrect. You really messed this one up.
      # Same issue as above with Transaction Code => Account Type
      # At least they were consistently discrepent.
      def self.decipher_C07(gibberish)
        {
          routing_number: gibberish[3..11],
          account_number: gibberish[12..28],
          account_type:
            AchClient::AchWorks::AccountTypeTransformer.deserialize_provider_value(
              gibberish[29]
            )
        }
      end

      # The rest of the cases are undocumented. We will expose the raw data
      #   given to us, along with a nice note that explains the situation
      #   while shaming AchWorks.
      def self.decipher_unknown(gibberish)
        {
          unhandled_correction_data: gibberish[3..-1],
          note: 'AchWorks failed to document this correction code, so we ' +
          'can\'t tell you what this data means. You might be able to find ' +
          'out by contacting them. Alternatively, you could check the ' +
          'AchWorks web console, and match your records against theirs to ' +
          'see what changed. Enjoy! Let us know what you find, and maybe we' +
          ' can handle this case in the future.'
        }
      end
    end
  end
end
