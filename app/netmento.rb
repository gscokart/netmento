

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

get '/netmento/:user' do
  "Welcome #{params['user']}"
end

class Stream
  def each
    100.times { |i| yield "tt=#{i}\n" }
  end
end

get('/t') { Stream.new }