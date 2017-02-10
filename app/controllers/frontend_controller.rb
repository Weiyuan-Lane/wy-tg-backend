class FrontendController < ApplicationController
  def index
    render 'index', layout: 'application_frontend'
  end
end
