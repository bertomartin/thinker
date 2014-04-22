class UsersController < RestController

  protected

  def attrs
    [ :id, :email, :created_at, :updated_at ]
  end

  def safe_params
    params.require(:user).permit(:email)
  end
end
