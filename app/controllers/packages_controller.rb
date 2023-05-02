class PackagesController < ApplicationController
  def index
    # Render a view that displays all packages and their information
    @page = (params[:page] || 1).to_i
    per_page = 1000

    @packages = PackagesLoader.load(page: @page, per_page: per_page)
  end
end