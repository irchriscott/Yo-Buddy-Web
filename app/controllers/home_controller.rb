class HomeController < ApplicationController
	def index
		@items = Item.all
	end

	def search
		respond_to do |format|

			@users = User.where("name LIKE :query OR username LIKE :query", {query: "%#{params[:q]}%"}).order(name: :asc)
			@items = Item.where("name LIKE :query", {query: "%#{params[:q]}%"}).order(created_at: :desc)
			@requests = ItemRequest.where("title LIKE :query", {query: "%#{params[:q]}%"}).order(created_at: :desc)

			@results = Array.new

			@users.limit(15).each do |user|
				data = Hash.new
				data["type"] = "user"
				data["data"] = user.json
				@results.push(data)
			end

			@items.limit(15).each do |item|
				data = Hash.new
				data["type"] = "item"
				data["data"] = item.json
				@results.push(data)
			end

			@requests.limit(15).each do |request|
				data = Hash.new
				data["type"] = "request"
				data["data"] = request.json
				@results.push(data)
			end

			format.html { }
			format.json { render json: {"query" => params[:q] , "results" => @results.shuffle } }
		end
	end
end
