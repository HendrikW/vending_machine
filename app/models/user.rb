PASSWORD_REQUIREMENTS = /\A 
 (?=.{8,}) # minimum length 8
 (?=.*\d)  # at least one number
/x

class User < ApplicationRecord
    has_secure_password
    validates :password_confirmation, presence: true
    validates :password, format: PASSWORD_REQUIREMENTS

    validates :username, presence: true, uniqueness: { case_sensitive: false }

    enum role: [:buyer, :seller]
    validates :role, presence: true

    def as_json(options = nil)
      super({ only: [:username, :role, :deposit] }.merge(options || {}))
    end
end
