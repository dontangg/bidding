require './app'
use Rack::Deflater

if ENV['RACK_ENV'] != 'production'
  map '/assets' do
    run BiddingApp.assets
  end
end

map '/' do
  run BiddingApp
end
