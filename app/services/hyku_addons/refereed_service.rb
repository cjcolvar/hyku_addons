# frozen_string_literal: true
module HykuAddons
  class RefereedService < Hyrax::QaSelectService
    def initialize(_authority_name = nil)
      super('refereed')
    end
  end
end
