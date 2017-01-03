module AchClient
  class AchWorks
    # Processes individual response records from AchWorks
    class ResponseRecordProcessor < Abstract::ResponseRecordProcessor

      # Find the response code in the response record and delegate to the
      # appropriate handler method
      # @param record [Hash] AchWorks response hash
      # @return [AchClient::AchResponse] response
      def self.process_response_record(record)
        self.send(('process_' + record[:response_code]).to_sym, record)
      end

      ##
      # If it looks like we tried to call a function for an unknown response
      # code, then raise an exception so we know what kind of crazy response
      # codes they are sending us
      def self.method_missing(method, *args, &block)
        if method.to_s.start_with?('process_')
          if (record = args[0]) && record.is_a?(Hash)
            raise "Unknown response code #{record[:response_code]}"
          end
        else
          super
        end
      end

      # 1SNT: The transaction has been sent, but not yet processed
      # @param record [Hash] AchWorks response hash
      # @return [AchClient::ProcessingAchResponse] processing response
      def self.process_1SNT(record)
        AchClient::ProcessingAchResponse.new(
          amount: BigDecimal.new(record[:trans_amount]),
          date: record[:action_date]
        )
      end

      # 2STL: The transaction is settled. Huzzah!
      # @param record [Hash] AchWorks response hash
      # @return [AchClient::SettledAchResponse] settled response
      def self.process_2STL(record)
        AchClient::SettledAchResponse.new(
          amount: BigDecimal.new(record[:trans_amount]),
          date: record[:action_date]
        )
      end

      # 3RET: The transaction was returned for some reason (insufficient
      #   funds, invalid account, etc)
      # @param record [Hash] AchWorks response hash
      # @return [AchClient::ReturnedAchResponse] returned response
      def self.process_3RET(record)
        AchClient::ReturnedAchResponse.new(
          amount: BigDecimal.new(record[:trans_amount]),
          date: record[:action_date],
          return_code: AchClient::ReturnCodes.find_by(
            code: record[:action_detail][0..2]
          )
        )
      end

      # 4INT: AchWorks already knows the transaction would result in a
      #   return, so they didn't bother sending it to the bank.
      # @param record [Hash] AchWorks response hash
      # @return [AchClient::ReturnedAchResponse] returned response
      def self.process_4INT(record)
        self.process_3RET(record)
      end

      # 5COR: Corrected account details (new account number, bank buys
      #   another bank, etc). You are responsible for updating your records,
      #   and making the request with the new info, lest AchWorks will be
      #   most displeased.
      # @param record [Hash] AchWorks response hash
      # @return [AchClient::CorrectedAchResponse] corrected response
      def self.process_5COR(record)
        AchClient::CorrectedAchResponse.new(
          amount: BigDecimal.new(record[:trans_amount]),
          date: record[:action_date],
          return_code: AchClient::ReturnCodes.find_by(
            code: record[:action_detail][0..2]
          ),
          corrections: AchClient::AchWorks::CorrectionDetailsProcessor
            .decipher_correction_details(record[:action_detail])
        )
      end

      # Not pictured: 9BNK
    end
  end
end
