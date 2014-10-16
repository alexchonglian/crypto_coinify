require 'json'

class Coin < ActiveRecord::Base
  belongs_to :user
  belongs_to :project

  has_many :koin_features
  has_many :koin_powers


  # def name=(val)
  #   self[:name] = val.capitalize
  # end
  delegate :display_image, to: :project
  #Everywhere in the API an asset is referenced as an uppercase alphabetic (base 26) string name of the asset,
  # of at least 4 characters in length and not starting with 'A', or as 'BTC' or 'XCP' as appropriate. Examples are:
end
