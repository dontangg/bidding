require './app'
use Rack::Deflater

if ENV['RACK_ENV'] != 'production'
  map '/assets' do
    run NotesApp.assets
  end
end

map '/' do
  run NotesApp
end
