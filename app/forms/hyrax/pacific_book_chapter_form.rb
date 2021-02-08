# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificBookChapter`
module Hyrax
  # Generated form for PacificBookChapter
  class PacificBookChapterForm < Hyrax::Forms::WorkForm
    # Adds behaviors for hyrax-doi plugin.
    include Hyrax::DOI::DOIFormBehavior
    # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
    include Hyrax::DOI::DataCiteDOIFormBehavior
    include ::HykuAddons::WorkForm

    self.model_class = ::PacificBookChapter
    add_terms %i[title alt_title resource_type creator institution contributor abstract
                 date_published book_title pagination is_included_in volume publisher isbn issn additional_links rights_holder license
                 org_unit doi subject keyword refereed add_info]

    self.required_fields = %i[title creator resource_type institution org_unit pagination publisher]

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
        permitted_params << [:alt_title, :book_title, :pagination, :is_included_in,
                             :volume, :publisher, :isbn, :issn, :additional_links,
                             :org_unit, :subject, :keyword, :refereed]
      end
    end
  end
end