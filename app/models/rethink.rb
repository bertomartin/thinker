require 'errors'

class Rethink
  include Errors

  def self.validate(args)
    if args.has_key? :errors
      raise ValidationError.new('Bad request', args[:errors])
    end

    args
  end

  def self.validate_present(args, *keys)
    for k in keys
      unless args.has_key?(k) and args[k].present?
        args[:errors] ||= {}
        args[:errors][k] ||= []
        args[:errors][k] << "can't be blank."
      end
    end
    args
  end

  def self.validate_email(args)
    if args.has_key? :email
      args[:email].downcase!

      unless args[:email].present? and
        args[:email].match EMAIL_REGEX

        args[:errors] ||= {}
        args[:errors][:email] ||= []
        args[:errors][:email] << "is invalid."
      end
    end
    args
  end
end
