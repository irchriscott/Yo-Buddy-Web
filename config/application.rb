require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Buddyweb

    MAX_HOURS_PENALTIES = 4

  	class Application < Rails::Application

    	# Initialize configuration defaults for originally generated Rails version.

    	config.load_defaults 5.1

    	# Settings in config/environments/* take precedence over those specified here.
   	 	# Application configuration should go into files in config/initializers
    	# -- all .rb files in that directory are automatically loaded.

      config.web_console.whitelisted_ips = ['10.0.5.159', '10.0.2.2', '127.0.0.1']
      config.web_console.whiny_requests = true

    	config.action_dispatch.default_headers = {
		      'Access-Control-Allow-Origin' => '*',
		      'Access-Control-Request-Method' => %w{GET POST PUT DELETE PATCH}.join(",")
		  }

      config.exceptions_app = self.routes


      config.action_mailer.default_url_options = { host: '127.0.0.1:3000' }
      config.action_mailer.asset_host = '127.0.0.1:3000'

      config.active_job.queue_adapter = :sidekiq

      config.action_mailer.delivery_method = :smtp
      config.action_mailer.smtp_settings = {
          :address => "smtp.gmail.com",
          :port => "587",
          :domain => "gmail.com",
          :user_name => "irchristianscott@gmail.com",
          :password => "323639371998",
          :authentication => :login,
          :enable_starttls_auto => true
      } 

  	end
end
