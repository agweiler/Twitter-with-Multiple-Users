get '/' do
  erb :index
end

get '/signin' do
  token = TwitterSignIn.request_token
  redirect TwitterSignIn.authenticate_url(token)
end

get '/callback' do
  token = TwitterSignIn.access_token(params["oauth_token"], params["oauth_verifier"])

  if token
    user = TwitterSignIn.verify_credentials(token)
    session[:user] = user["screen_name"]
    session[:info] = {
      :avatar => user["profile_image_url"],
      :name   => user["name"],
      :bio    => user["description"]
    }
    localuser = TwitterUser.find_or_create_by(screen_name: user["screen_name"])
    localuser.update(oauth_token: user["access_token"], oauth_verifier: user["access_token_secret"])
  else
    logger.info "User didn't authorized us"
  end
  @account = ACCOUNT_TO_FOLLOW
  erb :awesome
end

get '/logout' do
  session[:user] = nil
  session[:info] = nil
  erb :index
end

get '/awesome_features' do
  if user_logged.nil?
    erb :forbidden
  else
    @account = ACCOUNT_TO_FOLLOW
    erb :awesome
  end
end

get '/awesome_features/follow' do
  if user_logged.nil?
    erb :forbidden
  else
    db = Daybreak::DB.new DATABASE
    dbtoken = db[session[:user]]
    @oauth = YAML.load_file(TWITTER)
    oauth = @oauth.dup
    oauth[:token] = dbtoken["access_token"]
    oauth[:token_secret] = dbtoken["access_token_secret"]
    response = TwitterSignIn.request(
      :post,
      "https://api.twitter.com/1.1/friendships/create.json",
      {:screen_name => ACCOUNT_TO_FOLLOW},
      oauth
    )
    user = JSON.parse(response.body)
    db.close

    @info = JSON.pretty_generate(user)
    erb :awesome_follow
  end
end

get '/awesome_features/info' do
  if user_logged.nil?
    erb :forbidden
  else
    @info = JSON.pretty_generate(user_logged)
    erb :awesome_info
  end
end

get '/awesome_features/post' do
  if user_logged.nil?
    erb :forbidden
  else
    erb :awesome_post
  end
end

post '/awesome_features/post' do
  localuser = TwitterUser.where(screen_name: session[:user]).first
  localuser.clientlogin
  $client.update(params[:tweet])
  erb :awesome
end