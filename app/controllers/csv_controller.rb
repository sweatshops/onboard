class CsvController < ApplicationController
  #api
  protect_from_forgery with: :null_session

  #before_action :destroy_session
  before_action :check_valid_params

  #addrecord
  def add

    name_regex = /\A[a-zA-Z0-9 !?,_.-]+\z/
    email_regex = /\A[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}\Z/i

    if !params.has_key?(:first_name) || !params.has_key?(:last_name) || !params.has_key?(:email)
      @result = {:result =>'false' , :message => 'Insufficient input parameters'}
      render json: @result, :status => 400
      return
    end

    if !(params[:first_name] =~ name_regex) || !(params[:last_name] =~ name_regex) || !(params[:email] =~ email_regex)
      @result = {:result =>'false' , :message => 'Invalid input parameters'}
      render json: @result, :status => 400
      return
    end

    first_name = params[:first_name]
    last_name = params[:last_name]
    email = params[:email]

    dropbox_client = DropboxClient.new(@app.user.access_token)

    #in case file is deleted
    begin
      csv_content = dropbox_client.get_file(@app.filePath)
    rescue Exception => e
      csv_content = ""
    end
    
    if csv_content.length > 10000
      @result = {:result =>'false' , :message => 'File size limit reached'}
      render json: @result, :status => 400
      return
    end

    csv_content = csv_content + "\n\"" + first_name + "\",\"" + last_name + "\",\"" + email + "\""

    response = dropbox_client.put_file('/' + @app.filePath, csv_content, true)

    #redirect to page if redirect_url exist
    if params.has_key?(:redirect_url)
      if params[:redirect_url] =~ URI::regexp
        redirect_to params[:redirect_url]
        return
      end
    end

    @result = {:result => 'true', :content => '"'+ first_name +'","' + last_name + '","' + email + '"', :requester => request.env["HTTP_REFERER"], :file_size => csv_content.length}
    render json: @result, :status => 200
    return
  end

  private

  def destroy_session
    request.session_options[:skip] = true
  end

  def check_valid_params
    appID = params[:appid]
    appName = params[:appname]
    @app = App.where(:id => appID).where(:name => appName).first

    if !@app
      @result = {:result =>'false' , :message => 'Invalid app parameters'}
      render json: @result, :status => 400
      return
    end

  end
end
