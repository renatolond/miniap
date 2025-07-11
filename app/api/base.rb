# frozen_string_literal: true

module API
  # The base class for the API, from here we include other routes
  class Base < Grape::API
    format :json

    mount API::WellKnown

    content_type :json, "application/activity+json"
    prefix :api

    rescue_from Grape::Exceptions::ValidationErrors do |e|
      errors = e.errors.map do |key, value|
        { fields: key, errors: value }
      end
      error!({ error: "VALIDATION_ERROR", details: errors, with: Entities::Error }, 400)
    end
    namespace :actors do
      get ":username" do
        username = params[:username]
        error!({ error: "NOT_FOUND", details: [{ fields: %i[resource], errors: ["not found"] }], with: Entities::Error }, 404) unless username == "alice"
        base_url = "http#{"s" if EnvironmentConfig.use_https?}://#{EnvironmentConfig.miniap_core_host}/"
          publicKey = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAzQD6CWMMqSpWbrgVL8ox\ndG9oB9baYqMNT+C3Xbv7pHOocoPeJIFmP16a8GK7D+LHFLlABzSTNBP45ZQWA4GE\nstI/HRPN4HEyYVSiIYdXe3XXoNDmdo5f5vRUAeDwY7X4bNMeAkAPuX6rhX/TAdOD\n+2v1YPxPMwqqVSrNtNIHPe24C5nGO6k+g8ruYna+Wn4u7iJdo1WIBAIFVPzpFine\n6CQki1L9f72a42AJ7ZZ8PzmtLXOLhJSj+1VvG1Maeh3E/Y5syt5wMHNJZvqXkF8w\nsExrTLBVbqy1rFx7MZJckfzWHnQixV0skMQO2c8Hp/txKsP8csyTO7r64E7W2sYP\nBwIDAQAB"
        id = "#{base_url}api/actors/#{username}"
        {
          "@context": [
            "https://www.w3.org/ns/activitystreams",
            "https://w3id.org/security/v1"
          ],

          id:,
          type: "Person",
          preferredUsername: username,
          inbox: "#{base_url}api/inbox",
          following: "#{base_url}api/actors/#{username}/following",
          followers: "#{base_url}api/actors/#{username}/followers",
          name: "#{username}",
          summary: "Hello.",

          publicKey: {
            id: "#{base_url}api/actors/#{username}#main-key",
            owner: "#{base_url}api/actors/#{username}",
            publicKeyPem: File.read("alice_public.pem")
          }
        }
      end
      get ":username/followers" do
        []
      end
      get ":username/following" do
        []
      end
    end

    post :send_hello do
      base_url = "http#{"s" if EnvironmentConfig.use_https?}://#{EnvironmentConfig.miniap_core_host}/"
        username = "alice"
      body = %({"@context": "https://www.w3.org/ns/activitystreams","id": "#{base_url}create-hello-world","type": "Create","actor": "#{base_url}api/actors/#{username}","object": {"id": "#{base_url}hello-world","type": "Note","published": "2025-07-02T11:17:11Z","attributedTo": "#{base_url}api/actors/#{username}","inReplyTo": "http://localhost:3001/@admin/114777388896097652","content": "<p>Hello world</p>","to": "https://www.w3.org/ns/activitystreams#Public"}})
      pp body
      keypair = OpenSSL::PKey::RSA.new(File.read("alice_private.pem"))
      date = Time.now.utc.httpdate
      body_digest = RequestSigner.body_digest(body)
      signed_string = RequestSigner.signed_string("post /inbox", "localhost:3001", date, body_digest)
      signature = RequestSigner.sign(signed_string, keypair)
      extra_headers = {
        Signature: %(keyId="#{base_url}api/actors/#{username}",headers="#{RequestSigner::HEADERS}",signature="#{signature}"),
        Date: date,
        Digest: body_digest,
        "Content-type": "application/activity+json"
      }
      pp extra_headers
      ActivityPubClientHandler.connect(host: "http://localhost:3001", extra_headers:) do |client|
        client.inbox_post(body:)
      end
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
        security_definitions: {},
        security: {},
        consumes: ["application/json"],
        produces: ["application/json"]
    end

    route :any, "*path" do
      error!({ error: "NOT_FOUND", with: Entities::Error }, 404)
    end
  end
end
