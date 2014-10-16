class AddCpKeyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :cp_key, :string
  end
end
