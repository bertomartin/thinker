class RepliesController < RestController

  protected

  def attrs
    [ :id, :body, :article_id, :username, :created_at, :updated_at ]
  end

  def safe_params
    Reply.validate( params.require(:reply).permit(:body, :username) )
  end
end
