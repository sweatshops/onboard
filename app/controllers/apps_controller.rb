class AppsController < ApplicationController

	layout "user_layout"

  before_action :confirm_logged_in
  before_action :check_for_valid_id, only: [:edit, :update, :delete]

	def index
    current_user = User.find(session[:user_id])
    @apps = current_user.apps
    @apps.each do |app|
      app.check_expire
    end

    @apps
	end

  def edit

  end

  def update
    if @app.update_attributes(app_edit_params)
      flash[:success] = 'App information updated'
      redirect_to(:action => 'edit')
    else
      render('edit')
    end
  end

	def new
    @app = App.new
	end

  def create
    @app = App.new(app_params)

    current_user = User.find(session[:user_id])
    @app.user = current_user

    begin
      dropbox_client = DropboxClient.new(current_user.access_token)
    rescue Exception => e
      flash[:danger] = 'Please login with Dropbox again'
      redirect_to root_path
    end

    if @app.save
      dropbox_client = DropboxClient.new(current_user.access_token)
      response = dropbox_client.put_file('/' + @app.id.to_s + '-' + @app.name + '.csv', "")
      shortlinkhash = dropbox_client.shares(@app.filePath)
      @app.download_link = shortlinkhash['url']
      @app.expire = shortlinkhash['expires']

      @app.save

      flash[:success] = 'App created.'
      redirect_to(:action => 'index')
    else
      render("new")
    end
  end

  def delete
    @app.destroy
    flash[:success] = 'App deleted.'
    redirect_to(:action => 'index')
  end

  private

  def app_params
    params.require(:app).permit(:name, :itunes_app_id, :request_origin_url)
  end

  def app_edit_params
    params.require(:app).permit(:itunes_app_id, :request_origin_url)
  end

  def check_for_valid_id

    @app = App.where(:id => params[:id]).where(:user_id => session[:user_id]).first
    if !@app
      flash[:warning] = 'Invalid app id specified'
      redirect_to(:action => 'index')
    end

  end
end
