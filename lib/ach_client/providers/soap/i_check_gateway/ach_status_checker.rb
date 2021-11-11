module AchClient
  class ICheckGateway
    # Poll ICheckGateway for status of processed or processing Ach transactions.
    class AchStatusChecker < Abstract::AchStatusChecker

      # These responses aren't documented anywhere, so we have to add them as
      #   they are discovered
      KNOWN_ERROR_STRINGS = [
        # ICheckGateway has a rate limit of 20 requests per calendar day
        "ACCESS DENIED: Report Call Limit Exceeded",
        # The date range can't be wider than 15 days
        "ACCESS DENIED: Date Range Exceeds 15 Days",
        # Because so far they all contain ACCESS_DENIED:
        "ACCESS DENIED"
      ]

      EMPTY_RETURNS_RESPONSE = 'NO RETURNS REPORTED'.freeze

      ##
      # ICheckGateway does not support this
      def self.most_recent
        # In the future, this might just return the last 24 hours or something
        raise 'ICheckGateway does not have a most_recent bucket'
      end

      # If there are any strings we know are errors in the response, raise an
      #   error
      # Unfortunately the API doesn't really use HTTP status codes, so we have
      #   to resort to this string/pattern matching to find out if something
      #   went wrong.
      def self.check_for_errors(record)
        KNOWN_ERROR_STRINGS.each do |error_string|
          if record.include?(error_string)
            raise "Couldnt process ICheckGateway Response: #{record}"
          end
        end
      end

      # @return Hash{String => [AchClient::AchResponse]} Hash with
      # confirmation number as the key, lists of AchResponse objects as values
      def self.in_range(start_date:, end_date:)
        Helpers::Utils.hashlist_merge(
          check_for_late_returns(start_date: start_date, end_date: end_date) +
            pull_transaction_report(start_date: start_date, end_date: end_date)
        )
      end

      # @return [Hash{String => [AchClient::AchResponse]}] List of hashes with
      # confirmation number as the key, lists of AchResponse objects as values
      private_class_method def self.pull_transaction_report(start_date:, end_date:)
        AchClient::ICheckGateway.wrap_request(
          method: :pull_transaction_report,
          message: AchClient::ICheckGateway::CompanyInfo.build.to_hash.merge({
            startDate: start_date,
            endDate: end_date
          })
        ).split("\n").select do |record|
          check_for_errors(record)
          # Only the records that start with ICHECK are ACH transactions.
          # Everything else is other types of transactions such as credit card swipes which are outside
          # the scope of this library
          record.start_with?('ICHECK')
        end.map do |record|
          # The 4th column is the external_ach_id which becomes the hash key
          {
            record.split('|')[3] =>
              [
                AchClient::ICheckGateway::ResponseRecordProcessor
                  .process_response_record(record)
              ]
          }
        end
      end

      # The pull_transaction_report method returns ACHs by effective entry date, which won't necessarily include
      #   any late returns that were returned outside the window of pending ACHs.
      # This uses a separate endpoint which gives back returned ACHs by the return date, which will include late
      #  returns
      # @return [Hash{String => [AchClient::AchResponse]}] List of hashes with
      # confirmation number as the key, lists of AchResponse objects as values
      private_class_method def self.check_for_late_returns(start_date:, end_date:)
        (start_date..end_date).map do |date|
          AchClient::ICheckGateway.wrap_request(
            method: :pull_returned_checks,
            message: AchClient::ICheckGateway::CompanyInfo.build.to_hash.merge({
              ReturnedDate: date
            })
          ).split("\n").map do |record|
            if record.include?("|")
              # Each record returned by the API is a pipe separated list with 2 columns:
              # Example: external_ach_id|R01\r\n
              external_ach_id, return_code = record.split('|')
              {external_ach_id => [AchClient::ReturnedAchResponse.new(
                amount: nil, # response does not include amount
                date: date,
                return_code: AchClient::ReturnCodes.find_by(code: return_code)
              )]}
            elsif record.include?(EMPTY_RETURNS_RESPONSE)
              # Server returns an error message instead of an empty list, so we catch the error message and return our
              #  own empty response
              {}
            else
              raise "Couldnt process ICheckGateway Late Returns Response: #{record}"
            end
          end
        end.reduce(&:+)
      end
    end
  end
end
