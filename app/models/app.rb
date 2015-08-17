require 'dropbox_sdk'

class App < ActiveRecord::Base
  belongs_to :user, :foreign_key => 'user_id'

  NAME_REGEX = /\A[a-zA-z0-9\-_]+\Z/

  validates :name, :presence => true, :length => { :minimum=> 1, :maximum => 64 }, :format => NAME_REGEX
  validates :itunes_app_id, numericality: { only_integer: true } , :allow_nil => true, :allow_blank => true

  #http://stackoverflow.com/questions/1805761/check-if-url-is-valid-ruby
  validates :request_origin_url, :length => { :maximum => 255 }, :format => URI::regexp , :allow_nil => true, :allow_blank => true

  def restURL
    ENV['API_BASE_URL'] + self.id.to_s + '/' + self.name
  end

  def filePath
    self.id.to_s + '-' + self.name + '.csv'
  end

  def check_expire
    #today is later than expire date
    if Date.today > self.expire
      dropbox_client = DropboxClient.new(self.user.access_token)
      shortlinkhash = dropbox_client.shares(self.filePath)
      self.download_link = shortlinkhash['url']
      self.expire = shortlinkhash['expires']

      self.save
    end
  end
end
