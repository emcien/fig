require "yaml"
require "fig"

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = "random"
end

def yaml_path(name)
  File.expand_path("../data/#{name}", __FILE__)
end

def yaml_data(name)
  path = yaml_path(name)
  text = File.read(path)
  data = YAML.load(text)
  data
end
