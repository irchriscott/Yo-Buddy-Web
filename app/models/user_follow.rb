class UserFollow < ApplicationRecord
  belongs_to :user

  def following
  	return User.find(self.following_id)
  end
end
