module ItemRequestsHelper
	include ItemsHelper

	def set_request_helper
		@status = Array["pending", "succeeded", "failed"]
		@sug_status = Array["pending", "accepted", "rejected", "removed"]
	end
end
