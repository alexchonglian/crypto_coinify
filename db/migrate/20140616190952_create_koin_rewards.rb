class CreateKoinRewards < ActiveRecord::Migration
  def change
    create_table :koin_rewards do |t|
      t.integer :coin_id
      t.text :trigger
      t.date :exp_date
      t.integer :amount
      t.integer :cap
      t.text :options
    end
  end
end
