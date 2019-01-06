class ErrorController < ApplicationController
	def not_found_error
		@title = "YB - OOPS 404"
		respond_to do |format|
			format.html{ render status: 404 }
		end
	end

	def internal_server_error
		@title = "YB - OOPS 500"
		respond_to do |format|
			format.html{ render status: 500 }
		end
	end
end
