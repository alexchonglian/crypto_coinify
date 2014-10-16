class AddAddressToUser < ActiveRecord::Migration
  def change
    add_column :users, :cp_address, :string
  end
end
