module ItemsHelper
	
	include UserHelper
    include ApplicationHelper

	def check_session
        if !is_logged_in? then
            flash[:danger] = "Loggin Required !!!"
            redirect_to new_user_path
        end
    end

    private def set_item_data_item
        @categories = Category.all
        @subcategories = Subcategory.all

        @currencies = ApplicationHelper::CURRENCIES

        @per = ApplicationHelper::PERS
    end
end
