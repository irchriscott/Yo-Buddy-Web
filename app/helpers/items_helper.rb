module ItemsHelper
	
	include UserHelper

	def check_session
        if !is_logged_in? then
            flash[:danger] = "Loggin Required !!!"
            redirect_to new_user_path
        end
    end

    private def set_item_data_item
        @categories = Category.all
        @subcategories = Subcategory.all

        @currencies = Array.new

        @currencies.append({"currency" => "UGX", "name" => "Uganda Shilling"})
        @currencies.append({"currency" => "FRC", "name" => "Franc Congolais"})
        @currencies.append({"currency" => "USD", "name" => "United State Dollars"})

        @per = Array["Hour", "Day", "Week", "Month", "Year"]
    end
end
