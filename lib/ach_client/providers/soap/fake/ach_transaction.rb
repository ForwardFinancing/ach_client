module AchClient
  class Fake
    class AchTransaction < Abstract::AchTransaction

      # Fake ACH sending just returns the provided external_ach_id to indicate success
      def do_send
        external_ach_id
      end
    end
  end
end
