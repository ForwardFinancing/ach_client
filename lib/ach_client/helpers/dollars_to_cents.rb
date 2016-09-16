module AchClient
  # Utility classes shared by all providers
  class Helpers

    # Turns dollars into cents
    class DollarsToCents

      # @param dollars [Float | BigDecimal | Fixnum | Integer]
      # @return [Fixnum] cents
      def self.dollars_to_cents(dollars)
        (dollars.to_f.round(2) * 100).to_i
      end
    end
  end
end
