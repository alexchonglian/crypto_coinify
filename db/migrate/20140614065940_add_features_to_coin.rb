class AddFeaturesToCoin < ActiveRecord::Migration
  def change
    add_column :coins, :features, :string
  end
end
