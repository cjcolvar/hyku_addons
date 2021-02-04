# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificPresentation`
module Hyrax
  class PacificPresentationPresenter < Hyrax::WorkShowPresenter
    # Adds behaviors for hyrax-doi plugin.
    include Hyrax::DOI::DOIPresenterBehavior
    # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
    include Hyrax::DOI::DataCiteDOIPresenterBehavior
    include ::HykuAddons::GenericWorkPresenterBehavior

    DELEGATED_METHODS = %i[title alt_title resource_type creator contributor abstract
                           date_published pagination is_included_in volume publisher issn additional_links rights_holder license
                           org_unit doi subject keyword refereed add_info].freeze
  end
end
