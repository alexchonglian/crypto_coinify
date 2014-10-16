class KoinFeature < ActiveRecord::Base
  validates_presence_of :name, :description, :requirement
  belongs_to :coin


  def self.array
    return [
        "Member forum @500",
        # "Member forum @ 500",
        "Early alpha access @ 2000",
        "Access to source code @ 5000",
        "Voting for Strategy @20000",
    ]
  end

end