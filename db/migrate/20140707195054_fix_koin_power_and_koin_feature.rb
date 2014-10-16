class FixKoinPowerAndKoinFeature < ActiveRecord::Migration
  def up
  	remove_column :projects, :koin_powers_and_features
  	remove_column :projects, :koinpower
  	add_column :projects, :koin_powers, :json
  	add_column :projects, :koin_features, :json
  end

  def down
  	add_column :projects, :koin_powers_and_features, :json
  	add_column :projects, :koinpower, :string
  	remove_column :projects, :koin_powers
  	remove_column :projects, :koin_features
  end
end
