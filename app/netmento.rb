
require 'sinatra/base'
require 'mongo'
require 'storage'
require 'user'

include Mongo

module Netmento

  class Login < Sinatra::Base

    def initialize(app) 
      super(app)
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
      session[:user] = Storage::Storage.store.find_one(Storage::User,{:userId => params["name"]})
      redirect '/netmento'
    end

    post '/register' do
      #TODO store hash of the password
      #TODO check user identity using an email
      #TODO Use captcha
      user = Storage::User.new
      user.userId = params["name"]
      user.password = params['password']
      Storage::Storage.store.persist(user)
      #TODO: Call the login logic
      session[:user] = user
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
      learnings = @db.collection("learnings").find({"author_id" => {"$in" => @user.trust}})
      #TODO Add sorting
      #TODO remove the one already reviewed
      #=> Plutot que de faire une requete, je devrais pousser les news chez mes follower (genre mailbox)
      #TODO render the post as markdown text
      haml :home, :format => :html5, :locals => { :learnings => learnings}
    end

    post '/profile' do
      @user.name = params[:name]
      @user.email = params[:email]
      Storage::Storage.store.persist(@user)
      #TODO update it in the session
      #TODO find a way to the GET result
      haml :profile, :format => :html5
    end

    
    get '/profile' do
      haml :profile, :format => :html5
    end

    get '/network' do
      #TODO remove duplication between the get and the post
      trusted = @db.collection("users").find({"_id" => {"$in" => @user.trust}})
      trusting = @db.collection("users").find({"trust" => {"$elemMatch" => { "$eq" => @user._id}}})
      haml :network, :format => :html5, :locals => { :found => nil , :trusted => trusted , :trusting => trusting}
    end
    
    post '/network' do
      trusted = @db.collection("users").find({"_id" => {"$in" => @user.trust}})
      print @user._id , " " , @user._id.class , "\n"
      trusting = @db.collection("users").find({"trust" => {"$elemMatch" => { "$eq" => @user._id}}})
      found = @db.collection("users").find({:name => params["name"]})
      haml :network, :format => :html5, :locals => { :found => found , :trusted => trusted , :trusting => trusting}
    end
    
    post '/trust' do
      trust = (@user.trust or []).push(BSON::ObjectId.from_string(params['_id']))
      @user.trust = trust
      Storage::Storage.store.persist(@user)
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
    
    post '/share' do
      # TODO add a timestamp
      # TODO add possibly a tag
      # TODO add possibly a level
      @db.collection("learnings").save({:author_id => @user._id, :author => @user.name, :descr => params['learning']})
      haml :share, :format => :html5
    end
    
    # start the server if ruby file executed directly
    run! if app_file == $0
    
  end

end
