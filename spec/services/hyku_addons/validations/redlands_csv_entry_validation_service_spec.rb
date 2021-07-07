# frozen_string_literal: true
require "rails_helper"

RSpec.describe HykuAddons::Validations::RedlandsEntryValidationService, type: :model do
  let(:entry)   { instance_double(HykuAddons::CsvEntry, status: 'Complete', id: 1, identifier: '123') }
  let(:account) { create(:account, name: 'tenant', cname: 'example.com') }

  let(:service) { described_class.new(account, entry) }

  describe "initialize" do
    context "with valid params" do
      it "returns an instance" do
        expect(service).to be_a(described_class)
      end
    end

    context "with no account" do
      let(:account) { nil }

      it "raise an Argument Error" do
        expect { service }.to raise_error(ArgumentError, "You must pass a valid Account")
      end
    end
  end

  # rubocop:disable RSpec/EmptyExampleGroup
  describe "validate" do
    context "with a correctly imported CSV file" do
      let(:user) { create(:user, email: 'test@example.com') }
      # let! is needed below to ensure that this user is created for file attachment because this is the depositor in the CSV fixtures
      let(:depositor) { create(:user, email: 'batchuser@example.com') }
      let(:importer) do
        create(:bulkrax_importer_csv,
               user: user,
               field_mapping: Bulkrax.field_mappings["HykuAddons::CsvParser"],
               parser_klass: "HykuAddons::CsvParser",
               parser_fields: { 'import_file_path' => import_batch_file },
               limit: 0)
      end
      let(:import_batch_file) { 'spec/fixtures/csv/pacific_articles.metadata.csv' }
    end
    # rubocop:enable RSpec/EmptyExampleGroup
  end

  describe 'filter_out_excluded_fields' do
    let(:metadata) do
      {
        foo: :bar,
        bar: :baz,
        empty_string: "",
        empty_string_array: [""],
        exclude: 'true',
        include: 'true'
      }
    end
    let(:excluded_fields) { [:bar] }
    let(:excluded_fields_with_values) { { exclude: 'true', include: 'false' } }
    let(:result) { service.send(:processable_fields, metadata) }

    before do
      stub_const("HykuAddons::Validations::RedlandsEntryValidationService::EXCLUDED_FIELDS", excluded_fields)
      stub_const("HykuAddons::Validations::RedlandsEntryValidationService::EXCLUDED_FIELDS_WITH_VALUES", excluded_fields_with_values)
    end

    it 'removes the excluded fields from the hash param based on EXCLUDED_FIELDS' do
      expect(result.keys).to include(:foo)
      expect(result.keys).not_to include(:bar)
    end
  end
end