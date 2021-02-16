# frozen_string_literal: true
# Customer organization account
module HykuAddons
  module AccountBehavior
    extend ActiveSupport::Concern
    include ActiveModel::Validations
    included do
      belongs_to :datacite_endpoint, dependent: :delete
      has_many :children, class_name: "Account", foreign_key: "parent_id", dependent: :destroy, inverse_of: :parent
      belongs_to :parent, class_name: "Account", inverse_of: :parent, foreign_key: "parent_id", optional: true

      store_accessor :data, :is_parent
      store_accessor :settings, :contact_email, :weekly_email_list, :monthly_email_list, :yearly_email_list,
                     :google_scholarly_work_types,
                     :enabled_doi, :gtm_id, :add_collection_list_form_display, :hide_form_relationship_tab, :shared_login,
                     :email_format, :work_unwanted_fields,
                     :metadata_labels,
                     :institutional_relationship_picklist, :institutional_relationship, :contributor_roles,
                     :creator_roles, :licence_list, :allow_signup, :redirect_on, :oai_admin_email,
                     :file_size_limit, :enable_oai_metadata, :oai_prefix, :oai_sample_identifier

      accepts_nested_attributes_for :datacite_endpoint, update_only: true
      after_initialize :set_jsonb_work_unwanted_fields_default_keys
      after_initialize :set_jsonb_metadata_labels_default_keys, :set_jsonb_licence_list_default_keys
      after_initialize :set_jsonb_allow_signup_default
      before_save :remove_settings_hash_key_with_nil_value
      validates :gtm_id, format: { with: /GTM-[A-Z0-9]{4,7}/, message: "Invalid GTM ID" }, allow_blank: true
      validates :contact_email, :oai_admin_email,
                format: { with: URI::MailTo::EMAIL_REGEXP },
                allow_blank: true
      validate :validate_email_format, :validate_contact_emails
    end

    def datacite_endpoint
      super || NilDataCiteEndpoint.new
    end

    private

      def validate_email_format
        return unless settings['email_format'].present?
        settings['email_format'].each do |email|
          errors.add(:email_format) unless email.match?(/@\S*\.\S*/)
        end
      end

      def validate_contact_emails
        ['weekly_email_list', 'monthly_email_list', 'yearly_email_list'].each do |key|
          next unless settings[key].present?
          settings[key].each do |email|
            errors.add(:"#{key}") unless email.match?(URI::MailTo::EMAIL_REGEXP)
          end
        end
      end

      def set_jsonb_work_unwanted_fields_default_keys
        return if settings['work_unwanted_fields'].present?
        self.work_unwanted_fields = {
          book_chapter: nil, article: nil, news_clipping: nil
        }
      end

      def set_jsonb_metadata_labels_default_keys
        return if settings['metadata_labels'].present?
        self.metadata_labels = {
          institutional_relationship: nil, family_name: nil, given_name: nil,
          org_unit: nil, version_number: nil
        }
      end

      def set_jsonb_licence_list_default_keys
        return if settings['licence_list'].present?
        self.licence_list = {
          name: nil, value: nil
        }
      end

      def set_jsonb_allow_signup_default
        return if settings['allow_signup'].present?
        self.allow_signup = 'true'
      end

      def remove_settings_hash_key_with_nil_value
        ['work_unwanted_fields', 'metadata_labels'].each do |key|
          settings[key].delete_if { |_hash_key, value| value.blank? } if settings[key].class == Hash
        end
      end
  end
end
