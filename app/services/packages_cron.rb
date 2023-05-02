class PackagesCron
  def self.call
    Rails.cache.clear
    Package.destroy_all
    packages_list = PackagesLoader.download_packages_list
    number_of_packages = packages_list.size
    per_page = 1000
    total_pages = (number_of_packages / per_page.to_f).ceil

    (1..total_pages).each do |page|
      packages = PackagesLoader.load(page: page, per_page: per_page)
      puts "Loaded #{packages.size} packages from page #{page} of #{total_pages}"
    end
  end
end