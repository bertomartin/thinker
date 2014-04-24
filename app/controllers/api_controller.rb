class ApiController < ApplicationController

  def index
    render json: { links: { users: users_url, articles: articles_url } }
  end

  def uuids
    num = params[:num].to_i
    num = num < 1 ? 1 : num

    render json: { uuids: (0...num).map { SecureRandom.uuid } }
  end
end
