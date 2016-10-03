module AchClient
  # Base concern for providers like SVB and BOA that use NACHA format
  module NachaProvider
    extend ActiveSupport::Concern

    included do
      # @return [String] Immediate Destination ID provided by SVB, refers to SVB
      class_attribute :immediate_destination

      # @return [String] Immediate Destination Name provided by SVB, refers to SVB
      class_attribute :immediate_destination_name

      # @return [String] Immediate Origin ID provided by SVB, refers to you
      class_attribute :immediate_origin

      # @return [String] Immediate Origin Name provided by SVB, refers to you
      class_attribute :immediate_origin_name

      # @return [String] Company Identification provided by SVB, refers to you
      class_attribute :company_identification

      # @return [String] Company Entry Description, whatever that means
      class_attribute :company_entry_description

      # @return [String] originating_dfi_identification refers to your bank?
      # originating_dfi => "Originating Depository Financial Institution"
      class_attribute :originating_dfi_identification
    end
  end
end
