# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificMedia`
module Hyrax
  class PacificMediaPresenter < Hyrax::WorkShowPresenter
    # Adds behaviors for hyrax-doi plugin.
    include Hyrax::DOI::DOIPresenterBehavior
    # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
    include Hyrax::DOI::DataCiteDOIPresenterBehavior
    include ::HykuAddons::GenericWorkPresenterBehavior

    DELEGATED_METHODS = %i[title alt_title resource_type creator contributor institution abstract
                           date_published duration version_number is_included_in page_display_order_number
                           publisher additional_links rights_holder license location
                           org_unit official_link subject keyword refereed add_info].freeze
  end
end
