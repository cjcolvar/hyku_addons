# frozen_string_literal: true
require 'hyrax/doi/errors'

module HykuAddons
  module DOIControllerBehavior
    extend ActiveSupport::Concern
    included do
      def autofill
        respond_to do |format|
          # TODO: Make this respond to json instead of js
          format.js { render json: json_response, status: :ok }

          if Rails.env.development?
            format.html { render json: json_response, status: :ok }

            # NOTE: Use this to see the raw XML returned, useful for creating fixtures for specs
            # http://repo.lvh.me:3000/doi/autofill.xml?curation_concern=generic_work&doi=10.7554/elife.63646
            format.xml { render xml: raw_response.string, status: :ok }
          end
        end

      rescue ::Hyrax::DOI::NotFoundError => e
        respond_to do |format|
          format.js { render plain: e.message, status: :internal_server_error }
        end
      end

      protected

        def json_response
          { data: formatted_work, curation_concern: curation_concern }.to_json
        end

        def formatted_work
          meta = raw_response

          raise ::Hyrax::DOI::NotFoundError, "DOI (#{doi}) could not be found." if meta.blank? || meta.doi.blank?

          meta.hyku_addons_work_form_fields
        end

        def raw_response
          Bolognese::Metadata.new(input: doi)
        end

        def curation_concern
          params.require(:curation_concern)
        end

        def doi
          params.require(:doi)
        end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
