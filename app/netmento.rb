

require 'sinatra/base'
require 'mongo'
include Mongo


class Netmento < Sinatra::Base

  def initialize() 
    super()
    #Is it thread safe ?
    @db = MongoClient.new['local']
  end 
  enable :logging

  #TODO: how to make that cluster safe?
  use Rack::Session::Pool, :expire_after => 2592000
  
  use Rack::Auth::Basic, "Netmento" do |username, password|
    #TODO check the password in mongoDB
    ([username, password] == [username, username]) 
  end

  before do
    #TODO get the real user from ENV
    session[:user] = @db.collection("users").find_one({:userId => "admin"}) unless session[:user]
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
    #TODO find a way to redirect
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

