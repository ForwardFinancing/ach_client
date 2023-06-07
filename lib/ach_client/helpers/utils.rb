module AchClient
  class Helpers
    class Utils
      # Given a list of hashes where the hashes values are lists, merge the
      #   list of hashes by appending the two lists when there is a key
      #   collision
      # @param hashlist [Array(Hash{String => Array})]
      def self.hashlist_merge(hashlist)
        hashlist.reduce do |map, record|
          map.merge(record) do |_key, left_value, right_value|
            left_value + right_value
          end
        end
      end

      def self.icheck_date_format(date_string)
        return unless date_string
        begin
          Date.strptime(date_string, "%m/%d/%Y")
        rescue Date::Error
          return date_string
        end
      end
    end
  end
end
