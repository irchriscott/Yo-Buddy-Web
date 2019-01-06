require 'net/http'
require 'uri'
require 'json'

class HomeController < ApplicationController

	before_action :set_search_results, except: [:index, :notification_getway]
	skip_before_action :verify_authenticity_token, only: [:notification_getway]

	def index
		max_categories = 3
		@items = Item.all.shuffle
		@title = "Yo Buddy !"
		if is_logged_in? then
			@categories = Array.new
			followed = Usercategory.where(user_id: session[:user_id]).order("RAND()").limit(max_categories)
			followed.each { |f| @categories.push f.category }
			if followed.count < max_categories then
				remain = max_categories - followed.count
				others =  Category.where.not(id: followed.map(&:id)).order("RAND()").limit(remain)
				others.each { |category| @categories.push category }
			end
		else
			@categories =  Category.order("RAND()").limit(max_categories)
		end
	end

	def search
		respond_to do |format|

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

			format.html { redirect_to search_items_path(q: @query) }
			format.json { render json: {"query" => @query , "results" => @results.shuffle } }
		end
	end

	def search_items
	end

	def search_requests
	end

	def search_users
	end

	def notification_getway
		uri = URI.parse("http://127.0.0.1:5000/notification/subscribe")

		headers = {"content-type" => "application/json"}
		http = Net::HTTP.new(uri.host, uri.port)
		request = Net::HTTP::Post.new(uri.request_uri, headers)
		request.body = {"subscription" => params[:subscription], "data" => {"title" => params[:title], "body" => params[:body], "icon" => params[:icon], "url" => params[:url]}}.to_json

		response = http.request(request)
		render json: {"type" => "success", "text" => "Notification Sent"}
	end

	private def set_search_results
		@query = params[:q]
		@users = User.where("name LIKE :query OR username LIKE :query", {query: "%#{@query}%"}).order(name: :asc)
		@items = Item.where("name LIKE :query", {query: "%#{@query}%"}).order(created_at: :desc)
		@requests = ItemRequest.where("title LIKE :query", {query: "%#{@query}%"}).order(created_at: :desc)
	end
end
