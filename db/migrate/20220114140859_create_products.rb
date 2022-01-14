class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.integer :amount_available
      t.string :product_name
      t.integer :cost

      t.references :seller, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
