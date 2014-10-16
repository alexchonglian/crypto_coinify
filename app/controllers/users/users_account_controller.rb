class Users::UsersAccountController < ApplicationController
  actions :index
  belongs_to :user
  layout 'catarse_bootstrap'

end