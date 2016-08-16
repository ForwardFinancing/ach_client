module AchClient
  class AchWorks
    ##
    # Transforms between AchClient class and the strings that AchWorks expects
    # For example, the TransactionType classes are serialized as 'C' or 'D'
    class AchWorksTransformer

      ##
      # Convert AchWorks string representation to AchClient class
      # =>  representation
      # @param string [String] string to turn into class
      # @return [Class] for example AccountTypes::Checking or
      # AccountTypes::Savings
      def self.string_to_class(string)
        self.string_to_class_map[string] or raise(
          "Unknown #{self} string #{string}"
        )
      end

      ##
      # Convert AchClient class to string representation used byAchWorks
      # @param type [Class] the type to convert to a string
      # @return [String] string serialization of the input class
      def self.class_to_string(type)
        self.string_to_class_map.invert[type] or raise(
          "type must be one of #{self.string_to_class_map.values.join(', ')}"
        )
      end

      # Mapping of classes to strings, to be overridden
      # @return [Hash {String => Class}] the mapping
      def self.string_to_class_map
        raise AbstractMethodError
      end
    end
  end
end
