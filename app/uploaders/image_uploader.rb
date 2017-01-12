class ImageUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :fog
  process :validate_dimensions
  process resize_to_fit: [500,500]

  def initialize(*)
    super
    self.fog_credentials = {
      :provider           => 'Rackspace',
      :rackspace_username => ENV["RACKSPACE_USERNAME"],
      :rackspace_api_key  => ENV["RACKSPACE_API_KEY"],
      :rackspace_region    => :dfw
    }
    self.fog_directory = 'gournet_dishes'
  end

  def extension_whitelist
    %w(jpg jpeg gif png)
  end

  def content_type_whitelist
    /image\//
  end

  def content_type_blacklist
    ['application/text', 'application/json', 'application/pdf']
  end

  def filename
    "#{secure_token}.#{file.extension}" if original_filename.present?
  end

  version :thumb do
    process resize_to_fill: [150,150]
  end

  version :small_thumb, from_version: :thumb do
    process resize_to_fill: [50,50]
  end

  protected
    def secure_token
      var = :"@#{mounted_as}_secure_token"
      model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
    end
end
