require 'dropbox_sdk'
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private

  def confirm_logged_in
    unless session[:user_id]
      flash[:warning] = "Please log in."
      redirect_to(:controller=> 'home', :action => 'index')
      return false #halts the before action
    else
      return true #continue to the action
    end
  end

end
