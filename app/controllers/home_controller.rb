class HomeController < ApplicationController
	def index
		
	end

	def dropbox_auth
		#flow = DropboxOAuth2FlowNoRedirect.new(ENV["DROPBOX_API_KEY"], ENV["DROPBOX_API_SECRET"])
		csrf_state = SecureRandom.hex(n=16)
		session[:csrf_state] = csrf_state
		redirect_to("https://www.dropbox.com/1/oauth2/authorize?response_type=code&client_id=" +ENV['DROPBOX_API_KEY'] + "&redirect_uri=" + ENV['DROPBOX_CALLBACK'] + "&state=" +csrf_state)

	end

	def dropbox_callback
		if !params.has_key?(:state) || !params.has_key?(:code)
			flash[:danger] = "Authorization failed"
			redirect_to root_path
			return
		end

		if params[:state] != session[:csrf_state]
			flash[:error] = "Authorization failed"
			redirect_to root_path
			return
		end

		response = Unirest.post "https://api.dropbox.com/1/oauth2/token", 
                        headers:{ "Accept" => "application/json" }, 
                        parameters:{ :code => params[:code], :grant_type => "authorization_code" , :client_id => ENV['DROPBOX_API_KEY'], :client_secret => ENV['DROPBOX_API_SECRET'], :redirect_uri => ENV['DROPBOX_CALLBACK']}

		if response.body.has_key?("access_token") && response.body.has_key?("uid")
			
			tmpUser = User.where(:uid => response.body["uid"]).first_or_create
			tmpUser.update(:access_token => response.body["access_token"])

			session[:user_uid] = tmpUser.uid
      session[:user_id] = tmpUser.id

			#flash[:success] = "You have successfully authorized with dropbox. with access token " + response.body["access_token"] + " and uid " + response.body["uid"]

			redirect_to user_path
			return
		else
			flash[:danger] = "Authorization failed"
			redirect_to root_path
			return
		end
	end

	def dropbox_deauth
		if session[:user_id]
			current_user = User.find(session[:user_id])
			dropbox_client = DropboxClient.new(current_user.access_token)
			dropbox_client.disable_access_token
			reset_session
		end

		flash[:success] = "Successfully logged out"
		redirect_to root_path
	end
end
