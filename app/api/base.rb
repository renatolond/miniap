# frozen_string_literal: true

module API
  # The base class for the API, from here we include other routes
  class Base < Grape::API
    format :json

    mount API::WellKnown

    prefix :api

    rescue_from Grape::Exceptions::ValidationErrors do |e|
      errors = e.errors.map do |key, value|
        { fields: key, errors: value }
      end
      error!({ error: "VALIDATION_ERROR", details: errors, with: Entities::Error }, 400)
    end

    rescue_from :all do |e|
      if Environment.test? || Environment.development?
        puts e
        puts e.backtrace
      end
      error!({ error: "INTERNAL_SERVER_ERROR", with: Entities::Error }, 500)
    end

    if Environment.development? || Environment.test?
      add_swagger_documentation \
        mount_path: "/swagger_doc",
        doc_version: "0.0", # Get info from somewhere
        info: {
          title: "MiniAP API",
          description: "This is the API that MiniAP makes available for all apps that will use it.",
          license: "GNU Affero General Public License v3.0",
          license_url: "https://raw.githubusercontent.com/renatolond/miniap/refs/heads/main/LICENSE"
        },
        security_definitions: {
        },
        security: { },
        consumes: ["application/json"],
        produces: ["application/json"]
    end

    route :any, "*path" do
      error!({ error: "NOT_FOUND", with: Entities::Error }, 404)
    end
  end
end
