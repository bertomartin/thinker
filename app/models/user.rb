class User < Rethink

  def self.validate(args)
    User.validate_password(args)
    Rethink.validate_email(args)

    super(args)
  end

  def self.validate_password(args)
    salted_fish = if args[:password].present?
      if args[:password] == args[:password_confirmation]
        salt = BCrypt::Engine.generate_salt
        fish = BCrypt::Engine.hash_secret(args[:password], salt)

        { salt: salt, fish: fish }
      else
        args[:errors] ||= {}
        args[:errors][:password] = [ "doesn't match confirmation." ]
        {}
      end
    else
      {}
    end

    args.merge( salted_fish ).except( :password, :password_confirmation )
  end
end
