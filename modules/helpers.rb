
class BiddingApp < Sinatra::Base
  helpers do
    def asset_manifest
      unless @asset_manifest
        manifest_path = File.join(settings.root, '/public/assets')
        @asset_manifest = Sprockets::Manifest.new(settings.assets, manifest_path)
      end

      @asset_manifest
    end

    def stylesheet_include_tag(source)
      source = "#{source}.css" if File.extname(source) == ''

      asset_tag source, "<link href='{0}' rel='stylesheet' />"
    end

    def javascript_include_tag(source)
      source = "#{source}.js" if File.extname(source) == ''

      asset_tag source, "<script src='{0}'></script>"
    end

    def asset_tag(source, template)
      if settings.environment == :production
        template.sub('{0}', "/assets/#{asset_manifest.assets[source]}")
      else
        settings.assets[source].to_a.map { |asset|
          template.sub('{0}', "/assets/#{asset.logical_path}?body=1")
        }.join
      end
    end
  end
end

