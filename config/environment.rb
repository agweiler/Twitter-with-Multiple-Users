# Set up gems listed in the Gemfile.
# See: http://gembundler.com/bundler_setup.html
#      http://stackoverflow.com/questions/7243486/why-do-you-need-require-bundler-setup
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

# Require gems we care about
require 'rubygems'
require 'uri'
require 'pathname'
require 'pg'
require 'active_record'
require 'logger'
require 'sinatra'
require "sinatra/reloader" if development?
require 'erb'
require 'byebug'
require 'twitter'
require 'json'
require "yaml"
require "daybreak"

# Some helper constants for path-centric logic
APP_ROOT = Pathname.new(File.expand_path('../../', __FILE__))

APP_NAME = APP_ROOT.basename.to_s

# Set up the controllers and helpers
Dir[APP_ROOT.join('app', 'controllers', '*.rb')].each { |file| require file }
Dir[APP_ROOT.join('app', 'helpers', '*.rb')].each { |file| require file }

# Set up the database and models
require APP_ROOT.join('config', 'database')

#Twitter app stuff
require File.expand_path(File.dirname(__FILE__) + '/../config/lib/twitter_sign_in')

DATABASE = File.expand_path(File.dirname(__FILE__) + '/../db/signin.db')
TWITTER  = File.expand_path(File.dirname(__FILE__) + "/../config/twitter_oauth.yaml")

ACCOUNT_TO_FOLLOW = "twitterapi"
TwitterSignIn.configure
APP_KEY = YAML.load_file(TWITTER)

configure do
  enable :sessions
  set :session_secret, 'this is super secret, unless you read this file'
end


helpers do
  def user_logged
    user = nil
    if session[:user]
      db = Daybreak::DB.new DATABASE
      user = db[session[:user]]
      db.close
    end
    user
  end
end