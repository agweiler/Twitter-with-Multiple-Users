class CreateTwitterUsers < ActiveRecord::Migration
  def change
    create_table :twitter_users do |t|
      t.string :oauth_token
      t.string :oauth_verifier
      t.string :screen_name
    end
  end
end
