module AchClient
  class Abstract
      # Interface for storing company credentials used with a provider
    class CompanyInfo

      ##
      # @return [CompanyInfo] instance built from configuration values
      def self.build
        raise AbstractMethodError
      end

      ##
      # Build a hash to send to provider
      # @return [Hash] hash to send to provider
      def to_hash
        raise AbstractMethodError
      end

      private_class_method def self.build_from_config(args)
        self.new(
          args.map do |arg|
            {arg => self.to_s.deconstantize.constantize.send(arg)}
          end.reduce(&:merge)
        )
      end
    end
  end
end
