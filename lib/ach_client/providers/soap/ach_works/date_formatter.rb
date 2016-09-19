module AchClient
  class AchWorks
    ##
    # For formatting dates for AchWorks
    class DateFormatter

      ##
      # Formats given date in the manner required by AchWorks
      # The date can be a String or a Date/DateTime.
      # If it is a string it will be given to the DateTime parser
      # Will be formatted like 2016-08-11T09:56:24.35103-04:00
      # @param date [Object] String or Date to format
      # @return [String] formatted datetime
      def self.format(date)
        if date.is_a?(String)
          format_string(date)
        elsif date.respond_to?(:strftime)
          format_date(date)
        else
          raise 'Cannot format date'
        end
      end

      private_class_method def self.format_string(string)
        format_date(DateTime.parse(string))
      end

      private_class_method def self.format_date(date)
        date.strftime('%Y-%m-%dT%H:%M:%S.%5N%:z')
      end
    end
  end
end
