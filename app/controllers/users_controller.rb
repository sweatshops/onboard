class UsersController < ApplicationController

	layout "user_layout"

  before_action :confirm_logged_in
  
	def index

	end

  def setting
  end

  def logout
  end
  
end
