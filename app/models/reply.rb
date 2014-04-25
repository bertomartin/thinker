class Reply < Rethink

  def self.validate(args)
    Rethink.validate_present(args, :body, :username )

    super(args)
  end

end
