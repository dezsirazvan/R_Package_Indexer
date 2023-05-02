class PackagesController < ApplicationController
  def index
    # Render a view that displays all packages and their information
    @packages = PackagesLoader.load
  end
end