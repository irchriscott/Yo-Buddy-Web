class SubcategoryController < ApplicationController
	def index
  		@subcategories = Subcategory.all.order(name: :asc)
  	end

	def show
  		@category = Category.find(params[:category_id])
  		@subcategory = @category.subcategory.find(params[:id])
  		@items = @subcategory.item.all.order(created_at: :desc)
	end
end
