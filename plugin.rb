# name: slack
# about: Post new topics etc to slack
# version: 0.0.1
# authors: Victoria Fierce <tdfischer@hackerbots.net>

require 'json'
require 'net/http'
require 'pp'

enabled_site_setting :slack_enabled

DiscourseEvent.on(:post_created) do |post|
  if SiteSetting.slack_enabled
    if post.post_type == Post.types[:regular]
      attachment_data = {
        :fallback => "#{post.topic.category.name}: #{post.topic.title}",
        :color => "#" + post.topic.category.color,
        :author => {
          :author_name => post.user.readable_name,
          :author_icon => post.user.small_avatar_url
        },
        :title => "New post in #{post.topic.title}",
        :title_link => post.full_url,
        :text => post.raw,
        :footer => post.topic.category.name,
        :mrkdwn_in => ['text']
      }
      data = {:username => "Discourse", :icon_emoji => ":oob:", :attachments => [attachment_data]}
      slack_uri = URI(SiteSetting.slack_webhook_url)
      Net::HTTP::post_form(slack_uri, 'payload' => ActiveSupport::JSON.encode(data))
      Rails.logger.info("Sending new post to slack.")
    end
  end
end
