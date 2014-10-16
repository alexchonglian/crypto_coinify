class CreateCoins < ActiveRecord::Migration
  def change
    create_table :coins do |t|
      t.string :name, null: false
      t.references :user, null: false, index: true
      t.references :project, index: true
      t.decimal :total_amount, precision: 32, scale: 16, null: false
      t.decimal :total_issued, precision: 32, scale: 16, null: false, default: 0
      t.decimal :sold, precision: 32, scale: 16, null: false, default: 0
      t.decimal :redeemed, precision: 32, scale: 16, null: false, default: 0
      t.decimal :price, precision: 32, scale: 16, null: false
      t.text :description

      t.timestamps
    end
  end
end
