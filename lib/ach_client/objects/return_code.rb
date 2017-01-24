module AchClient
  # Represents an Ach Return code. Consult NACHA documentation for a full list
  # See config/return_codes.yml for our list.
  class ReturnCode

    # The first character in a correction code
    CORRECTION_START_CHARACTER = 'C'

    # The first character in an internal return code
    INTERNAL_START_CHARACTER = 'X'

    attr_accessor :code,
                  :description,
                  :reason

    # Constructs a Ach return code
    # @param code [String] the 3 char code identifier (ie 'R01')
    # @param description [String] full explanation of the return
    # @param reason [String] shorter explanation of the return
    def initialize(code:, description:, reason: nil)
      @code = code
      @description = description
      @reason = reason
    end

    # @return Whether or not this return is a correction/notice of change
    def correction?
      @code.start_with?(CORRECTION_START_CHARACTER)
    end

    # @return Whether or not the return is internal
    # An "internal" return means that the ACH provider knew that the ACH
    #   would fail and didn't bother to send it to their upstream provider
    def internal?
      @code.start_with?(INTERNAL_START_CHARACTER)
    end
  end
end
