# frozen_string_literal: true
module HykuAddons
  class FunderService < Hyrax::QaSelectService
    def initialize(_authority_name = nil)
      super('funder')
    end
  end
end