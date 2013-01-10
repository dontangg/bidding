require 'rake'
require 'rake/sprocketstask'
require 'sprockets'

module Sprockets
  module Sinatra
    class Task < Rake::SprocketsTask

      def define
        namespace :assets do
          desc "Compile all the assets"
          task :precompile do
            with_logger do
              manifest.compile(assets)
            end
          end

          desc "Remove old compiled assets"
          task :clean do
            with_logger do
              manifest.clean(keep)
            end
          end

          desc "Remove compiled assets"
          task :clobber do
            with_logger do
              manifest.clobber
            end
          end
        end
      end

    end
  end
end
