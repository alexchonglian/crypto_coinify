class CreateKoinPower < ActiveRecord::Migration
  def change
    create_table :koin_powers do |t|
      t.string :name
      t.string :description
      t.float :cost
    end
  end
end
