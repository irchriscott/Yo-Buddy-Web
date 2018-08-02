class YbKeyUsage < ApplicationRecord
  belongs_to :yb_key
  belongs_to :admin_user
end
