module AchClient
  class ICheckGateway
    # ICheckGateway credentials for your company
    class CompanyInfo < Abstract::CompanyInfo
      attr_reader :api_key,
                  :site_i_d,
                  :site_key,
                  :live

      ##
      # @param api_key [String] your ICheckGateway API key
      # @param site_i_d [String] your ICheckGateway SiteID
      # @param site_key [String] your ICheckGateway SiteKey
      # @param live [Boolean] "GatewayLiveMode" value
      def initialize(
        api_key:,
        site_i_d:,
        site_key:,
        live:
      )
        @api_key = api_key
        @site_i_d = site_i_d
        @site_key = site_key
        @live = live
      end

      ##
      # @return [CompanyInfo] instance built from configuration values
      def self.build
        build_from_config([
          :api_key,
          :live,
          :site_i_d,
          :site_key
        ])
      end

      ##
      # Build a hash to send to ICheckGateway
      # @return [Hash] hash to send to ICheckGateway
      def to_hash
        {
          SiteID: @site_i_d,
          SiteKey: @site_key,
          APIKey: @api_key,
          GatewayLiveMode: @live ? '1' : '0'
        }
      end
    end
  end
end
