# frozen_string_literal: true

module HykuAddons
  module UserBehavior
    extend ActiveSupport::Concern

    included do
      has_one :orcid_identity
    end
  end
end