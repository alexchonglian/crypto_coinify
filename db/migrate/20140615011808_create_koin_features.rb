class CreateKoinFeatures < ActiveRecord::Migration
  def change
    create_table :koin_features do |t|
      t.string :name
      t.string :description
      t.float :requirement
    end
  end
end
