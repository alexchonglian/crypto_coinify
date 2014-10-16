class KoinPower < ActiveRecord::Base
  validates_presence_of :name, :description, :cost
  belongs_to :coin



  def self.array
    return [
        "10,000 Mario Gold @ 100",
        "Super Jump @ 500",
        "Invincible @ 2000"
    ]
  end
end