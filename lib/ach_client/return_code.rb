module AchClient
  # Represents an Ach Return code. Consult NACHA documentation for a full list
  # See config/return_codes.yml for our list.
  class ReturnCode

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
  end
end
