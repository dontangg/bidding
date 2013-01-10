
class BiddingApp < Sinatra::Base
  get '/' do
    slim :index
  end
end

