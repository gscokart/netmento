

require 'sinatra'

enable :session
set :public_folder, File.dirname(__FILE__) + '/../static/'


get '/' do
  redirect '/netmento'
end

get '/netmento' do
  "This is the home page"
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