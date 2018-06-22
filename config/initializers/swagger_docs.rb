Swagger::Docs::Config.register_apis({
  "1.0" => {
    # the extension used for the API
    :api_extension_type => :json,
    # the output location where your .json files are written to
    :api_file_path => "public/docs",
    # the URL base path to your API
    :controller_base_path => '',
    :base_path => ENV['PRODUCTION_URL'],
    # if you want to delete all .json files at each generation
    :clean_directory => true,
  }
})

class Swagger::Docs::Config
  def self.transform_path(path, api_version)
    "docs/#{path}"
  end
end
