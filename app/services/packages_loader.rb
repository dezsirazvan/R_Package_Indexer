require 'uri'
require 'net/http'
require 'zlib'
require 'stringio'
require 'rubygems/package'

class PackagesLoader
  def self.load(page:, per_page:)
    Rails.cache.fetch("packages-page-#{page}", expires_in: 1.hour) do
      packages_data = extract_packages_data(page, per_page)
      packages = insert_packages(packages_data)
      Package.where(id: packages.pluck('id')).order(:name).map(&:attributes)
    end
  end

  def self.download_packages_list
    url = URI("http://cran.r-project.org/src/contrib/PACKAGES.gz")
    http = Net::HTTP.new(url.host, url.port)
    request = Net::HTTP::Get.new(url)
    response = http.request(request)
    Zlib::GzipReader.new(StringIO.new(response.body)).read
  end

  private

  def self.extract_packages_data(page, per_page)
    packages_list = download_packages_list

    packages_list[((page - 1) * per_page)...(page * per_page)].scan(/Package:\s+(.+?)\nVersion:\s+(.+?)\n/).map do |match|
      {
        name: match[0],
        version: match[1]
      }.merge(extract_package_details(match[0], match[1]))
    end
  end

  def self.extract_package_details(name, version)
    url = URI("http://cran.r-project.org/src/contrib/#{name}_#{version}.tar.gz")
    http = Net::HTTP.new(url.host, url.port)
    request = Net::HTTP::Get.new(url)
    response = http.request(request)

    tar_extract = Gem::Package::TarReader.new(Zlib::GzipReader.new(StringIO.new(response.body)))
    description = nil

    # Find the DESCRIPTION file
    tar_extract.each do |entry|
      if entry.full_name =~ /^.+\/DESCRIPTION$/
        description = entry.read
        break
      end
    end

    tar_extract.close

    data = {}

    # Extract package fields using regular expressions
    data[:title] = description.match(/^Title:\s(.+)$/)&.captures&.first
    data[:date_publication] = DateTime.parse(description.match(/^Date\/Publication:\s(.+)$/)&.captures&.first)
    authors = description.match(/^Author:\s(.+?)(?:\s\[(.+?)\])?(?:,\s(.+?)(?:\s\[(.+?)\])?)*$/)
      &.captures
      &.each_slice(2)
      &.map {|name, role| name }.compact
    data[:authors] = authors.size > 1 ? authors&.join(', ') : authors.join('')
    data[:maintainers] = description.match(/^Maintainer:\s(.+)$/)&.captures&.join(',')
    data[:license] = description.match(/^License:\s(.+)$/)&.captures&.first
    dependencies = description.match(/^Depends:\s(.+)$/)&.captures&.first&.split(',')
    data[:dependencies] = dependencies&.drop(1)&.join(',')
    data[:r_version_needed] = dependencies&.first
  
    data
  end

  def self.insert_packages(packages_data)
    Package.insert_all(packages_data)
  end
end
