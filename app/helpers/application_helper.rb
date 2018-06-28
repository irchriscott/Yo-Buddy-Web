require 'securerandom'

module ApplicationHelper

	include UserHelper

	def generate_uuid(text)
		return (text.gsub(' ', '-') + '-' + SecureRandom.urlsafe_base64(16)).downcase
	end
end
