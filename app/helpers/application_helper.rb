require 'securerandom'

module ApplicationHelper

	include UserHelper

	def generate_uuid(text, length=16)
		return (text.gsub(' ', '-') + '-' + SecureRandom.urlsafe_base64(length)).downcase
	end

	def check_active
		@active = check_active_user
	end

	def get_expiry_date(days)
		return Time.now + (days.to_i * 24 * 60 * 60)
	end
end
