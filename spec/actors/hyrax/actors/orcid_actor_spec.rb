# frozen_string_literal: true

require "rails_helper"

RSpec.describe Hyrax::Actors::OrcidActor do
  subject(:actor) { described_class.new(next_actor) }
  let(:ability) { Ability.new(user) }
  let(:env) { Hyrax::Actors::Environment.new(work, ability, {}) }
  let(:next_actor) { Hyrax::Actors::Terminator.new }
  let(:user) { FactoryBot.build(:base_user, :with_orcid_identity) }
  let(:model_class) { GenericWork }
  let(:work) { model_class.create(work_attributes) }
  let(:work_attributes) do
    {
      "title" => ["Moomin"],
      "creator" => [
        [{
          "creator_given_name" => "Smith",
          "creator_family_name" => "John",
          "creator_name_type" => "Personal",
          "creator_orcid" => orcid_id
        }].to_json
      ]
    }
  end
  let(:orcid_id) { "0000-0003-0652-4625" }

  before do
    allow(Flipflop).to receive(:enabled?).and_call_original
    allow(Flipflop).to receive(:enabled?).with(:orcid_identities).and_return(true)

    ActiveJob::Base.queue_adapter = :test
  end

  describe "#create" do
    context "when orcid_identities is enabled" do
      it "enqueues a job" do
        expect { actor.create(env) }.to have_enqueued_job(Hyrax::Orcid::ProcessWorkJob)
          .with(orcid_id, work)
          .on_queue(Hyrax.config.ingest_queue_name)
      end
    end

    context "when orcid_identities is disabled" do
      before do
        allow(Flipflop).to receive(:enabled?).with(:orcid_identities).and_return(false)
      end

      it "enqueues a job" do
        expect { actor.create(env) }.not_to have_enqueued_job(Hyrax::Orcid::ProcessWorkJob)
      end
    end
  end

  describe "#update" do
    context "when orcid_identities is enabled" do
      it "enqueues a job" do
        expect { actor.update(env) }.to have_enqueued_job(Hyrax::Orcid::ProcessWorkJob)
          .with(orcid_id, work)
          .on_queue(Hyrax.config.ingest_queue_name)
      end
    end

    context "when orcid_identities is disabled" do
      before do
        allow(Flipflop).to receive(:enabled?).with(:orcid_identities).and_return(false)
      end

      it "enqueues a job" do
        expect { actor.update(env) }.not_to have_enqueued_job(Hyrax::Orcid::ProcessWorkJob)
      end
    end
  end
end