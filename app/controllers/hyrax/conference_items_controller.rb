# frozen_string_literal: true

module Hyrax
  class ConferenceItemsController < ::ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::ConferenceItem
    self.show_presenter = Hyrax::ConferenceItemPresenter
  end
end
