# frozen_string_literal: true

module API
  # Routes that respond on the .well-known path
  class WellKnown < Grape::API
    prefix ".well-known"

    params do
      requires :resource, type: String, desc: "The resource you want information about"
    end
    get "webfinger" do
      resource = params[:resource].delete_prefix("acct:")
      username, domain = resource.split("@", 2)
      error!({ error: "NOT_FOUND", details: [{ fields: %i[resource], errors: ["not found"] }], with: Entities::Error }, 404) if domain != EnvironmentConfig.miniap_core_host

      subject = "#{username}@#{EnvironmentConfig.miniap_core_host}"
      href = "http#{"s" if EnvironmentConfig.use_https?}://#{EnvironmentConfig.miniap_core_host}/api/actor/#{username}"
      { subject:, links: [{ rel: "self", type: "application/activity+json", href: }] }
    end
  end
end
