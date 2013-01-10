ENV['RACK_ENV'] ||= 'development'

require 'bundler'
Bundler.require(:default, ENV['RACK_ENV'].to_sym)
require 'sinatra/content_for'

Sinatra::Base.configure do |c|
  c.set :root, File.dirname(__FILE__)
  c.helpers Sinatra::ContentFor

  assets = Sprockets::Environment.new
  assets.append_path 'assets/javascripts'
  assets.append_path 'assets/stylesheets'

  c.set :assets, assets
end

Sinatra::Base.configure :production do |c|
  c.set :static_cache_control, [:public, :max_age => 36000]
end

%w(modules).each do |folder_name|
  Dir[File.expand_path("../#{folder_name}/*.rb", __FILE__)].each {|file| require file}
end

