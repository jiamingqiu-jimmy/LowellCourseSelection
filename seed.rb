require_relative "environment"

DEFAULT_REGISTRIES = [
  {
    name: "1706",
  },
  {
    name: "1707",
  }
]

DEFAULT_REGISTRIES.each do |registry_data|
  puts "Creating #{registry_data[:name]}..."
  Registry.create(registry_data)
end
