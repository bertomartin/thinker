class ArticlesController < RestController

  protected

  def attrs
    [ :id, :title, :body, :user_id, :updated_at ]
  end

  def safe_params
    Article.validate(
      params.require(:article).permit(:title, :body)
    )
  end
end
