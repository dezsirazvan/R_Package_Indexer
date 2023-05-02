require 'rails_helper'

RSpec.describe PackagesLoader, type: :service do
  describe '.download_packages_list' do
    it 'returns the packages list' do
      response_body = "Package: foo\nVersion: 1.0\n\nPackage: bar\nVersion: 2.0\n\n"
      stub_request(:get, "http://cran.r-project.org/src/contrib/PACKAGES.gz")
        .to_return(status: 200, body: Zlib.gzip(response_body), headers: {'Content-Encoding' => 'gzip'})
      expect(PackagesLoader.download_packages_list).to eq response_body
    end
  end

  describe '.extract_packages_data' do
    it 'extracts the correct packages data' do
      packages_list = "Package: foo\nVersion: 1.0\n\nPackage: bar\nVersion: 2.0\n\n"
      allow(PackagesLoader).to receive(:download_packages_list).and_return(packages_list)
      expected_data = [
        {
          name: 'foo',
          version: '1.0',
          title: 'Foo Package',
          date_publication: DateTime.parse('2022-01-01'),
          authors: 'John Smith',
          maintainers: 'Jane Doe',
          license: 'MIT',
          dependencies: 'some_package, another_package',
          r_version_needed: '3.5.0'
        },
        {
          name: 'bar',
          version: '2.0',
          title: 'Bar Package',
          date_publication: DateTime.parse('2022-02-01'),
          authors: 'Mary Johnson, Tom Williams',
          maintainers: 'Mary Johnson',
          license: 'GPL-3',
          dependencies: nil,
          r_version_needed: '3.6.0'
        }
      ]
      allow(PackagesLoader).to receive(:extract_package_details).and_return(
        {title: 'Foo Package', date_publication: DateTime.parse('2022-01-01'), authors: 'John Smith', maintainers: 'Jane Doe', license: 'MIT', dependencies: 'some_package, another_package', r_version_needed: '3.5.0'},
        {title: 'Bar Package', date_publication: DateTime.parse('2022-02-01'), authors: 'Mary Johnson, Tom Williams', maintainers: 'Mary Johnson', license: 'GPL-3', dependencies: nil, r_version_needed: '3.6.0'}
      )
      expect(PackagesLoader.extract_packages_data(1, 500)).to eq expected_data
    end
  end

  describe '.extract_package_details' do
    it 'extracts the correct package details' do
      tar_gz_file = Tempfile.new('foo.tar.gz')
      tar_file_path = Rails.root.join('spec', 'fixtures', 'foo_1.0.tar.gz')
      FileUtils.cp(tar_file_path, tar_gz_file.path)
  
      stub_request(:get, "http://cran.r-project.org/src/contrib/foo_1.0.tar.gz")
        .to_return(status: 200, body: File.open(tar_gz_file.path), headers: {'Content-Type' => 'application/x-gzip'})
  
      details = PackagesLoader.extract_package_details('foo', '1.0')
  
      expect(details).to include(
        title: 'Conditional Aalen-Johansen Estimation',
        date_publication: DateTime.parse('Wed, 01 Mar 2023 10:42:09.000000000 +0000'),
        authors: 'Martin Bladt,   Christian Furrer',
        maintainers: 'Martin Bladt <martinbladt@math.ku.dk>',
        license: 'GPL (>= 2)',
        dependencies: nil,
        r_version_needed: nil
      )
    end
  end
end