class UsersController < RestController

  protected

  def attrs
    [ :id, :email, :created_at, :updated_at ]
  end

  def safe_params
    User.validate(
      params.require(:user).permit(
        :email, :password, :password_confirmation
      )
    )
  end
end
