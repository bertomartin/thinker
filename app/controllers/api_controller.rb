class ApiController < ApplicationController

  def index
    render json: { links: { users: users_url, articles: articles_url } }
  end

  def uuids
  end
end
