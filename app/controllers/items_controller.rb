class ItemsController < ApplicationController

    include ItemsHelper
    include ApplicationHelper

    before_action :check_session, only: [:new, :edit]
    before_action :set_item_data_item, only: [:new, :edit, :create, :update, :show]
    before_action :check_token, only:[:like_item, :like_item_destroy, :create, :destroy, :update, :delete_image_item]
    skip_before_action :verify_authenticity_token

    def index
        @items = Item.all.order(created_at: :desc)
    end

    def show
        @item = Item.find(params[:id])
    end

    def new
        @item = Item.new
        render layout: false
    end

    def create
        respond_to do |format|

            @item = Item.new(item_params)
            @item.user_id = session[:user_id]
            @item.is_available = true
            @item.is_deleted = false
            @item.uuid = generate_uuid(params[:item][:name])

            if @item.save then
                images = params[:item][:image]
                for image in images
                    @image = ItemImage.new
                    @image.item_id = @item.id
                    @image.image = image
                    if @image.save then
                    else
                        flash[:danger] = @image.errors.full_messages
                        format.json{ render json: {"type" => "error", "text" => @image.errors.full_messages} }
                    end
                end

                format.html { redirect_to session_items_path }
                format.json { render json: {"type" => "success", "text" => "Item Added Successfully !!!"} }
                flash[:success] = "Item Added Successfully !!!"
            else
                format.html { redirect_to session_items_path }
                format.json { render json: {"type" => "error", "text" => @item.errors.full_messages}, status: :unprocessable_entity }
                flash[:danger] = @item.errors.full_messages
            end
        end

    end

    def edit
        @item = Item.find(params[:id])
        if @item.user.id == session[:user_id] then
        render layout: false
        end
    end

    def update
        respond_to do |format|
            @item = Item.find(params[:id])
            @item.is_available = params[:item][:is_available]
            @item.uuid = generate_uuid(params[:item][:name])
            if @item.user.id == session[:user_id] then
                subcat = Subcategory.find(params[:item][:subcategory_id])
                if subcat.category.id == params[:item][:category_id].to_i then
                    if @item.update(item_params) then
                        images = params[:item][:image]
                        if images then
                            for image in images
                                @image = ItemImage.new
                                @image.item_id = @item.id
                                @image.image = image
                                if @image.save then
                                else
                                    flash[:danger] = @image.errors.full_messages
                                end
                            end
                        end
                        format.html { redirect_to @item }
                        format.json { render json: {"type" => "success", "text" => @item} }
                        flash[:success] = "Item Updated Successfully !!!"
                    else
                        format.html { redirect_to @item }
                        format.json { render json: { "type" => "error", "text" => @item.errors }, status: :unprocessable_entity }
                        flash[:danger] = @item.errors.full_messages
                    end
                else
                    format.html { redirect_to @item }
                    format.json { render json: { "type" => "error", "text" => "Subcategory is not the child of Category !!!" }, status: :unprocessable_entity }
                    flash[:danger] = "Subcategory is not the child of Category !!!"
                end
            else
                format.html { redirect_to @item }
                format.json { render json: { "type" => "error", "text" => "You are not the owner !!!" }, status: :unprocessable_entity }
                flash[:danger] = "You are not the owner !!!"
            end
        end
    end

    def available
        @dates = Array.new
        @item = Item.find(params[:id])
        now = Time.new.localtime
        @borrows = @item.borrow_item_user.where("status = :status OR status = :status_else", {status: "accepted", status_else: "rendered"}).order(from_date: :asc)
        
        if @borrows.count > 0 then
            if @borrows[0].from_date.localtime > now then
                date = Hash.new 
                date["from"] = now
                date["to"] = @borrows[0].from_date.localtime - (1 * 60 * 60)
                date["count"] = @item.count
                @dates.append(date)
            end
        else
            date = Hash.new 
            date["from"] = now
            date["to"] = "-"
            date["count"] = @item.count
            @dates.append(date)
        end


        @borrows.each_with_index do |_,i|
            if i != 0  then
                if @borrows[i - 1].from_date.localtime >= @borrows[i].from_date.localtime and @borrows[i].to_date.localtime >= @borrows[i - 1].to_date.localtime then
                    date = Hash.new 
                    date["from"] = @borrows[i].from_date.localtime - (1 * 60 * 60)
                    date["to"] = @borrows[i].to_date.localtime + (1 * 60 * 60)
                    date["count"] = @item.count - (@borrows[i].count.to_i + @borrows[i - 1].count.to_i)
                    @dates.append(date)
                end
                if @borrows[i].from_date.localtime >= @borrows[i - 1].from_date.localtime and @borrows[i - 1].to_date.localtime >= @borrows[i].from_date.localtime  then
                    date = Hash.new 
                    date["from"] = @borrows[i - 1].from_date.localtime - (1 * 60 * 60)
                    date["to"] = @borrows[i - 1].to_date.localtime + (1 * 60 * 60)
                    date["count"] = @item.count - @borrows[i - 1].count 
                    @dates.append(date)
                end
                
                if @borrows[i].to_date.localtime >= @borrows[i - 1].to_date.localtime and @borrows[i].from_date.localtime <= @borrows[i - 1].to_date.localtime then 
                    date = Hash.new 
                    date["from"] = @borrows[i].from_date.localtime - (1 * 60 * 60)
                    date["to"] = @borrows[i - 1].to_date.localtime + (1 * 60 * 60)
                    date["count"] = @item.count - (@borrows[i].count.to_i + @borrows[i - 1].count.to_i)
                    @dates.append(date)
                    _date = Hash.new 
                    _date["from"] = @borrows[i - 1].to_date.localtime - (1 * 60 * 60)
                    _date["to"] = @borrows[i].to_date.localtime + (1 * 60 * 60)
                    _date["count"] = @item.count - @borrows[i].count.to_i 
                    @dates.append(_date)
                end

                if @borrows[i].from_date.localtime >= @borrows[i - 1].to_date.localtime and @borrows[i].to_date.localtime >= @borrows[i - 1].to_date.localtime then
                    date = Hash.new 
                    date["from"] = @borrows[i - 1].to_date.localtime - (1 * 60 * 60)
                    date["to"] = @borrows[i].from_date.localtime + (1 * 60 * 60)
                    date["count"] = @item.count
                    @dates.append(date)
                end

                if @borrows[i].from_date.localtime >= @borrows[i - 1].from_date.localtime and @borrows[i - 1].to_date.localtime >= @borrows[i].to_date.localtime then
                    if @borrows[i].from_date.localtime > @borrows[i - 1].from_date.localtime then
                        date = Hash.new 
                        date["from"] = @borrows[i - 1].from_date.localtime - (1 * 60 * 60)
                        date["to"] = @borrows[i].from_date.localtime + (1 * 60 * 60)
                        date["count"] = @item.count - @borrows[i - 1].count.to_i
                        @dates.append(date)
                    end

                    if true then
                        date = Hash.new 
                        date["from"] = @borrows[i].from_date.localtime - (1 * 60 * 60)
                        date["to"] = @borrows[i].to_date.localtime + (1 * 60 * 60)
                        date["count"] = @item.count - (@borrows[i].count.to_i + @borrows[i - 1].count.to_i)
                        @dates.append(date)
                    end

                    if @borrows[i - 1].to_date.localtime > @borrows[i].to_date.localtime then
                        date = Hash.new 
                        date["from"] = @borrows[i].to_date.localtime - (1 * 60 * 60)
                        date["to"] = @borrows[i - 1].to_date.localtime + (1 * 60 * 60)
                        date["count"] = @item.count - @borrows[i - 1].count.to_i
                        @dates.append(date)
                    end
                end
            end
            if i == @borrows.count - 1 then
                if @borrows[i].from_date.localtime >= @borrows[i - 1].from_date.localtime and @borrows[i - 1].to_date.localtime >= @borrows[i].to_date.localtime then
                    date = Hash.new 
                    date["from"] = @borrows[i - 1].to_date.localtime - (1 * 60 * 60)
                    date["to"] = "-"
                    date["count"] = @item.count
                    @dates.append(date)
                else
                    date = Hash.new 
                    date["from"] = @borrows[i].to_date.localtime - (1 * 60 * 60)
                    date["to"] = "-"
                    date["count"] = @item.count
                    @dates.append(date)
                end
            end
        end

        render layout: false
    end

    def delete_image_item
        
        @image = ItemImage.find(params[:id])
        @item = Item.find(@image.item.id)
        @images = @item.item_image.all

        if @image.item.user.id == session[:user_id] then
            if @images.length > 2 then
                @image.destroy
                render json: {"type" => "success", "text" => "Image Deleted Successfully !!!"}
            else
                render json: {"type" => "error", "text" => "Item Images Are Few !!!"}
            end
        else
            render json: {"type" => "error", "text" => "You are not the owner !!!"}
        end
    end

    def destroy
        @item = Item.find(params[:id])
        if @item.user.id == session[:user_id] then
        @item.is_deleted = true
        @item.save
        end
        redirect_to session_items_path
    end

    def like_item
        @like = ItemLike.new
        @like.item_id = params[:like][:item_id]
        @like.user_id = (is_logged_in?) ? session[:user_id] : params[:like][:session]
        user_id = (is_logged_in?) ? session[:user_id] : params[:like][:session]

        item = Item.find(params[:like][:item_id])
        
        check_like = ItemLike.where(user_id: user_id, item_id: params[:like][:item_id]).first

        if check_like == nil then
            if @like.save then
                Notification.create([{user_from_id: session[:user_id], user_to_id: item.user.id, ressource: "item_like", ressource_id: item.id, is_read: false}])
                render json: {"type" => "like", "text" => "Item Liked !!!"}
            else
                render json: {"type" => "error", "error" => @like.errors.full_messages}
            end
        else
            check_like.destroy
            render json: {"type" => "dislike", "text" => "Item Disliked !!!"}
        end
    end

    def like_item_destroy
        like = ItemLike.find(params[:id])
        if like != nil then
            if like.user.id == session[:user_id] then
                like.destroy
                render json: {"type" => "success", "text" => "Item Disliked !!!"}
            else
                render json:{"type" => "error", "text" => "You Are Not The Owner !!!"}
            end
        else
            render json:{"type" => "error", "text" => "Item Like Not Found !!!"}
        end 
    end

    def favourite_item
        @favourite = ItemFavourite.new
        @favourite.item_id = params[:favourite][:item_id]
        @favourite.user_id = session[:user_id]

        check_favourite = ItemFavourite.where(user_id: session[:user_id], item_id: params[:favourite][:item_id]).first

        if check_favourite == nil then
            if @favourite.save then
                render json: {"type" => "success", "text" => "Item Marked as Favourite !!!"}
            else
                render json: {"type" => "error", "error" => @favourite.errors.full_messages}
            end
        else
            check_favourite.destroy
            render json: {"type" => "unmark", "text" => "Item Unmarked as Favourite !!!"}
        end
    end

    def favourite_item_destroy
        favourite = ItemFavourite.find(params[:id])
        if favourite != nil then
            if favourite.user.id == session[:user_id] then
                favourite.destroy
                render json: {"type" => "success", "text" => "Item Unmarked as Favourite !!!"}
            else
                render json: {"type" => "error", "text" => "You are not the Owner !!!"}
            end
        else
            render json: {"type" => "error", "text" => "404: Favourite Not Found !!!"}
        end
    end

    private def item_params
        params.require(:item).permit(:name, :category_id, :subcategory_id, :price, :currency, :per, :description, :count)
    end
end
