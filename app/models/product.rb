class Product < ApplicationRecord
    belongs_to :seller, class_name: "User"
    validates :seller_id, presence: true

    validates :product_name, presence: true, length: { minimum: 3 }
    validates :amount_available, numericality: { greater_than_or_equal_to: 0 }

    validate :cost_is_multiple_of_five


    def amount_available
        super || 0
    end

    def cost_is_multiple_of_five
        unless cost > 0 && cost % 5 === 0
          errors.add(:cost, "has to be a multiple of five")
        end
    end

    def as_json(options = nil)
        super({ only: [:id, :product_name, :amount_available, :cost, :seller_id] }.merge(options || {}))
    end
end
