# encoding: utf-8
require 'sinatra'

require './clues'

enable :sessions
set :session_secret, ENV['SESSION_SECRET']

get '/' do

end

post '/msg' do
  clue = Clue.new(session)
  clue.talk(params).text
end
