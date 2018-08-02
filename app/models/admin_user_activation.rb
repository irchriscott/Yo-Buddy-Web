class AdminUserActivation < ApplicationRecord

  	belongs_to :admin_user
  	belongs_to :yb_key
end
