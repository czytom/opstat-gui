class User
  include MongoMapper::Document
#  plugin MongoMapper::Devise
  set_collection_name "opstat.users"
  devise :database_authenticatable, :confirmable, :lockable, 
         :recoverable, :rememberable, :registerable, :trackable, 
         :timeoutable, :validatable

  attr_accessible :name, :email, :password, :password_confirmation, :remember_me
  key :encrypted_password, String
  key :username, String
  key :email, String
  key :remember_created_at, Time
  key :confirmation_token, String
  key :confirmed_at, Time
  key :locked_at, Time
  key :current_sign_in_ip, String
  key :last_sign_in_ip, String
  key :sign_in_count, Integer
  key :failed_attempts, Integer
  key :current_sign_in_at, Time
  key :last_sign_in_at, Time
  key :confirmation_sent_at,Time
  key :unconfirmed_email, Boolean
end

