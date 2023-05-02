namespace :packages do
  desc 'Update packages list'
  task :update => :environment do
    require 'open-uri'
    
    packages_url = 'https://example.com/packages'
    packages_path = Rails.root.join('public', 'packages.json')
    
    # Download the latest packages list
    packages_data = open(packages_url).read
    
    # Write the packages list to a file
    File.write(packages_path, packages_data)
    
    puts "Packages list updated at #{Time.now}"
  end
end
