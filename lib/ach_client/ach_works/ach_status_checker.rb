module AchClient
  class AchWorks
    # Poll AchWorks for status of processed or processing Ach transactions.
    class AchStatusChecker

      ##
      # @param [AchClient::AchWorks::InputCompanyInfo] The company you want to
      # check Ach statuses for
      def initialize(company_info:)
        @company_info = company_info
      end

      ##
      # Gets the most recent "unread" ach statuses from AchWorks.
      # NOT IDEMPOTENT - Once this method is called (successfully or
      # unsuccessfully), AchWorks will never return the same Ach transactions
      # here again.
      # Wraps: http://tstsvr.achworks.com/dnet/achws.asmx?op=GetACHReturns
      # @return [Savon::Response] AchWorks response
      def most_recent
        AchClient::AchWorks.soap_client.call(
          :get_ach_returns,
          message: most_recent_hash
        )
      end

      ##
      # Gets the status of ach transactions between the given dates
      # Can be called many times with the same result
      # Sometimes AchWorks will modify the end date...
      # Wraps: http://tstsvr.achworks.com/dnet/achws.asmx?op=GetACHReturnsHist
      # @param start_date [String] lower bound of date ranged status query
      # @param end_date [String] upper bound of date ranged status query
      # @return [Savon::Response] AchWorks response
      def in_range(start_date:, end_date:)
        AchClient::AchWorks.soap_client.call(
          :get_ach_returns_hist,
          message: in_range_hash(start_date: start_date, end_date: end_date)
        )
      end

      private

      def most_recent_hash
        @company_info.to_hash
      end

      def in_range_hash(start_date:, end_date:)
        @company_info.to_hash.merge({
          ReturnDateFrom: AchClient::AchWorks::DateFormatter.format(start_date),
          ReturnDateTo: AchClient::AchWorks::DateFormatter.format(end_date)
        })
      end
    end
  end
end
