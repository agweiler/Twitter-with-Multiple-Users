class TwitterUser < ActiveRecord::Base
  has_many :tweets
  def clientlogin
    $client = Twitter::REST::Client.new do |config|
      byebug
      config.consumer_key        = APP_KEY[:consumer_key]
      config.consumer_secret     = APP_KEY[:consumer_secret]
      config.access_token        = self.oauth_token
      config.access_token_secret = self.oauth_verifier
    end
  end
end
