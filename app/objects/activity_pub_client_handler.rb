# frozen_string_literal: true

module ActivityPubClientHandler
  class << self
    def connect(host:, extra_headers:)
      client = ActivityPubClient.open(host)
      client = client.with(headers: extra_headers)
      Sync do
        yield client
      ensure
        client.close
      end
    end
  end
end
