
require 'sinatra/base'
require 'mongo'
include Mongo

class Login < Sinatra::Base

  #TODO understand what the parameter is (it fails if I remove it)
  def initialize(args) 
    super()
    #Is it thread safe ?
    @db = MongoClient.new['local']
  end 
  
end


class Netmento < Sinatra::Base

  def initialize() 
    super()
    #Is it thread safe ?
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
    session[:user] = @db.collection("users").find_one({:userId => params["name"]})
    redirect '/netmento'
  end

  post '/register' do
    haml :login, :layout => nil
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

  
  before do
    #TODO get the real user from ENV
    #session[:user] = @db.collection("users").find_one({:userId => "admin"}) unless session[:user]
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
    @db.collection("users").save(@user)
    #TODO update it in the session
    #TODO find a way to the GET result
    haml :profile, :format => :html5
  end

  
  get '/profile' do
    haml :profile, :format => :html5
  end

  get '/network' do
    haml :network, :format => :html5
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

