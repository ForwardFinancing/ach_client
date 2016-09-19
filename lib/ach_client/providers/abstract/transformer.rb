module AchClient
  ##
  # Transforms between client class and the strings that the provider expects
  # For example, the TransactionType classes are serialized as 'C' or 'D' for
  # AchWorks
  class Transformer

    ##
    # Convert provider's string representation to AchClient class
    #   representation
    # @param string [String] string to turn into class
    # @return [Class] for example AchClient::AccountTypes::Checking or
    # AchClient::AccountTypes::Savings
    def self.deserialize_provider_value(string)
      self.transformer[string] or raise(
        "Unknown #{self} string #{string}"
      )
    end

    ##
    # Convert client class to string representation used by provider
    # @param type [Class] the type to convert to a string
    # @return [String] string serialization of the input class
    def self.serialize_to_provider_value(type)
      self.transformer.find do |_, v|
        type <= v
      end.try(:first) or raise(
        "type must be one of #{self.transformer.values.join(', ')}"
      )
    end

    # Mapping of classes to strings, to be overridden
    # @return [Hash {String => Class}] the mapping
    def self.transformer
      raise AbstractMethodError
    end
  end
end
