require 'yaml'

file_path = ARGV[0]
data = YAML.load_file(file_path)

new_dependency = {
  'GrowingAnalytics/TrackerCore' => [
    {
      :path => '../../GrowingAnalytics.podspec'
    }
  ]
}

data['target_definitions'].each do |target_def|
  if target_def['name'] == 'Pods'
    target_def['dependencies'] << new_dependency
    break
  end
end

File.write(file_path, data.to_yaml)
