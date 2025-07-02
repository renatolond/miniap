# frozen_string_literal: true

class ActivityPubClient < Async::REST::Resource
  ENDPOINT = "localhost:3000"
  def inbox_post(body:)
    ActivityPubInbox.post(self.with(path: "/inbox"), body)
  end
end
