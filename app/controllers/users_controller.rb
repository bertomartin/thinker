class UsersController < RestController

  protected

  def attrs
    [ :id, :email, :created_at, :updated_at ]
  end

  def safe_params
    user = params[:user]

    salted_fish = if user[:password].present? and
      user[:password] == user[:password_confirmation]

      salt = BCrypt::Engine.generate_salt
      fish = BCrypt::Engine.hash_secret(params[:password], salt)

      { salt: salt, fish: fish }
    else
      {}
    end

    params.require(:user).permit(
      :email, :password, :password_confirmation
    ).merge( salted_fish ).except( :password, :password_confirmation )
  end
end
