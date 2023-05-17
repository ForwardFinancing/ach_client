module AchClient
  # Represents an Ach Return code. Consult NACHA documentation for a full list
  # See config/return_codes.yml for our list.
  class ReturnCode

    # The first character in a correction code
    CORRECTION_START_CHARACTER = 'C'

    # The first character in an internal return code
    INTERNAL_START_CHARACTER = 'X'

    # Returns that are both internal and corrections start with this string
    INTERNAL_CORRECTION_STRING = 'XZ'

    attr_accessor :code,
                  :description,
                  :reason,
                  :risk_and_enforcement_category

    # Constructs a Ach return code
    # @param code [String] the 3 char code identifier (ie 'R01')
    # @param description [String] full explanation of the return
    # @param reason [String] shorter explanation of the return
    def initialize(code:, description:, reason: nil, risk_and_enforcement_category: nil)
      @code = code
      @description = description
      @reason = reason
      # See https://www.nacha.org/rules/ach-network-risk-and-enforcement-topics
      @risk_and_enforcement_category = risk_and_enforcement_category
    end

    # @return Whether or not this return is a correction/notice of change
    def correction?
      @code.start_with?(CORRECTION_START_CHARACTER) || @code.start_with?(INTERNAL_CORRECTION_STRING)
    end

    # @return Whether or not the return is internal
    # An "internal" return means that the ACH provider knew that the ACH
    #   would fail and didn't bother to send it to their upstream provider
    def internal?
      @code.start_with?(INTERNAL_START_CHARACTER)
    end

    def administrative_return?
      @risk_and_enforcement_category == "administrative"
    end

    def unauthorized_return?
      @risk_and_enforcement_category == "unauthorized"
    end
  end
end
