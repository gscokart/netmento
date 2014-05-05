

require 'sinatra'

enable :session

use Rack::Auth::Basic, "Netmento" do |username, password|
  ([username, password] == ['admin', 'admin']) or ([username, password] == ['other', 'other'])
end


get '/' do
  redirect '/netmento'
end

get '/netmento' do
  #TODO understand how env is accessible/defined here, and if it is thread safe
  #"This is the home page = #{env['REMOTE_USER']}"
  haml :home, :format => :html5
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