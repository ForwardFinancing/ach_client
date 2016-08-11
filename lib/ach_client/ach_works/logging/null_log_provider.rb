module AchClient
  class AchWorks
    class Logging

      # A log provider that does nothing.
      class NullLogProvider < LogProvider

        # Does absolutely nothing with the log info
        def self.send_logs(*)
          # Do nothing
          nil
        end
      end
    end
  end
end
