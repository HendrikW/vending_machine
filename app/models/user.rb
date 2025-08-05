# frozen_string_literal: true

PASSWORD_REQUIREMENTS = /\A
 (?=.{8,}) # minimum length 8
 (?=.*\d)  # at least one number
/x

# User class
class User < ApplicationRecord
  has_secure_password
  validates :password_confirmation, presence: true, if: :password
  validates :password, format: PASSWORD_REQUIREMENTS, if: :password

  validates :username, presence: true, uniqueness: { case_sensitive: false }

  enum role: %i[buyer seller]
  validates :role, presence: true

  # NOTE: "dependent: :destroy" is being handled at database level using on_delete: cascade
  has_many :products, foreign_key: :seller_id

  def deposit
    super || 0
  end

  def deposit_coin(coin_value)
    return false unless [5, 10, 20, 50, 100].include?(coin_value)

    self.deposit = deposit + coin_value
    true
  end

  def deposit_coin!(coin_value)
    if deposit_coin(coin_value)
      save!
      return true
    end
    false
  end

  # the change the vending machine has to return with optimal coin allocation
  def available_change
    result = []
    leftover = deposit
    [100, 50, 20, 10, 5].each do |coin_value|
      result << "#{leftover / coin_value} x #{coin_value}"
      leftover = leftover % coin_value
    end
    result
  end

  def as_json(options = nil)
    super({ only: %i[username role deposit] }.merge(options || {}))
  end
end
