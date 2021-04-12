# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificBook`
require 'rails_helper'

RSpec.describe Hyrax::PacificBookPresenter do
  let(:presenter) { described_class.new(solrdoc, nil, nil) }
  let(:work) { Hyrax::PacificBook.new }
  let(:solrdoc) { SolrDocument.new(work.to_solr, nil) }

  let(:additional_properties) do
    [:is_included_in]
  end

  describe 'accessors' do
    it 'defines accessors' do
      additional_properties.each { |property| expect(presenter).to respond_to(property) }
    end
  end
end
