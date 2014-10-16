class CreateUsercoins < ActiveRecord::Migration
  def change
    create_table :usercoins do |t|
      t.references :user, null: false, index: true
      t.references :coin, null: false, index: true
      t.decimal :amount, precision: 32, scale: 16, null: false
      t.decimal :redeemed_amount, precision: 32, scale: 16, null: false, default: 0
      t.timestamps
    end
  end
end
