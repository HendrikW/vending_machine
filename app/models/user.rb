PASSWORD_REQUIREMENTS = /\A 
 (?=.{8,}) # minimum length 8
 (?=.*\d)  # at least one number
/x

class User < ApplicationRecord
    has_secure_password
    validates :password_confirmation, presence: true, if: :password
    validates :password, format: PASSWORD_REQUIREMENTS, if: :password

    validates :username, presence: true, uniqueness: { case_sensitive: false }

    enum role: [:buyer, :seller]
    validates :role, presence: true

    def deposit
      super || 0
    end

    def deposit_coin(coin_value)
      unless [5, 10, 20, 50, 100].include?(coin_value)
        return false
      end
      self.deposit = self.deposit + coin_value
      true
    end

    def deposit_coin!(coin_value)
      if deposit_coin(coin_value) 
         self.save!
         return true
      end
      false
    end

    def as_json(options = nil)
      super({ only: [:username, :role, :deposit] }.merge(options || {}))
    end
end
