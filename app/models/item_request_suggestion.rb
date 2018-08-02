class ItemRequestSuggestion < ApplicationRecord
  	belongs_to :item_request
  	belongs_to :item

  	def check_status
  		  @status = Array["pending", "accepted", "rejected", "removed"]
  		  case self.status
            when @status[0] then
  				      return "lightgreen"
  		      when @status[1] then
  				      return "green"
            when @status[2] then
  				      return "orange"
            when @status[3] then
                return "red"
            else
                return "gray"
        end
  	end
end
