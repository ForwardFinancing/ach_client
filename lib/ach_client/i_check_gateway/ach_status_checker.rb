module AchClient
  class ICheckGateway
    # Poll ICheckGateway for status of processed or processing Ach transactions.
    class AchStatusChecker < Abstract::AchStatusChecker
      ##
      # ICheckGateway does not support this
      def self.most_recent
        # In the future, this might just return the last 24 hours or something
        raise 'ICheckGateway does not have a most_recent bucket'
      end

      # Wrapper for the range response endpoint
      # @return [Hash{String => AchClient::AchResponse}] Hash with confirmation
      # number as the key, AchResponse objects as values
      def self.in_range(start_date:, end_date:)
        AchClient::ICheckGateway.wrap_request(
          method: :pull_transaction_report,
          message: AchClient::ICheckGateway::CompanyInfo.build.to_hash.merge({
            startDate: start_date,
            endDate: end_date
          })
        ).split("\n").select do |record|
          # Ignore credit card swipes if there are any
          record.start_with?('ICHECK')
        end.map do |record|
          {
            record.split('|')[3] =>
              AchClient::ICheckGateway::ResponseRecordProcessor
                .process_response_record(record)
          }
        end.reduce(&:merge)
      end
    end
  end
end
