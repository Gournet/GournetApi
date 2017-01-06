require 'carrierwave/orm/activerecord'

CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider           => 'Rackspace',
    :rackspace_username => ENV["RACKSPACE_USERNAME"],
    :rackspace_api_key  => ENV["RACKSPACE_API_KEY"],
    :rackspace_region    => :dfw
  }
  config.fog_directory = 'gournet_profile_images'
end
module CarrierWave
  module MiniMagick
    # check for images that are larger than you probably want
    def validate_dimensions
      manipulate! do |img|
        if img.dimensions.any?{|i| i > 8000 }
          raise CarrierWave::ProcessingError, "dimensions too large"
        end
        img
      end
    end
  end
end
