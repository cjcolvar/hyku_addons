# frozen_string_literal: true
module HykuAddons
  class QualificationLevelService < Hyrax::QaSelectService
    def initialize(_authority_name = nil)
      super('qualification_level')
    end
  end
end
