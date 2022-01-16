class UserAddCascadeDelete < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :products, :users, :column=>:seller_id
    add_foreign_key :products, :users, column: :seller_id, on_delete: :cascade
  end
end
