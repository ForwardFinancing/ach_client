module AchClient
  class AchWorks

    # This is the ACHworks "credentials" for your company
    class InputCompanyInfo

      attr_reader :company_key,
                  :company,
                  :loc_i_d,
                  :s_s_s

      ##
      # @param s_s_s [String] Arbitrary 3 letter code they give your company
      # @param loc_i_d [String] Another Arbitrary 4 letter code they give you...
      # @param company [String] Your user id string, used as a username
      # @param company_key [String] A key that they give you used as a password
      # Since all these fields are generated by them, and don't change, it
      # really seems like they could use just one.
      def initialize(
        company_key:,
        company:,
        loc_i_d:,
        s_s_s:
      )
        @company = company
        @company_key = company_key
        @loc_i_d = loc_i_d
        @s_s_s = s_s_s
      end

      ##
      # @return [InputCompanyInfo] instance built from configuration values
      def self.build
        self.new(
          company_key: AchClient::AchWorks.company_key,
          company: AchClient::AchWorks.company,
          loc_i_d: AchClient::AchWorks.loc_i_d,
          s_s_s: AchClient::AchWorks.s_s_s
        )
      end

      # Wraps: http://tstsvr.achworks.com/dnet/achws.asmx?op=ConnectionCheck
      # Checks validity of company info
      # @return whether or not the request was successful
      def connection_valid?
        connection_check_request(method: :connection_check)
      end

      # Wraps: http://tstsvr.achworks.com/dnet/achws.asmx?op=CheckCompanyStatus
      # Checks company status
      # @return whether or not the request was successful
      def company_valid?
        connection_check_request(method: :check_company_status)
      end

      # Calls both company_valid? and connection_valid?
      # Checks the validity of company info
      # @return whether or not the validity check requests were successful
      def valid?
        connection_valid? && company_valid?
      end

      ##
      # Build a hash to send to ACHWorks under the InpCompanyInfo XML path
      # @return [Hash] hash to send to ACHWorks
      def to_hash
        {
          InpCompanyInfo: self.instance_variables.map do |var|
            {
              var.to_s.split('@').last.camelize.to_sym =>
                self.instance_variable_get(var)
            }
          end.reduce(&:merge)
        }
      end

      private
      def connection_check_request(method:)
        AchClient::AchWorks.request(
          method: method,
          message: self.to_hash
        ).body["#{method}_response".to_sym]["#{method}_result".to_sym].include?(
          'SUCCESS'
        )
      end
    end
  end
end
