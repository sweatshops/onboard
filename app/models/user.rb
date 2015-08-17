class User < ActiveRecord::Base
  has_many :apps, dependent: :destroy
end
