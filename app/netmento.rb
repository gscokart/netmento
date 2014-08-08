
require 'sinatra/base'
require 'mongo'
include Mongo

class Login < Sinatra::Base

  def initialize(app) 
    super(app)
    #TODO Is it thread safe ?
    @db = MongoClient.new['local']
  end 

  configure :production do
    enable :logging
    #TODO: how to make that cluster safe?
    use Rack::Session::Pool, :expire_after => 2592000
  end

  configure :development do
    enable :logging
    enable :sessions
    set :session_secret => 'TODO: Use an external secret'
  end
  

  def logged_in?
    session[:user]!=nil
  end

  get '/login' do
    haml :login, :layout => nil
  end

  post '/login' do
    #TODO Check password
    #TODO Move the lookup into its own DAO/business layer
    session[:user] = @db.collection("users").find_one({:userId => params["name"]})
    redirect '/netmento'
  end

  post '/register' do
    #TODO store hash of the password
    #TODO check user identity using an email
    #TODO Use captcha
    @db.collection("users").save({:userId => params["name"], :password => params['password']})
    #TODO: Call the login logic
    session[:user] = @db.collection("users").find_one({:userId => params["name"]})
    redirect '/profile'
  end
  
  get '/logout' do
    session.clear
    redirect '/login'
  end
  
  get(//) do
    pass if logged_in?
    redirect '/login'
  end

  post(//) do
    pass if logged_in?
    redirect '/login'
  end
  
end


class Netmento < Sinatra::Base

  def initialize() 
    super()
    @db = MongoClient.new['local']
  end 
  
  before do
    @user = session[:user]
  end
  
  get '/' do
    redirect '/netmento'
  end    
  
  get '/netmento' do
    haml :home, :format => :html5
  end

  post '/profile' do
    @user["name"] = params[:name]
    @user["email"] = params[:email]
    @db.collection("users").save(@user)
    #TODO update it in the session
    #TODO find a way to the GET result
    haml :profile, :format => :html5
  end

  
  get '/profile' do
    haml :profile, :format => :html5
  end

  get '/network' do
    #TODO remove duplication between the get and the post
    trusted = @db.collection("users").find({"_id" => {"$in" => @user["trust"]}})
    trusting = @db.collection("users").find({"trust" => {"$elemMatch" => { "$eq" => @user["_id"]}}})
    haml :network, :format => :html5, :locals => { :found => nil , :trusted => trusted , :trusting => trusting}
  end
  
  post '/network' do
    trusted = @db.collection("users").find({"_id" => {"$in" => @user["trust"]}})
    trusting = @db.collection("users").find({"trust" => {"$elemMatch" => @user["_id"]}})
    found = @db.collection("users").find({:name => params["name"]})
    haml :network, :format => :html5, :locals => { :found => found , :trusted => trusted , :trusting => trusting}
  end
  
  post '/trust' do
    trust = (@user["trust"] or []).push(BSON::ObjectId.from_string(params['_id']))
    @user["trust"] = trust
    @db.collection("users").save(@user)
    #TODO Move this to a separated class
    #TODO Make sure we don't add 2 time the same person
    #TODO Make sure we don't add ourself
    redirect back
  end

  get '/knowledgeArea' do
    haml :knowledgeArea, :format => :html5
  end

  get '/share' do
    haml :share, :format => :html5
  end
  
  # start the server if ruby file executed directly
  run! if app_file == $0
  
end

