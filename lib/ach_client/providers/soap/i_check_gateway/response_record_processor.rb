module AchClient
  class ICheckGateway
    ## Transforms ICheckGateway transaction report response records into
    # AchClient::Response objects
    class ResponseRecordProcessor < Abstract::ResponseRecordProcessor

      # The column index with the record status
      STATUS_COLUMN = 1
      # The column index with the record amount ($)
      AMOUNT_COLUMN = 15
      # The column index with the record submission date
      DATE_COLUMN = 17
      # THe string index range within the record status with the return code
      RETURN_CODE_INDEX = 3..5

      ## Transforms ICheckGateway transaction report response records into
      # AchClient::Response objects
      # @param record [String] the | separated record string from ICheckGateway
      # @return [AchClient::AchResponse] our representation of the response
      def self.process_response_record(record)
        # The response record is a | separated list
        record = record.split('|')
        # The first letter in the second column determines the response type
        case record[STATUS_COLUMN].first
        when 'N'
          # N - no, it hasn't settled yet
          AchClient::ProcessingAchResponse.new(
            amount: record[AMOUNT_COLUMN],
            date: record[DATE_COLUMN]
          )
        when 'Y'
          # Y - yes, it has settled
          AchClient::SettledAchResponse.new(
            amount: record[AMOUNT_COLUMN],
            date: record[DATE_COLUMN]
          )
        else
          # If it starts with R, it is probably a return, in which case the
          # column looks like: R (R01)
          # As of now, it looks like there are no corrections from
          # ICheckGateway
          if record[1].start_with?('R')
            AchClient::ReturnedAchResponse.new(
              amount: record[AMOUNT_COLUMN],
              date: record[DATE_COLUMN],
              return_code: AchClient::ReturnCodes.find_by(
                code: record[STATUS_COLUMN][RETURN_CODE_INDEX]
              )
            )
          else
            # If it doesn't start with an R, something that is undocumented is
            # happening, so we raise an error since we need to know about it
            raise "Couldnt process ICheckGateway Response: #{record.join('|')}"
          end
        end
      end
    end
  end
end
