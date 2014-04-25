class Article < Rethink

  def self.validate(args)
    Rethink.validate_present(args, :title, :body )

    super(args)
  end

end
