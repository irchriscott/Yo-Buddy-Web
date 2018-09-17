class CategoryController < ApplicationController
  	
  	def index
  		  @categories = Category.all.order(name: :asc)
  	end

  	def show
  		  @category = Category.find(params[:id])
  		  @subcategories = @category.subcategory.all.order(name: :asc)
  		  @active = params[:activate]
  		  @categories = Category.all.order(name: :asc)
  	end

  	def follow
    		if is_logged_in?
      			check_follow = Usercategory.where(user_id: session[:user_id], category_id: params[:follow][:category_id]).first
      			if check_follow == nil then
        				follow = Usercategory.new
      	  			follow.user_id = session[:user_id]
      	  			follow.category_id = params[:follow][:category_id]
      	  			follow.save
      	  			render json: {"type" => "follow", "text" => "Category Followed !!!"}
      			else
        				check_follow.destroy
        				render json: {"type" => "unfollow", "text" => "Category Unfollowed !!!"}
      			end
    		else
    			 render json: {"type" => "error", "text" => "Loggin Please !!!"}
    		end
  	end
end
