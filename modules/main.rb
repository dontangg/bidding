
class NotesApp < Sinatra::Base
  get '/' do
    slim :index
  end
end

