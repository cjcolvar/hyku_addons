# frozen_string_literal: true
module HykuAddons
  class InstallGenerator < Rails::Generators::Base
    desc <<-EOS
      This generator makes the following changes to Hyku:
        1. Installs and configures hyrax-doi
    EOS

    source_root File.expand_path('templates', __dir__)

    def install_hyrax_doi
      generate 'hyrax:doi:install --datacite'
      # Configure default_url_options
      # Rails.application.routes.default_url_options[:host] = 'lvh.me:3000' ?

      # generate 'hyrax:doi:add_to_work_type GenericWork --datacite'
    end

    def inject_overrides_into_curation_concerns
      insert_into_file(Rails.root.join('app', 'models', 'generic_work.rb'), before: /^  include ::Hyrax::BasicMetadata/) do
        "\n  # HykuAddons initializer will include more modules and then close the work with this include\n  #"
      end
      # Replace hyku override to avoid #doi and #isbn methods
      gsub_file(Rails.root.join('app', 'presenters', 'hyrax', 'generic_work_presenter.rb'), '< Hyku::WorkShowPresenter', '< Hyrax::WorkShowPresenter')
    end

    def copy_controlled_vocabularies
      directory HykuAddons::Engine.root.join("config", "authorities"), Rails.root.join("config", "authorities")
    end

    def inject_javascript
      insert_into_file(Rails.root.join('app', 'assets', 'javascripts', 'application.js'), after: /require hyrax$/) do
        "\n//= require hyku_addons"
      end
    end

    def inject_into_helper
      # rubocop:disable Style/RedundantSelf
      # For some reason I had to use self.destination_root here to get all contexts to work (calling from hyrax app, calling from this engine to test app, rspec tests)
      self.destination_root = Rails.root if self.destination_root.blank? || self.destination_root == HykuAddons::Engine.root.to_s
      helper_file = File.join(self.destination_root, 'app', 'helpers', "hyrax_helper.rb")
      # rubocop:enable Style/RedundantSelf

      insert_into_file helper_file, after: 'include Hyrax::HyraxHelperBehavior' do
        "\n" \
        "  # Helpers provided by hyku_addons plugin.\n" \
        "  include HykuAddons::HelperBehavior"
      end
    end
  end
end
