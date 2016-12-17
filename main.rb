require 'slack-ruby-client'
class AirDevBrake
  def initialize(dev, air)
    @@dev, @@air = dev, air

    Slack.configure do |config|
      config.token = "SLACK_BOT_TOKEN"
    end
    @@client = Slack::Web::Client.new
    @@dev_user, @@air_user = @@dev.first, @@air.first
    @@first_user = 1
    get_user_on_channel(@@air_user, @@dev_user)
end

def get_user_on_channel(air, dev)
  airbrake_user = air
  devsupport_user = dev

  call_api_slack(airbrake_user, devsupport_user)
end

def post_slack_tags(dev, air)
  @@client.chat_postMessage(channel: '#airbrake', text: "#{air}, You're on Airbrake today.", as_user: true, parse: true, link_names: true)

  @@client.chat_postMessage(channel: '#devsupport', text: "#{dev}, You're on Dev-support today.", as_user: true, parse: true, link_names: true)
end

def check_days
  if Time.now.strftime("%A").downcase == "sunday" || Time.now.strftime("%A").downcase == "saturday"
    return true
  else
    return false
  end
end

def set_next_user
  airbrake = @@air[@@first_user]
  devsupport = @@dev[@@first_user]
  @@first_user +=1
  if @@first_user > 7
    @@first_user = 0
  end

  return [airbrake, devsupport]
end

def call_api_slack(airbrake, devsupport)
  airbrake, devsupport = airbrake, devsupport

  if check_days
    sleep(86400)
    get_user_on_channel(airbrake, devsupport)
  else
    post_slack_tags(devsupport.capitalize, airbrake.capitalize)
    next_user = set_next_user
    sleep(86400)
    get_user_on_channel(next_user[0], next_user[1])
  end
end

end


dev=[
  '@lee',
  '@richard ',
  '@jacob',
  '@karen',
  '@sarah',
  '@rich',
  '@bob',
  '@john'
]

air=[
  '@john',
  '@bob',
  '@rich',
  '@sarah',
  '@karen',
  '@jacob',
  '@richard',
  '@lee'
]

AirDevBrake.new(dev, air)
