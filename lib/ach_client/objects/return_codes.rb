module AchClient
  # Finding and listing all Ach return codes
  class ReturnCodes

    # The path to the file where the return codes are enumerated
    RETURN_CODES_YAML = '../../../config/return_codes.yml'

    class_attribute :_return_codes

    # @return [Array<AchClient::ReturnCode>] A list of all return codes.
    def self.all
      self._return_codes ||= YAML.load_file(
        File.expand_path(File.join(File.dirname(__FILE__), RETURN_CODES_YAML))
      ).map do |code|
        ReturnCode.new(
          code: code['code'],
          description: code['description'],
          reason: code['reason']
        )
      end
    end

    # Finds the first ReturnCode with the given code, or raises an exception.
    # @param [String] 3 char code identifier for a return code
    # @param [AchClient::ReturnCode] The ReturnCode object with that code
    def self.find_by(code:)
      self.all.find do |return_code|
        return_code.code == code
      # For some reason || is bad syntax in this context
      end or raise "Could not find return code #{code}"
    end
  end
end
