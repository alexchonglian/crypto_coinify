class AddFkToKoinFeature < ActiveRecord::Migration
  def change
    add_column :koin_features, :coin_id, :integer
  end
end
