module AchClient
  class Logging
    # Logs to stdout (using puts)
    class StdoutLogProvider < LogProvider
      # Prints the name and then the body
      # @param body [String] the log body
      # @param name [String] the log name
      def self.send_logs(body:, name:)
        puts name
        puts body
      end
    end
  end
end
