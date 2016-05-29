# name: slack
# about: Post new topics etc to slack
# version: 0.0.1
# authors: Victoria Fierce <tdfischer@hackerbots.net>

require 'json'
require 'net/http'
require 'pp'

SLACK_HOOK_URL ||= ENV['SLACK_HOOK_URL'].freeze

DiscourseEvent.on(:post_created) do |post|
  attachment_data = {
    :fallback => "New in #{post.topic.category.name}: #{post.topic.title}",
    :color => "#" + post.topic.category.color,
    :author => {
      :author_name => post.user.readable_name,
      :author_icon => post.user.small_avatar_url
    },
    :title => "New post in #{post.topic.title}",
    :title_link => post.full_url,
    :text => post.raw,
    :footer => post.topic.category.name,
  }
  data = {:username => "Discourse", :icon_emoji => ":oob:", :attachments => [attachment_data]}
  slack_uri = URI(SLACK_HOOK_URL)
  Net::HTTP::post_form(slack_uri, 'payload' => ActiveSupport::JSON.encode(data))
  Rails.logger.info("Sending new post to slack.")
end
