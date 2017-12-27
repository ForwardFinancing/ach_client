module AchClient
  class Abstract

    # Interface for polling provider for ACH status responses
    class AchStatusChecker
      # Wrapper for a provider's "most recent bucket"
      # @return [Hash{String => [AchClient::AchResponse]}] Hash with provider's
      #   external ACH id as the key, list of AchResponse objects as values
      def self.most_recent
        raise AbstractMethodError
      end

      # Wrapper for a providers range response endpoint
      # @return [Hash{String => [AchClient::AchResponse]}] Hash with provider's
      #   external ACH id as the key, list of AchResponse objects as values
      def self.in_range(*)
        raise AbstractMethodError
      end
    end
  end
end
