class AddKoinpowerAndKoinnameToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :koinpower, :string
    add_column :projects, :koinname, :string
  end
end
