class UserFollow < ApplicationRecord
  belongs_to :user

  def following
  	return User.find(following_id)
  end
end
