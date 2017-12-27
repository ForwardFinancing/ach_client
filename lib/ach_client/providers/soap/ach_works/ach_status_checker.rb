module AchClient
  class AchWorks
    # Poll AchWorks for status of processed or processing Ach transactions.
    class AchStatusChecker < Abstract::AchStatusChecker
      ##
      # Gets the most recent "unread" ach statuses from AchWorks.
      # NOT IDEMPOTENT - Once this method is called (successfully or
      # unsuccessfully), AchWorks will never return the same Ach transactions
      # here again.
      # Wraps: http://tstsvr.achworks.com/dnet/achws.asmx?op=GetACHReturns
      # @return [Hash{String => AchClient::AchResponse}] Hash with FrontEndTrace
      #   values as keys, AchResponse objects as values
      def self.most_recent
        request_and_process_response(
          method: :get_ach_returns,
          message: most_recent_hash
        )
      end

      ##
      # Gets the status of ach transactions between the given dates
      # Sometimes AchWorks will modify the end date...
      # Wraps: http://tstsvr.achworks.com/dnet/achws.asmx?op=GetACHReturnsHist
      # BEWARE OF LARGE DATE RANGES: AchWorks doesn't appear to cache or even
      # paginate their responses, so if your range has too many responses,
      # something will probably break.
      # @param start_date [String] lower bound of date ranged status query
      # @param end_date [String] upper bound of date ranged status query
      # @return [Hash{String => AchClient::AchResponse}] Hash with FrontEndTrace
      #   values as keys, AchResponse objects as values
      def self.in_range(start_date:, end_date:)
        request_and_process_response(
          method: :get_ach_returns_hist,
          message: in_range_hash(start_date: start_date, end_date: end_date)
        )
      end

      private_class_method def self.request_and_process_response(
        method:,
        message:
      )
        response = AchClient::AchWorks.wrap_request(
          method: method,
          message: message,
          path: ['_response', '_result'].map do |postfix|
            (method.to_s + postfix).to_sym
          end
        )
        if response[:total_num_records] == '0'
          []
        else
          Helpers::Utils.hashlist_merge(
            response[:ach_return_records][:ach_return_record].select do |record|
              # Exclude records with no front end trace
              # They are probably 9BNK response codes, not actual transactions
              # 9BNK is when AchWorks gives us an aggregate record, containing
              #   the total debit/credit to your actual bank account.
              # We don't care about those here.
              record[:front_end_trace].present?
            end.map do |record|
              {
                # Strips the first characther because it is always the added Z
                record[:front_end_trace][1..-1] =>
                  [
                    AchClient::AchWorks::ResponseRecordProcessor
                    .process_response_record(record)
                  ]
              }
            end
          )
        end
      end

      private_class_method def self.company_info
        AchClient::AchWorks::CompanyInfo.build
      end

      private_class_method def self.most_recent_hash
        company_info.to_hash
      end

      private_class_method def self.in_range_hash(start_date:, end_date:)
        company_info.to_hash.merge({
          ReturnDateFrom:
            AchClient::AchWorks::DateFormatter.format(start_date),
          ReturnDateTo: AchClient::AchWorks::DateFormatter.format(end_date)
        })
      end
    end
  end
end
