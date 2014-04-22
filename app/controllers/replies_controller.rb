class RepliesController < RestController

  protected

  def attrs
    [ :id, :body, :article_id, :user_id, :created_at, :updated_at ]
  end

  def safe_params
    params.require(:reply).permit(:body)
  end
end
