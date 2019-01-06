class SubcategoryController < ApplicationController
	def index
  		@subcategories = Subcategory.all.order(name: :asc)
  		@title = "YB - Subcategories"
  	end

	def show
  		@category = Category.find(params[:category_id])
  		@subcategory = @category.subcategory.find(params[:id])
  		@items = @subcategory.item.all.order(created_at: :desc).paginate(page: params[:page], per_page: 10)
  		@title = "YB - #{@subcategory.name}"
	end
end
